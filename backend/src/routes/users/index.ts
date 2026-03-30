import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { NotFoundError, ValidationError } from "../../lib/errors.js";

export default async function userRoutes(app: FastifyInstance) {
  const auth = { preHandler: authMiddleware };

  app.get("/me", auth, async (request, reply) => {
    const result = await app.db.query(
      "SELECT * FROM users WHERE firebase_uid = $1",
      [request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("User");

    const user = result.rows[0];

    // Auto-expire premium if past expiry
    if (user.is_premium && user.premium_expires_at && new Date(user.premium_expires_at) < new Date()) {
      await app.db.query("UPDATE users SET is_premium = FALSE WHERE id = $1", [user.id]);
      user.is_premium = false;
    }

    const countResult = await app.db.query(
      "SELECT COUNT(*)::int AS count FROM renewals WHERE user_id = $1",
      [user.id]
    );
    const limitResult = await app.db.query(
      "SELECT value FROM app_config WHERE key = 'free_renewal_limit'"
    );
    const renewalLimit = user.is_premium
      ? null
      : parseInt(limitResult.rows[0]?.value ?? "5", 10);

    return reply.send({
      user,
      plan: {
        is_premium: user.is_premium,
        expires_at: user.premium_expires_at,
        renewal_limit: renewalLimit,
        renewal_count: countResult.rows[0].count,
      },
    });
  });

  const updateUser = async (request: any, reply: any) => {
    const body = request.body as Record<string, unknown>;
    const { name, phone, email, avatar_url, default_currency, country, device_os, device_model, app_version } = body;

    const result = await app.db.query(
      `UPDATE users SET
        name = COALESCE($1, name),
        phone = COALESCE($2, phone),
        email = COALESCE($3, email),
        avatar_url = COALESCE($4, avatar_url),
        default_currency = COALESCE($5, default_currency),
        country = COALESCE($6, country),
        device_os = COALESCE($7, device_os),
        device_model = COALESCE($8, device_model),
        app_version = COALESCE($9, app_version),
        updated_at = NOW()
       WHERE firebase_uid = $10 RETURNING *`,
      [name ?? null, phone ?? null, email ?? null, avatar_url ?? null, default_currency ?? null, country ?? null, device_os ?? null, device_model ?? null, app_version ?? null, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("User");
    return reply.send({ user: result.rows[0] });
  };

  app.patch("/me", auth, updateUser);
  app.put("/me", auth, updateUser);

  app.delete("/me", auth, async (request, reply) => {
    const userResult = await app.db.query(
      "SELECT id FROM users WHERE firebase_uid = $1",
      [request.user.uid]
    );
    if (userResult.rows.length === 0) throw new NotFoundError("User");
    const userId = userResult.rows[0].id;

    const client = await app.db.connect();
    try {
      await client.query("BEGIN");
      await client.query("DELETE FROM chat_usage WHERE user_id = $1", [userId]);
      await client.query("DELETE FROM payments WHERE user_id = $1", [userId]);
      await client.query("DELETE FROM documents WHERE user_id = $1", [userId]);
      await client.query(
        "DELETE FROM reminders WHERE renewal_id IN (SELECT id FROM renewals WHERE user_id = $1)",
        [userId]
      );
      await client.query("DELETE FROM renewals WHERE user_id = $1", [userId]);
      await client.query("DELETE FROM notification_log WHERE user_id = $1", [userId]);
      await client.query("DELETE FROM notification_preferences WHERE user_id = $1", [userId]);
      await client.query("DELETE FROM support_tickets WHERE user_id = $1", [userId]);
      await client.query("DELETE FROM users WHERE id = $1", [userId]);
      await client.query("COMMIT");
    } catch (err) {
      await client.query("ROLLBACK").catch(() => {});
      throw err;
    } finally {
      client.release();
    }

    return reply.send({ deleted: true });
  });

  await registerFcmToken(app);
  await registerNotificationPreferences(app);
}

async function registerFcmToken(app: FastifyInstance) {
  const auth = { preHandler: authMiddleware };

  app.put("/me/fcm-token", auth, async (request, reply) => {
    const body = request.body as Record<string, unknown>;
    const { fcm_token, device_os, device_os_version, device_model, app_version } = body;
    if (!fcm_token || typeof fcm_token !== "string") {
      throw new ValidationError("fcm_token is required");
    }

    const result = await app.db.query(
      `UPDATE users SET fcm_token = $1, fcm_token_updated_at = NOW(),
         device_os = COALESCE($3, device_os),
         device_os_version = COALESCE($4, device_os_version),
         device_model = COALESCE($5, device_model),
         app_version = COALESCE($6, app_version)
       WHERE firebase_uid = $2 RETURNING id`,
      [fcm_token, request.user.uid, device_os ?? null, device_os_version ?? null, device_model ?? null, app_version ?? null]
    );
    if (result.rows.length === 0) throw new NotFoundError("User");

    // Ensure notification_preferences row exists
    await app.db.query(
      `INSERT INTO notification_preferences (user_id)
       VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
      [result.rows[0].id]
    );

    return reply.send({ success: true });
  });
}

async function registerNotificationPreferences(app: FastifyInstance) {
  const auth = { preHandler: authMiddleware };

  app.get("/me/notification-preferences", auth, async (request, reply) => {
    const result = await app.db.query(
      `SELECT np.* FROM notification_preferences np
       JOIN users u ON u.id = np.user_id
       WHERE u.firebase_uid = $1`,
      [request.user.uid]
    );

    const defaults = {
      enabled: true,
      default_days_before: [7, 1],
      daily_digest_enabled: false,
      daily_digest_hour: 9,
      quiet_hours_start: null,
      quiet_hours_end: null,
    };

    return reply.send({ preferences: result.rows[0] ?? defaults });
  });

  app.put("/me/notification-preferences", auth, async (request, reply) => {
    const body = request.body as Record<string, unknown>;
    const userId = await getUserId(app, request.user.uid);

    const result = await app.db.query(
      `INSERT INTO notification_preferences (user_id, enabled, default_days_before,
         daily_digest_enabled, daily_digest_hour, quiet_hours_start, quiet_hours_end)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT (user_id) DO UPDATE SET
         enabled = COALESCE($2, notification_preferences.enabled),
         default_days_before = COALESCE($3, notification_preferences.default_days_before),
         daily_digest_enabled = COALESCE($4, notification_preferences.daily_digest_enabled),
         daily_digest_hour = COALESCE($5, notification_preferences.daily_digest_hour),
         quiet_hours_start = $6,
         quiet_hours_end = $7,
         updated_at = NOW()
       RETURNING *`,
      [
        userId,
        body.enabled ?? true,
        body.default_days_before ?? [7, 1],
        body.daily_digest_enabled ?? false,
        body.daily_digest_hour ?? 9,
        body.quiet_hours_start ?? null,
        body.quiet_hours_end ?? null,
      ]
    );

    return reply.send({ preferences: result.rows[0] });
  });
}

async function getUserId(app: FastifyInstance, firebaseUid: string): Promise<string> {
  const result = await app.db.query(
    "SELECT id FROM users WHERE firebase_uid = $1",
    [firebaseUid]
  );
  if (result.rows.length === 0) throw new NotFoundError("User");
  return result.rows[0].id;
}
