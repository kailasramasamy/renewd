import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { AppError } from "../../lib/errors.js";

export default async function authRoutes(app: FastifyInstance) {
  app.post("/register", { preHandler: authMiddleware }, async (request, reply) => {
    const { uid, email } = request.user;

    const existing = await app.db.query(
      "SELECT id FROM users WHERE firebase_uid = $1",
      [uid]
    );

    if (existing.rows.length > 0) {
      return reply.status(409).send({ error: "User already registered", code: "USER_EXISTS" });
    }

    try {
      const result = await app.db.query(
        `INSERT INTO users (firebase_uid, email) VALUES ($1, $2) RETURNING *`,
        [uid, email ?? null]
      );
      return reply.status(201).send({ user: result.rows[0] });
    } catch (err) {
      if (err instanceof Error && err.message.includes("unique")) {
        return reply.status(409).send({ error: "User already registered", code: "USER_EXISTS" });
      }
      throw new AppError("Failed to create user", 500, "DB_ERROR");
    }
  });
}
