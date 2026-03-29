import type { FastifyRequest, FastifyReply } from "fastify";
import type { FastifyInstance } from "fastify";
import { getConfigValue } from "../lib/config-cache.js";

declare module "fastify" {
  interface FastifyRequest {
    premium: { isPremium: boolean };
  }
}

export function createPremiumMiddleware(app: FastifyInstance) {
  return async function premiumMiddleware(
    request: FastifyRequest,
    _reply: FastifyReply
  ): Promise<void> {
    // Atomic: expire and return status in a single query
    const result = await app.db.query(
      `UPDATE users
       SET is_premium = CASE
         WHEN premium_expires_at IS NOT NULL AND premium_expires_at < NOW() THEN FALSE
         ELSE is_premium
       END
       WHERE firebase_uid = $1
       RETURNING is_premium`,
      [request.user.uid]
    );

    if (result.rows.length === 0) {
      request.premium = { isPremium: false };
      return;
    }

    request.premium = { isPremium: !!result.rows[0].is_premium };
  };
}

export function createRequirePremium(app: FastifyInstance, featureKey?: string) {
  const premiumMiddleware = createPremiumMiddleware(app);

  return async function requirePremium(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    // Check if feature is open to all via app_config (cached in Redis)
    if (featureKey) {
      const featureAccess = await getConfigValue(app, `feature_${featureKey}`);
      if (featureAccess === "all") return;
      if (featureAccess === "none") {
        reply.status(403).send({
          error: "This feature is currently disabled",
          code: "FEATURE_DISABLED",
        });
        return;
      }
    }

    await premiumMiddleware(request, reply);

    if (!request.premium.isPremium) {
      reply.status(403).send({
        error: "Premium subscription required",
        code: "PREMIUM_REQUIRED",
      });
    }
  };
}
