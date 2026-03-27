import Anthropic from "@anthropic-ai/sdk";
import { env } from "../config/env.js";
import { AppError } from "../lib/errors.js";

const client = new Anthropic({ apiKey: env.CLAUDE_API_KEY });

const SYSTEM_PROMPT = `You are a helpful assistant for the Renewd app — a personal renewal and subscription tracking tool.
Help users manage their renewals, understand due dates, and get reminders. Be concise and practical.`;

const EXTRACTION_PROMPT = `Analyze this document and extract the following information. Return ONLY valid JSON, no other text:
{
  "summary": "2-3 sentence summary of what this document is",
  "provider": "company/organization name or null",
  "document_type": "policy/receipt/certificate/invoice/id/other",
  "issue_date": "YYYY-MM-DD or null",
  "expiry_date": "YYYY-MM-DD or null",
  "amount": number or null,
  "key_details": ["list of important details like policy number, coverage amount, terms"]
}`;

export async function chat(message: string, context?: string): Promise<string> {
  const userContent = context ? `Context:\n${context}\n\nUser: ${message}` : message;

  try {
    const response = await client.messages.create({
      model: env.CLAUDE_MODEL,
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

function parseJsonResponse(text: string): Record<string, unknown> {
  let cleaned = text.trim();
  // Strip markdown code blocks if present
  if (cleaned.startsWith("```")) {
    cleaned = cleaned.replace(/^```(?:json)?\s*\n?/, "").replace(/\n?```\s*$/, "");
  }
  return JSON.parse(cleaned) as Record<string, unknown>;
}

export async function extractDocumentData(
  fileBuffer: Buffer,
  mimeType: string,
  fileName: string
): Promise<Record<string, unknown>> {
  const isImage = mimeType.startsWith("image/");

  if (!isImage) {
    return {
      summary: `Document: ${fileName}`,
      document_type: "other",
      provider: null,
      issue_date: null,
      expiry_date: null,
      amount: null,
      key_details: [],
    };
  }

  const base64 = fileBuffer.toString("base64");
  const mediaType = mimeType as "image/jpeg" | "image/png" | "image/gif" | "image/webp";

  try {
    const response = await client.messages.create({
      model: env.CLAUDE_MODEL,
      max_tokens: 1024,
      messages: [
        {
          role: "user",
          content: [
            { type: "image", source: { type: "base64", media_type: mediaType, data: base64 } },
            { type: "text", text: EXTRACTION_PROMPT },
          ],
        },
      ],
    });

    const block = response.content[0];
    if (block.type !== "text") {
      throw new AppError("Unexpected AI response type", 502, "AI_ERROR");
    }

    return parseJsonResponse(block.text);
  } catch (err) {
    if (err instanceof AppError) throw err;
    if (err instanceof SyntaxError) {
      throw new AppError("AI returned invalid JSON", 502, "AI_PARSE_ERROR");
    }
    if (err instanceof Anthropic.APIError) {
      throw new AppError(`AI service error: ${err.message}`, 502, "AI_ERROR");
    }
    throw new AppError("Failed to extract document data", 502, "AI_ERROR");
  }
}
