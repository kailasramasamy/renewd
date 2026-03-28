import type { FastifyInstance } from "fastify";
import Anthropic from "@anthropic-ai/sdk";
import { authMiddleware } from "../../middleware/auth.js";
import { ValidationError } from "../../lib/errors.js";
import { env } from "../../config/env.js";

const client = new Anthropic({ apiKey: env.CLAUDE_API_KEY });

const SYSTEM_PROMPT = `You are Renewd AI — a helpful assistant for the Renewd app, a personal renewal and subscription tracker.
You have access to the user's renewals, payments, and analytics data through tools.
Be concise, practical, and friendly. Format currency in Indian Rupees (₹).
When showing lists, keep them brief. When asked about spending, use the analytics tools.`;

const TOOLS: Anthropic.Tool[] = [
  {
    name: "get_renewals",
    description: "Get the user's renewal items. Returns all active renewals sorted by urgency.",
    input_schema: { type: "object" as const, properties: {}, required: [] },
  },
  {
    name: "get_payments",
    description: "Get payment history for a specific renewal or all payments.",
    input_schema: {
      type: "object" as const,
      properties: {
        renewal_id: { type: "string", description: "Optional renewal ID to filter by" },
      },
      required: [],
    },
  },
  {
    name: "get_spending_by_category",
    description: "Get total spending grouped by renewal category (insurance, subscription, etc.)",
    input_schema: { type: "object" as const, properties: {}, required: [] },
  },
  {
    name: "get_spending_by_month",
    description: "Get monthly spending totals for the last 12 months",
    input_schema: { type: "object" as const, properties: {}, required: [] },
  },
];

export default async function chatRoutes(app: FastifyInstance) {
  app.post("/", { preHandler: authMiddleware }, async (request, reply) => {
    const body = request.body as { message?: string };
    if (!body.message || typeof body.message !== "string") {
      throw new ValidationError("message is required");
    }

    const uid = request.user.uid;
    const messages: Anthropic.MessageParam[] = [
      { role: "user", content: body.message },
    ];

    let response = await client.messages.create({
      model: env.CLAUDE_MODEL,
      max_tokens: 1024,
      system: SYSTEM_PROMPT,
      tools: TOOLS,
      messages,
    });

    // Handle tool use loop (max 3 rounds)
    let rounds = 0;
    while (response.stop_reason === "tool_use" && rounds < 3) {
      const toolBlocks = response.content.filter(
        (b): b is Anthropic.ToolUseBlock => b.type === "tool_use"
      );

      const toolResults: Anthropic.ToolResultBlockParam[] = [];
      for (const tool of toolBlocks) {
        const result = await executeTool(app, uid, tool.name, tool.input as Record<string, unknown>);
        toolResults.push({
          type: "tool_result",
          tool_use_id: tool.id,
          content: JSON.stringify(result),
        });
      }

      messages.push({ role: "assistant", content: response.content });
      messages.push({ role: "user", content: toolResults });

      response = await client.messages.create({
        model: env.CLAUDE_MODEL,
        max_tokens: 1024,
        system: SYSTEM_PROMPT,
        tools: TOOLS,
        messages,
      });
      rounds++;
    }

    const textBlock = response.content.find(
      (b): b is Anthropic.TextBlock => b.type === "text"
    );

    return reply.send({
      reply: textBlock?.text ?? "I couldn't process that request.",
      timestamp: new Date().toISOString(),
    });
  });
}

async function executeTool(
  app: FastifyInstance,
  uid: string,
  toolName: string,
  input: Record<string, unknown>
): Promise<unknown> {
  const userResult = await app.db.query(
    "SELECT id FROM users WHERE firebase_uid = $1", [uid]
  );
  if (userResult.rows.length === 0) return { error: "User not found" };
  const userId = userResult.rows[0].id;

  switch (toolName) {
    case "get_renewals": {
      const r = await app.db.query(
        `SELECT name, category, provider, amount, renewal_date, frequency, status
         FROM renewals WHERE user_id = $1 AND status = 'active'
         ORDER BY renewal_date ASC LIMIT 20`,
        [userId]
      );
      return r.rows;
    }
    case "get_payments": {
      const renewalId = input.renewal_id as string | undefined;
      if (renewalId) {
        const r = await app.db.query(
          `SELECT p.amount, p.paid_date, p.method, r.name AS renewal_name
           FROM payments p JOIN renewals r ON r.id = p.renewal_id
           WHERE p.user_id = $1 AND p.renewal_id = $2
           ORDER BY p.paid_date DESC LIMIT 20`,
          [userId, renewalId]
        );
        return r.rows;
      }
      const r = await app.db.query(
        `SELECT p.amount, p.paid_date, p.method, r.name AS renewal_name
         FROM payments p JOIN renewals r ON r.id = p.renewal_id
         WHERE p.user_id = $1 ORDER BY p.paid_date DESC LIMIT 20`,
        [userId]
      );
      return r.rows;
    }
    case "get_spending_by_category": {
      const r = await app.db.query(
        `SELECT r.category, COUNT(p.id)::int AS count,
                SUM(p.amount)::numeric AS total
         FROM payments p JOIN renewals r ON r.id = p.renewal_id
         WHERE p.user_id = $1 GROUP BY r.category ORDER BY total DESC`,
        [userId]
      );
      return r.rows;
    }
    case "get_spending_by_month": {
      const r = await app.db.query(
        `SELECT TO_CHAR(p.paid_date, 'YYYY-MM') AS month,
                SUM(p.amount)::numeric AS total
         FROM payments p WHERE p.user_id = $1
           AND p.paid_date >= CURRENT_DATE - INTERVAL '12 months'
         GROUP BY month ORDER BY month DESC`,
        [userId]
      );
      return r.rows;
    }
    default:
      return { error: `Unknown tool: ${toolName}` };
  }
}
