import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { NotFoundError } from "../../lib/errors.js";
import { createRemindersForDays, deleteUnsentReminders } from "./helpers.js";

const auth = { preHandler: authMiddleware };

export async function registerReminderRoutes(app: FastifyInstance) {
  app.get("/:id/reminders", auth, async (request, reply) => {
    const { id } = request.params as { id: string };

    const result = await app.db.query(
      `SELECT r.* FROM reminders r
       JOIN renewals ren ON ren.id = r.renewal_id
       JOIN users u ON u.id = ren.user_id
       WHERE r.renewal_id = $1 AND u.firebase_uid = $2
       ORDER BY r.days_before DESC`,
      [id, request.user.uid]
    );

    return reply.send({ reminders: result.rows });
  });

  app.put("/:id/reminders", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { days_before } = request.body as { days_before: number[] };

    const renewal = await app.db.query(
      `SELECT r.id, r.renewal_date, r.user_id FROM renewals r
       JOIN users u ON u.id = r.user_id
       WHERE r.id = $1 AND u.firebase_uid = $2`,
      [id, request.user.uid]
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

    const result = await app.db.query(
      `UPDATE reminders SET snoozed_until = CURRENT_DATE + ($1 || ' days')::interval, is_sent = FALSE, sent_at = NULL
       WHERE id = $2 AND renewal_id = $3
         AND user_id = (SELECT id FROM users WHERE firebase_uid = $4)
       RETURNING *`,
      [snooze_days ?? 1, reminderId, id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Reminder");

    return reply.send({ reminder: result.rows[0] });
  });
}
