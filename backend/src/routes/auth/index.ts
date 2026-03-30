import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { AppError } from "../../lib/errors.js";
import { getConfigValue } from "../../lib/config-cache.js";

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

    // Check if new users get a premium trial
    const trialDaysStr = await getConfigValue(app, "new_user_trial_days");
    const trialDays = parseInt(trialDaysStr ?? "0", 10);

    const isPremium = trialDays !== 0;
    // -1 = lifetime (no expiry), positive = days from now
    const expiresAt = trialDays === -1
      ? null
      : trialDays > 0
        ? new Date(Date.now() + trialDays * 86400000).toISOString()
        : null;

    try {
      const result = await app.db.query(
        `INSERT INTO users (firebase_uid, email, is_premium, premium_expires_at)
         VALUES ($1, $2, $3, $4) RETURNING *`,
        [uid, email ?? null, isPremium, expiresAt]
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
