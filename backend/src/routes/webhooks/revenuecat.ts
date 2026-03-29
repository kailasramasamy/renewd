import { timingSafeEqual } from "node:crypto";
import type { FastifyInstance } from "fastify";
import { AppError } from "../../lib/errors.js";
import { env } from "../../config/env.js";

interface WebhookEvent {
  event: {
    type: string;
    app_user_id: string;
    expiration_at_ms?: number;
    product_id?: string;
  };
}

export default async function revenueCatWebhookRoutes(app: FastifyInstance) {
  app.post("/revenuecat", async (request, reply) => {
    // Verify webhook secret
    const secret = env.REVENUECAT_WEBHOOK_SECRET;
    if (!secret) {
      app.log.error("REVENUECAT_WEBHOOK_SECRET is not configured");
      throw new AppError("Webhook not configured", 500, "WEBHOOK_NOT_CONFIGURED");
    }

    const authHeader = request.headers.authorization;
    if (!authHeader) {
      throw new AppError("Missing Authorization header", 401, "UNAUTHORIZED");
    }

    const expected = Buffer.from(`Bearer ${secret}`);
    const actual = Buffer.from(authHeader);
    if (expected.length !== actual.length || !timingSafeEqual(expected, actual)) {
      throw new AppError("Unauthorized", 401, "UNAUTHORIZED");
    }

    const body = request.body as WebhookEvent;
    const { type, app_user_id, expiration_at_ms } = body.event;

    const userResult = await app.db.query(
      "SELECT id FROM users WHERE firebase_uid = $1",
      [app_user_id]
    );

    if (userResult.rows.length === 0) {
      app.log.warn({ app_user_id, type }, "Webhook user not found");
      return reply.send({ success: true });
    }

    const userId = userResult.rows[0].id;

    switch (type) {
      case "INITIAL_PURCHASE":
      case "RENEWAL":
      case "NON_RENEWING_PURCHASE":
        await activatePremium(app, userId, expiration_at_ms);
        break;
      case "EXPIRATION":
      case "BILLING_ISSUE":
        await deactivatePremium(app, userId);
        break;
      case "CANCELLATION":
        // Keep premium until expiry — user already paid for the period
        break;
      default:
        app.log.info({ type, app_user_id }, "Unhandled webhook event");
    }

    return reply.send({ success: true });
  });
}

async function activatePremium(
  app: FastifyInstance,
  userId: string,
  expirationMs?: number
) {
  const expiresAt = expirationMs
    ? new Date(expirationMs).toISOString()
    : null;

  await app.db.query(
    "UPDATE users SET is_premium = TRUE, premium_expires_at = $1, updated_at = NOW() WHERE id = $2",
    [expiresAt, userId]
  );
}

async function deactivatePremium(app: FastifyInstance, userId: string) {
  await app.db.query(
    "UPDATE users SET is_premium = FALSE, updated_at = NOW() WHERE id = $1",
    [userId]
  );
}
