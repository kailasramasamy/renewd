import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { AppError, NotFoundError } from "../../lib/errors.js";

const auth = { preHandler: authMiddleware };

async function registerListAndGet(app: FastifyInstance) {
  app.get("/", auth, async (request, reply) => {
    const result = await app.db.query(
      "SELECT * FROM renewals WHERE user_id = (SELECT id FROM users WHERE firebase_uid = $1) ORDER BY renewal_date ASC",
      [request.user.uid]
    );
    return reply.send({ renewals: result.rows, total: result.rowCount });
  });

  app.get("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await app.db.query(
      "SELECT r.* FROM renewals r JOIN users u ON u.id = r.user_id WHERE r.id = $1 AND u.firebase_uid = $2",
      [id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Renewal");
    return reply.send({ renewal: result.rows[0] });
  });
}

async function registerCreate(app: FastifyInstance) {
  app.post("/", auth, async (request, reply) => {
    const body = request.body as Record<string, unknown>;
    const userResult = await app.db.query(
      "SELECT id FROM users WHERE firebase_uid = $1",
      [request.user.uid]
    );
    if (userResult.rows.length === 0) throw new AppError("User not found", 404, "NOT_FOUND");

    const { name, category, provider, amount, renewal_date, frequency, frequency_days, auto_renew, notes } = body;
    const result = await app.db.query(
      `INSERT INTO renewals (user_id, name, category, provider, amount, renewal_date, frequency, frequency_days, auto_renew, notes)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
      [userResult.rows[0].id, name, category, provider ?? null, amount ?? null, renewal_date, frequency, frequency_days ?? null, auto_renew ?? false, notes ?? null]
    );
    return reply.status(201).send({ renewal: result.rows[0] });
  });
}

async function registerUpdateAndDelete(app: FastifyInstance) {
  app.put("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = request.body as Record<string, unknown>;
    const { name, category, provider, amount, renewal_date, frequency, frequency_days, auto_renew, notes, status } = body;

    const result = await app.db.query(
      `UPDATE renewals SET name=$1, category=$2, provider=$3, amount=$4, renewal_date=$5,
       frequency=$6, frequency_days=$7, auto_renew=$8, notes=$9, status=$10, updated_at=NOW()
       WHERE id=$11 AND user_id=(SELECT id FROM users WHERE firebase_uid=$12) RETURNING *`,
      [name, category, provider ?? null, amount ?? null, renewal_date, frequency, frequency_days ?? null, auto_renew ?? false, notes ?? null, status ?? "active", id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Renewal");
    return reply.send({ renewal: result.rows[0] });
  });

  app.delete("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await app.db.query(
      "DELETE FROM renewals WHERE id=$1 AND user_id=(SELECT id FROM users WHERE firebase_uid=$2) RETURNING id",
      [id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Renewal");
    return reply.send({ deleted: true, id: result.rows[0].id });
  });
}

async function registerMarkRenewed(app: FastifyInstance) {
  app.post("/:id/renew", auth, async (request, reply) => {
    const { id } = request.params as { id: string };

    const renewal = await app.db.query(
      "SELECT * FROM renewals WHERE id=$1 AND user_id=(SELECT id FROM users WHERE firebase_uid=$2)",
      [id, request.user.uid]
    );
    if (renewal.rows.length === 0) throw new NotFoundError("Renewal");

    const r = renewal.rows[0];
    const nextDate = calculateNextDate(r.renewal_date, r.frequency, r.frequency_days);

    const result = await app.db.query(
      "UPDATE renewals SET renewal_date=$1, updated_at=NOW() WHERE id=$2 RETURNING *",
      [nextDate.toISOString().split("T")[0], id]
    );
    return reply.send({ renewal: result.rows[0] });
  });
}

function calculateNextDate(current: string, frequency: string, customDays: number | null): Date {
  const date = new Date(current);
  switch (frequency) {
    case "monthly": date.setMonth(date.getMonth() + 1); break;
    case "quarterly": date.setMonth(date.getMonth() + 3); break;
    case "yearly": date.setFullYear(date.getFullYear() + 1); break;
    case "weekly": date.setDate(date.getDate() + 7); break;
    case "custom": date.setDate(date.getDate() + (customDays ?? 30)); break;
    default: date.setFullYear(date.getFullYear() + 1);
  }
  return date;
}

export default async function renewalRoutes(app: FastifyInstance) {
  await registerListAndGet(app);
  await registerCreate(app);
  await registerUpdateAndDelete(app);
  await registerMarkRenewed(app);
}
