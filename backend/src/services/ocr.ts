import { env } from "../config/env.js";
import { AppError } from "../lib/errors.js";

interface OcrResult {
  text: string;
  confidence: number;
}

export async function extractTextFromImage(imageUrl: string): Promise<OcrResult> {
  if (!env.GOOGLE_VISION_KEY) {
    throw new AppError("Google Vision API key not configured", 503, "OCR_UNAVAILABLE");
  }

  const endpoint = `https://vision.googleapis.com/v1/images:annotate?key=${env.GOOGLE_VISION_KEY}`;
  const body = {
    requests: [
      {
        image: { source: { imageUri: imageUrl } },
        features: [{ type: "TEXT_DETECTION" }],
      },
    ],
  };

  const response = await fetch(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    throw new AppError(`Google Vision API error: ${response.statusText}`, 502, "OCR_ERROR");
  }

  const data = await response.json() as { responses: Array<{ fullTextAnnotation?: { text: string } }> };
  const text = data.responses[0]?.fullTextAnnotation?.text ?? "";

  return { text, confidence: text.length > 0 ? 1 : 0 };
}
