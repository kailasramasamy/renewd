// Aadhaar: 12 digits, often formatted as XXXX XXXX XXXX
const AADHAAR_PATTERN = /\b(\d{4})\s*(\d{4})\s*(\d{4})\b/g;

// PAN: 5 letters + 4 digits + 1 letter (e.g., ABCDE1234F)
const PAN_PATTERN = /\b([A-Z]{5})(\d{4})([A-Z])\b/g;

export function maskSensitiveData(text: string): string {
  let masked = text;

  // Mask Aadhaar — keep last 4 digits
  masked = masked.replace(AADHAAR_PATTERN, "XXXX XXXX $3");

  // Mask PAN — keep last 4 characters
  masked = masked.replace(PAN_PATTERN, "XXXXX$2$3");

  return masked;
}

export function maskExtractionJson(extraction: Record<string, unknown>): Record<string, unknown> {
  const result = { ...extraction };

  if (typeof result.summary === "string") {
    result.summary = maskSensitiveData(result.summary);
  }

  if (Array.isArray(result.key_details)) {
    result.key_details = result.key_details.map((detail) =>
      typeof detail === "string" ? maskSensitiveData(detail) : detail
    );
  }

  return result;
}
