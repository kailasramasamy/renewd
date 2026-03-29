import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { createPremiumMiddleware } from "../../middleware/premium.js";
import { NotFoundError } from "../../lib/errors.js";
import { getUserId } from "../../lib/user-context.js";
import { createRemindersForDays, deleteUnsentReminders } from "./helpers.js";

const auth = { preHandler: authMiddleware };

export async function registerReminderRoutes(app: FastifyInstance) {
  const premiumMiddleware = createPremiumMiddleware(app);

  app.get("/:id/reminders", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = await getUserId(app, request.user.uid);

    const result = await app.db.query(
      `SELECT * FROM reminders
       WHERE renewal_id = $1 AND user_id = $2
       ORDER BY days_before DESC`,
      [id, userId]
    );

    return reply.send({ reminders: result.rows });
  });

  app.put("/:id/reminders", { preHandler: [authMiddleware, premiumMiddleware] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { days_before } = request.body as { days_before: number[] };

    // Free users can only use free_reminder_days config
    if (!request.premium.isPremium) {
      const configResult = await app.db.query(
        "SELECT value FROM app_config WHERE key = 'free_reminder_days'"
      );
      const allowedDays: number[] = JSON.parse(configResult.rows[0]?.value ?? "[1]");
      const hasDisallowed = days_before.some((d) => !allowedDays.includes(d));
      if (hasDisallowed) {
        return reply.status(403).send({
          error: "Custom reminders require Premium",
          code: "PREMIUM_REQUIRED",
          allowed_days: allowedDays,
        });
      }
    }

    const userId = await getUserId(app, request.user.uid);
    const renewal = await app.db.query(
      "SELECT id, renewal_date, user_id FROM renewals WHERE id = $1 AND user_id = $2",
      [id, userId]
    );
    if (renewal.rows.length === 0) throw new NotFoundError("Renewal");

    const { user_id, renewal_date } = renewal.rows[0];
    await deleteUnsentReminders(app.db, id);
    await createRemindersForDays(app.db, user_id, id, renewal_date, days_before);

    const result = await app.db.query(
      "SELECT * FROM reminders WHERE renewal_id = $1 ORDER BY days_before DESC",
      [id]
    );

    return reply.send({ reminders: result.rows });
  });

  app.post("/:id/reminders/:reminderId/snooze", auth, async (request, reply) => {
    const { id, reminderId } = request.params as { id: string; reminderId: string };
    const { snooze_days } = request.body as { snooze_days?: number };
    const userId = await getUserId(app, request.user.uid);

    const result = await app.db.query(
      `UPDATE reminders SET snoozed_until = CURRENT_DATE + ($1 || ' days')::interval, is_sent = FALSE, sent_at = NULL
       WHERE id = $2 AND renewal_id = $3 AND user_id = $4
       RETURNING *`,
      [snooze_days ?? 1, reminderId, id, userId]
    );
    if (result.rows.length === 0) throw new NotFoundError("Reminder");

    return reply.send({ reminder: result.rows[0] });
  });
}
