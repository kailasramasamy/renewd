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
  // Dev bypass only when Firebase is NOT configured (no credentials at all)
  if (!env.FIREBASE_PROJECT_ID) {
    request.user = { uid: "dev-user", email: "dev@renewd.local" };
    return;
  }

  const authHeader = request.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    const err = new AppError("Missing or invalid Authorization header", 401, "UNAUTHORIZED");
    reply.status(401).send({ error: err.message, code: err.code });
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
  }
}
