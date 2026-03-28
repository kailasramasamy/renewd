import Anthropic from "@anthropic-ai/sdk";
import { env } from "../config/env.js";
import { AppError } from "../lib/errors.js";

const client = new Anthropic({ apiKey: env.CLAUDE_API_KEY });

const SYSTEM_PROMPT = `You are a helpful assistant for the Renewd app — a personal renewal and subscription tracking tool.
Help users manage their renewals, understand due dates, and get reminders. Be concise and practical.`;

const EXTRACTION_PROMPT = `Analyze this document image. This is for a renewal/subscription tracking app called Renewd.

If this is a relevant document (insurance policy, bill, invoice, receipt, certificate, license, subscription confirmation, ID card, or government document), extract the details below.

If this is NOT a relevant document (random photo, screenshot, meme, selfie, etc.), set is_relevant to false and explain why in the summary.

Return ONLY valid JSON, no other text:
{
  "is_relevant": true or false,
  "summary": "2-3 sentence summary. If not relevant, explain what the document actually is and suggest what types of documents to upload instead",
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
  const isPdf = mimeType === "application/pdf";

  if (!isImage && !isPdf) {
    return {
      is_relevant: false,
      summary: `Unsupported file type: ${fileName}. Upload an image or PDF.`,
      document_type: "other",
      provider: null,
      issue_date: null,
      expiry_date: null,
      amount: null,
      key_details: [],
    };
  }

  const base64 = fileBuffer.toString("base64");

  const contentBlock = isPdf
    ? { type: "document" as const, source: { type: "base64" as const, media_type: "application/pdf" as const, data: base64 } }
    : { type: "image" as const, source: { type: "base64" as const, media_type: mimeType as "image/jpeg" | "image/png" | "image/gif" | "image/webp", data: base64 } };

  try {
    const response = await client.messages.create({
      model: env.CLAUDE_MODEL,
      max_tokens: 1024,
      messages: [
        {
          role: "user",
          content: [
            contentBlock,
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
