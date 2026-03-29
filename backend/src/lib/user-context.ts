import type { FastifyInstance } from "fastify";
import { AppError } from "./errors.js";

/**
 * Get the internal user ID from a Firebase UID.
 * Throws 404 if user not found.
 */
export async function getUserId(
  app: FastifyInstance,
  firebaseUid: string
): Promise<string> {
  const result = await app.db.query(
    "SELECT id FROM users WHERE firebase_uid = $1",
    [firebaseUid]
  );
  if (result.rows.length === 0) {
    throw new AppError("User not found", 404, "NOT_FOUND");
  }
  return result.rows[0].id;
}
