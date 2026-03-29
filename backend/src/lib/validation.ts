import { ValidationError } from "./errors.js";

/** Validate a string field: non-empty and within length bounds */
export function validateString(
  value: unknown,
  fieldName: string,
  opts: { required?: boolean; minLen?: number; maxLen?: number } = {}
): string | null {
  const { required = false, minLen = 0, maxLen = 500 } = opts;

  if (value === undefined || value === null || value === "") {
    if (required) throw new ValidationError(`${fieldName} is required`);
    return null;
  }

  if (typeof value !== "string") {
    throw new ValidationError(`${fieldName} must be a string`);
  }

  const trimmed = value.trim();
  if (required && trimmed.length === 0) {
    throw new ValidationError(`${fieldName} is required`);
  }
  if (trimmed.length < minLen) {
    throw new ValidationError(`${fieldName} must be at least ${minLen} characters`);
  }
  if (trimmed.length > maxLen) {
    throw new ValidationError(`${fieldName} must be at most ${maxLen} characters`);
  }

  return trimmed;
}

/** Validate an email address */
export function validateEmail(value: unknown, required = false): string | null {
  const str = validateString(value, "email", { required, maxLen: 254 });
  if (str === null) return null;
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(str)) {
    throw new ValidationError("Invalid email address");
  }
  return str;
}

/** Validate a phone number (international format) */
export function validatePhone(value: unknown, required = false): string | null {
  const str = validateString(value, "phone", { required, maxLen: 20 });
  if (str === null) return null;
  if (!/^\+?[0-9\-() ]{6,20}$/.test(str)) {
    throw new ValidationError("Invalid phone number");
  }
  return str;
}

/** Validate a positive number */
export function validateNumber(
  value: unknown,
  fieldName: string,
  opts: { required?: boolean; min?: number; max?: number } = {}
): number | null {
  const { required = false, min, max } = opts;

  if (value === undefined || value === null || value === "") {
    if (required) throw new ValidationError(`${fieldName} is required`);
    return null;
  }

  const num = typeof value === "number" ? value : Number(value);
  if (isNaN(num)) throw new ValidationError(`${fieldName} must be a number`);
  if (min !== undefined && num < min) {
    throw new ValidationError(`${fieldName} must be at least ${min}`);
  }
  if (max !== undefined && num > max) {
    throw new ValidationError(`${fieldName} must be at most ${max}`);
  }

  return num;
}
