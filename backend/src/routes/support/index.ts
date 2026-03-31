import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { NotFoundError, ValidationError } from "../../lib/errors.js";
import { getUserId } from "../../lib/user-context.js";

const auth = { preHandler: authMiddleware };

export default async function supportRoutes(app: FastifyInstance) {
  // Public: account deletion request (no auth — for users who can't access the app)
  app.post("/delete-request", async (request, reply) => {
    const { contact, reason } = request.body as Record<string, unknown>;

    if (!contact || typeof contact !== "string" || contact.trim().length === 0) {
      throw new ValidationError("Email or phone number is required");
    }

    await app.db.query(
      `INSERT INTO support_tickets (type, subject, description)
       VALUES ('account_deletion', 'Account Deletion Request', $1)`,
      [`Contact: ${contact.trim()}\nReason: ${reason ?? "Not provided"}`]
    );

    return reply.send({ success: true });
  });

  // Create ticket
  app.post("/", auth, async (request, reply) => {
    const body = request.body as Record<string, unknown>;
    const { type, subject, description, device_info } = body;

    if (!subject || !description) {
      throw new ValidationError("subject and description are required");
    }

    const userId = await getUserId(app, request.user.uid);

    const result = await app.db.query(
      `INSERT INTO support_tickets (user_id, type, subject, description, device_info)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [userId, type ?? "feedback", subject, description, device_info ?? null]
    );

    return reply.send({ ticket: result.rows[0] });
  });

  // List user's tickets
  app.get("/", auth, async (request, reply) => {
    const userId = await getUserId(app, request.user.uid);
    const result = await app.db.query(
      `SELECT t.id, t.user_id, t.type, t.subject, t.description, t.status, t.device_info,
              t.created_at::text, t.updated_at::text,
        (SELECT COUNT(*)::int FROM ticket_replies r WHERE r.ticket_id = t.id AND r.sender = 'admin') AS admin_replies
       FROM support_tickets t
       WHERE t.user_id = $1
       ORDER BY t.updated_at DESC`,
      [userId]
    );
    return reply.send({ tickets: result.rows });
  });

  // Get single ticket with replies
  app.get("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = await getUserId(app, request.user.uid);

    const ticket = await app.db.query(
      `SELECT t.id, t.user_id, t.type, t.subject, t.description, t.status, t.device_info,
              t.created_at::text, t.updated_at::text
       FROM support_tickets t
       WHERE t.id = $1 AND t.user_id = $2`,
      [id, userId]
    );
    if (ticket.rows.length === 0) throw new NotFoundError("Ticket");

    const replies = await app.db.query(
      "SELECT id, ticket_id, sender, message, created_at::text FROM ticket_replies WHERE ticket_id = $1 ORDER BY created_at ASC",
      [id]
    );

    return reply.send({
      ticket: ticket.rows[0],
      replies: replies.rows,
    });
  });

  // User adds reply to ticket
  app.post("/:id/reply", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { message } = request.body as { message: string };

    if (!message) throw new ValidationError("message is required");

    // Verify ownership
    const userId = await getUserId(app, request.user.uid);
    const ticket = await app.db.query(
      "SELECT id FROM support_tickets WHERE id = $1 AND user_id = $2",
      [id, userId]
    );
    if (ticket.rows.length === 0) throw new NotFoundError("Ticket");

    const result = await app.db.query(
      "INSERT INTO ticket_replies (ticket_id, sender, message) VALUES ($1, 'user', $2) RETURNING *",
      [id, message]
    );

    await app.db.query(
      "UPDATE support_tickets SET updated_at = NOW() WHERE id = $1",
      [id]
    );

    return reply.send({ reply: result.rows[0] });
  });
}
