import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { NotFoundError } from "../../lib/errors.js";
import { getUserId } from "../../lib/user-context.js";

const auth = { preHandler: authMiddleware };

async function registerList(app: FastifyInstance) {
  app.get("/", auth, async (request, reply) => {
    const userId = await getUserId(app, request.user.uid);
    const result = await app.db.query(
      `SELECT n.*, r.name AS renewal_name FROM notification_log n
       LEFT JOIN renewals r ON r.id = n.renewal_id
       WHERE n.user_id = $1
       ORDER BY n.created_at DESC LIMIT 50`,
      [userId]
    );
    return reply.send({ notifications: result.rows, total: result.rowCount });
  });
}

async function registerUnreadCount(app: FastifyInstance) {
  app.get("/unread-count", auth, async (request, reply) => {
    const userId = await getUserId(app, request.user.uid);
    const result = await app.db.query(
      `SELECT COUNT(*)::int AS count FROM notification_log
       WHERE user_id = $1 AND is_read = FALSE`,
      [userId]
    );
    return reply.send({ count: result.rows[0]?.count ?? 0 });
  });
}

async function registerMarkRead(app: FastifyInstance) {
  app.put("/:id/read", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = await getUserId(app, request.user.uid);
    const result = await app.db.query(
      `UPDATE notification_log SET is_read = TRUE
       WHERE id = $1 AND user_id = $2
       RETURNING id`,
      [id, userId]
    );
    if (result.rows.length === 0) throw new NotFoundError("Notification");
    return reply.send({ success: true });
  });

  app.put("/mark-all-read", auth, async (request, reply) => {
    const userId = await getUserId(app, request.user.uid);
    await app.db.query(
      `UPDATE notification_log SET is_read = TRUE
       WHERE user_id = $1 AND is_read = FALSE`,
      [userId]
    );
    return reply.send({ success: true });
  });
}

export default async function notificationLogRoutes(app: FastifyInstance) {
  await registerList(app);
  await registerUnreadCount(app);
  await registerMarkRead(app);
}
