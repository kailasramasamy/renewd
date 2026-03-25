import Anthropic from "@anthropic-ai/sdk";
import { env } from "../config/env.js";
import { AppError } from "../lib/errors.js";

const client = new Anthropic({ apiKey: env.CLAUDE_API_KEY });

const SYSTEM_PROMPT = `You are a helpful assistant for the Minder app — a personal renewal and subscription tracking tool.
Help users manage their renewals, understand due dates, and get reminders. Be concise and practical.`;

export async function chat(message: string, context?: string): Promise<string> {
  const userContent = context ? `Context:\n${context}\n\nUser: ${message}` : message;

  try {
    const response = await client.messages.create({
      model: "claude-3-5-haiku-20241022",
      max_tokens: 1024,
      system: SYSTEM_PROMPT,
      messages: [{ role: "user", content: userContent }],
    });

    const block = response.content[0];
    if (block.type !== "text") {
      throw new AppError("Unexpected response type from AI", 502, "AI_ERROR");
    }

    return block.text;
  } catch (err) {
    if (err instanceof AppError) throw err;
    if (err instanceof Anthropic.APIError) {
      throw new AppError(`AI service error: ${err.message}`, 502, "AI_ERROR");
    }
    throw new AppError("Failed to get AI response", 502, "AI_ERROR");
  }
}
