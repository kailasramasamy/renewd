import type { FastifyRequest, FastifyReply } from "fastify";
import type { FastifyInstance } from "fastify";

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
    const result = await app.db.query(
      "SELECT is_premium, premium_expires_at FROM users WHERE firebase_uid = $1",
      [request.user.uid]
    );

    if (result.rows.length === 0) {
      request.premium = { isPremium: false };
      return;
    }

    const { is_premium, premium_expires_at } = result.rows[0];

    // Auto-expire if past expiry date
    if (is_premium && premium_expires_at && new Date(premium_expires_at) < new Date()) {
      await app.db.query(
        "UPDATE users SET is_premium = FALSE WHERE firebase_uid = $1",
        [request.user.uid]
      );
      request.premium = { isPremium: false };
      return;
    }

    request.premium = { isPremium: !!is_premium };
  };
}

export function createRequirePremium(app: FastifyInstance, featureKey?: string) {
  const premiumMiddleware = createPremiumMiddleware(app);

  return async function requirePremium(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    // Check if feature is open to all via app_config
    if (featureKey) {
      const configResult = await app.db.query(
        "SELECT value FROM app_config WHERE key = $1",
        [`feature_${featureKey}`]
      );
      if (configResult.rows[0]?.value === "all") return;
      if (configResult.rows[0]?.value === "none") {
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
