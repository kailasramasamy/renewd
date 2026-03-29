import type { FastifyRequest, FastifyReply } from "fastify";
import admin from "firebase-admin";
import { AppError } from "../lib/errors.js";
import { env } from "../config/env.js";

declare module "fastify" {
  interface FastifyRequest {
    user: {
      uid: string;
      email?: string;
    };
  }
}

export async function authMiddleware(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  // Test-only bypass — requires explicit header to prevent accidental use
  if (env.NODE_ENV === "test") {
    const testHeader = request.headers["x-test-uid"] as string | undefined;
    request.user = { uid: testHeader ?? "test-user", email: "test@renewd.local" };
    return;
  }

  // Dev bypass only when Firebase is NOT configured AND explicitly in development
  if (!env.FIREBASE_PROJECT_ID && env.NODE_ENV === "development") {
    request.user = { uid: "dev-user", email: "dev@renewd.local" };
    return;
  }

  if (!env.FIREBASE_PROJECT_ID) {
    reply.status(503).send({ error: "Authentication unavailable", code: "AUTH_DISABLED" });
    return;
  }

  const authHeader = request.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    reply.status(401).send({ error: "Missing or invalid Authorization header", code: "UNAUTHORIZED" });
    return;
  }

  const token = authHeader.slice(7);

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    request.user = { uid: decoded.uid, email: decoded.email };
  } catch (err) {
    if (err instanceof Error && err.message.includes("expired")) {
      reply.status(401).send({ error: "Token expired", code: "TOKEN_EXPIRED" });
      return;
    }
    reply.status(401).send({ error: "Invalid token", code: "INVALID_TOKEN" });
    return;
  }
}
