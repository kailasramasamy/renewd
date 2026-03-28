import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { NotFoundError, ValidationError } from "../../lib/errors.js";

const auth = { preHandler: authMiddleware };

async function registerCreate(app: FastifyInstance) {
  app.post("/", auth, async (request, reply) => {
    const body = request.body as Record<string, unknown>;
    const { renewal_id, amount, paid_date, method, reference_number, receipt_document_id } = body;

    if (!renewal_id || !amount || !paid_date) {
      throw new ValidationError("renewal_id, amount, and paid_date are required");
    }

    // Verify renewal ownership
    const renewal = await app.db.query(
      "SELECT id FROM renewals WHERE id = $1 AND user_id = (SELECT id FROM users WHERE firebase_uid = $2)",
      [renewal_id, request.user.uid]
    );
    if (renewal.rows.length === 0) throw new NotFoundError("Renewal");

    const userId = await getUserId(app, request.user.uid);
    const result = await app.db.query(
      `INSERT INTO payments (user_id, renewal_id, amount, paid_date, method, reference_number, receipt_document_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [userId, renewal_id, amount, paid_date, method ?? null, reference_number ?? null, receipt_document_id ?? null]
    );

    return reply.status(201).send({ payment: result.rows[0] });
  });
}

async function registerQueries(app: FastifyInstance) {
  app.get("/by-renewal/:renewalId", auth, async (request, reply) => {
    const { renewalId } = request.params as { renewalId: string };
    const result = await app.db.query(
      `SELECT p.* FROM payments p
       JOIN users u ON u.id = p.user_id
       WHERE p.renewal_id = $1 AND u.firebase_uid = $2
       ORDER BY p.paid_date DESC`,
      [renewalId, request.user.uid]
    );
    return reply.send({ payments: result.rows, total: result.rowCount });
  });

  app.get("/", auth, async (request, reply) => {
    const result = await app.db.query(
      `SELECT p.*, r.name AS renewal_name FROM payments p
       JOIN users u ON u.id = p.user_id
       JOIN renewals r ON r.id = p.renewal_id
       WHERE u.firebase_uid = $1
       ORDER BY p.paid_date DESC LIMIT 50`,
      [request.user.uid]
    );
    return reply.send({ payments: result.rows, total: result.rowCount });
  });
}

async function registerDelete(app: FastifyInstance) {
  app.delete("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await app.db.query(
      "DELETE FROM payments WHERE id = $1 AND user_id = (SELECT id FROM users WHERE firebase_uid = $2) RETURNING id",
      [id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Payment");
    return reply.send({ deleted: true, id: result.rows[0].id });
  });
}

async function registerAnalytics(app: FastifyInstance) {
  app.get("/analytics/by-category", auth, async (request, reply) => {
    const result = await app.db.query(
      `SELECT r.category, COUNT(p.id)::int AS payment_count,
              SUM(p.amount)::numeric AS total_spent
       FROM payments p
       JOIN renewals r ON r.id = p.renewal_id
       JOIN users u ON u.id = p.user_id
       WHERE u.firebase_uid = $1
       GROUP BY r.category ORDER BY total_spent DESC`,
      [request.user.uid]
    );
    return reply.send({ analytics: result.rows });
  });

  app.get("/analytics/by-month", auth, async (request, reply) => {
    const result = await app.db.query(
      `SELECT TO_CHAR(p.paid_date, 'YYYY-MM') AS month,
              COUNT(p.id)::int AS payment_count,
              SUM(p.amount)::numeric AS total_spent
       FROM payments p
       JOIN users u ON u.id = p.user_id
       WHERE u.firebase_uid = $1
         AND p.paid_date >= CURRENT_DATE - INTERVAL '12 months'
       GROUP BY month ORDER BY month DESC`,
      [request.user.uid]
    );
    return reply.send({ analytics: result.rows });
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

export default async function paymentRoutes(app: FastifyInstance) {
  await registerCreate(app);
  await registerQueries(app);
  await registerDelete(app);
  await registerAnalytics(app);
}
