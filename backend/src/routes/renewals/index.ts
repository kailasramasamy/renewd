import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { AppError, NotFoundError } from "../../lib/errors.js";
import { validateString, validateNumber } from "../../lib/validation.js";
import { getUserId } from "../../lib/user-context.js";
import { createDefaultReminders, deleteUnsentReminders } from "./helpers.js";
import { registerReminderRoutes } from "./reminders.js";
import { updateRenewalLogo } from "../../services/logo.js";
import { createPremiumMiddleware } from "../../middleware/premium.js";

const auth = { preHandler: authMiddleware };

async function registerListAndGet(app: FastifyInstance) {
  app.get("/", auth, async (request, reply) => {
    const userId = await getUserId(app, request.user.uid);
    const result = await app.db.query(
      "SELECT * FROM renewals WHERE user_id = $1 ORDER BY renewal_date ASC LIMIT 500",
      [userId]
    );
    return reply.send({ renewals: result.rows, total: result.rowCount });
  });

  app.get("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = await getUserId(app, request.user.uid);
    const result = await app.db.query(
      "SELECT * FROM renewals WHERE id = $1 AND user_id = $2",
      [id, userId]
    );
    if (result.rows.length === 0) throw new NotFoundError("Renewal");
    return reply.send({ renewal: result.rows[0] });
  });
}

async function registerCreate(app: FastifyInstance) {
  const premiumMiddleware = createPremiumMiddleware(app);

  app.post("/", { preHandler: [authMiddleware, premiumMiddleware] }, async (request, reply) => {
    const body = request.body as Record<string, unknown>;
    const userId = await getUserId(app, request.user.uid);

    const name = validateString(body.name, "name", { required: true, maxLen: 100 });
    const category = validateString(body.category, "category", { required: true, maxLen: 50 });
    const provider = validateString(body.provider, "provider", { maxLen: 100 });
    const amount = validateNumber(body.amount, "amount", { min: 0 });
    const { renewal_date, frequency, frequency_days, auto_renew, notes: rawNotes, group_name: rawGroup } = body;
    validateString(renewal_date, "renewal_date", { required: true });
    validateString(frequency, "frequency", { required: true, maxLen: 20 });
    const notes = validateString(rawNotes, "notes", { maxLen: 1000 });
    const group_name = validateString(rawGroup, "group_name", { maxLen: 50 });

    // Atomic insert with limit check to prevent TOCTOU race condition
    if (!request.premium.isPremium) {
      const limitResult = await app.db.query(
        "SELECT value FROM app_config WHERE key = 'free_renewal_limit'"
      );
      const limit = parseInt(limitResult.rows[0]?.value ?? "5", 10);

      const result = await app.db.query(
        `INSERT INTO renewals (user_id, name, category, provider, amount, renewal_date, frequency, frequency_days, auto_renew, notes, group_name)
         SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11
         WHERE (SELECT COUNT(*) FROM renewals WHERE user_id = $1) < $12
         RETURNING *`,
        [userId, name, category, provider ?? null, amount ?? null, renewal_date, frequency, frequency_days ?? null, auto_renew ?? false, notes ?? null, group_name ?? null, limit]
      );

      if (result.rows.length === 0) {
        return reply.status(403).send({
          error: "Free plan renewal limit reached",
          code: "RENEWAL_LIMIT",
          limit,
        });
      }

      const renewal = result.rows[0];
      await createDefaultReminders(app.db, userId, renewal.id, renewal.renewal_date);
      updateRenewalLogo(app.db, renewal.id, renewal.name, renewal.provider).catch(() => {});
      return reply.status(201).send({ renewal });
    }

    const result = await app.db.query(
      `INSERT INTO renewals (user_id, name, category, provider, amount, renewal_date, frequency, frequency_days, auto_renew, notes, group_name)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) RETURNING *`,
      [userId, name, category, provider ?? null, amount ?? null, renewal_date, frequency, frequency_days ?? null, auto_renew ?? false, notes ?? null, group_name ?? null]
    );

    const renewal = result.rows[0];
    await createDefaultReminders(app.db, userId, renewal.id, renewal.renewal_date);

    // Lookup brand logo (non-blocking)
    updateRenewalLogo(app.db, renewal.id, renewal.name, renewal.provider).catch(() => {});

    return reply.status(201).send({ renewal });
  });
}

async function registerUpdateAndDelete(app: FastifyInstance) {
  app.put("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const body = request.body as Record<string, unknown>;
    const { name, category, provider, amount, renewal_date, frequency, frequency_days, auto_renew, notes, status, group_name } = body;
    const userId = await getUserId(app, request.user.uid);

    const result = await app.db.query(
      `UPDATE renewals SET name=$1, category=$2, provider=$3, amount=$4, renewal_date=$5,
       frequency=$6, frequency_days=$7, auto_renew=$8, notes=$9, status=$10, group_name=$11, updated_at=NOW()
       WHERE id=$12 AND user_id=$13 RETURNING *`,
      [name, category, provider ?? null, amount ?? null, renewal_date, frequency, frequency_days ?? null, auto_renew ?? false, notes ?? null, status ?? "active", group_name ?? null, id, userId]
    );
    if (result.rows.length === 0) throw new NotFoundError("Renewal");

    const renewal = result.rows[0];
    await deleteUnsentReminders(app.db, id);
    await createDefaultReminders(app.db, renewal.user_id, id, renewal.renewal_date);
    updateRenewalLogo(app.db, id, renewal.name, renewal.provider).catch(() => {});

    return reply.send({ renewal });
  });

  app.delete("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = await getUserId(app, request.user.uid);
    const client = await app.db.connect();
    try {
      await client.query("BEGIN");
      await client.query("DELETE FROM payments WHERE renewal_id = $1", [id]);
      await client.query("DELETE FROM documents WHERE renewal_id = $1", [id]);
      await client.query("DELETE FROM reminders WHERE renewal_id = $1", [id]);
      const result = await client.query(
        "DELETE FROM renewals WHERE id=$1 AND user_id=$2 RETURNING id",
        [id, userId]
      );
      if (result.rows.length === 0) {
        await client.query("ROLLBACK");
        throw new NotFoundError("Renewal");
      }
      await client.query("COMMIT");
      return reply.send({ deleted: true, id: result.rows[0].id });
    } catch (err) {
      await client.query("ROLLBACK").catch(() => {});
      throw err;
    } finally {
      client.release();
    }
  });
}

async function registerMarkRenewed(app: FastifyInstance) {
  app.post("/:id/renew", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = await getUserId(app, request.user.uid);

    const renewal = await app.db.query(
      "SELECT * FROM renewals WHERE id=$1 AND user_id=$2",
      [id, userId]
    );
    if (renewal.rows.length === 0) throw new NotFoundError("Renewal");

    const r = renewal.rows[0];
    const nextDate = calculateNextDate(r.renewal_date, r.frequency, r.frequency_days);
    const nextDateStr = nextDate.toISOString().split("T")[0];

    const result = await app.db.query(
      "UPDATE renewals SET renewal_date=$1, updated_at=NOW() WHERE id=$2 RETURNING *",
      [nextDateStr, id]
    );

    await deleteUnsentReminders(app.db, id);
    await createDefaultReminders(app.db, r.user_id, id, nextDateStr);

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

async function registerPriceCheck(app: FastifyInstance) {
  app.get("/:id/price-check", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = await getUserId(app, request.user.uid);

    const renewal = await app.db.query(
      "SELECT amount, previous_amount FROM renewals WHERE id = $1 AND user_id = $2",
      [id, userId]
    );
    if (renewal.rows.length === 0) throw new NotFoundError("Renewal");

    const lastPayment = await app.db.query(
      "SELECT amount FROM payments WHERE renewal_id = $1 ORDER BY paid_date DESC LIMIT 1",
      [id]
    );

    const currentAmount = parseFloat(renewal.rows[0].amount) || 0;
    const lastPaid = lastPayment.rows.length > 0
      ? parseFloat(lastPayment.rows[0].amount) || 0
      : null;
    const previousAmount = parseFloat(renewal.rows[0].previous_amount) || null;

    const changed = lastPaid !== null && lastPaid !== currentAmount;
    const diff = changed ? lastPaid - currentAmount : 0;

    return reply.send({
      current_amount: currentAmount,
      last_paid: lastPaid,
      previous_amount: previousAmount,
      price_changed: changed,
      difference: diff,
    });
  });
}

async function registerBackfillLogos(app: FastifyInstance) {
  app.post("/backfill-logos", auth, async (_request, reply) => {
    const result = await app.db.query(
      "SELECT id, name, provider FROM renewals WHERE logo_url IS NULL"
    );
    let updated = 0;
    for (const row of result.rows) {
      await updateRenewalLogo(app.db, row.id, row.name, row.provider);
      updated++;
    }
    return reply.send({ updated, total: result.rowCount });
  });
}

async function registerDuplicateCheck(app: FastifyInstance) {
  app.post("/check-duplicate", auth, async (request, reply) => {
    const body = request.body as Record<string, unknown>;
    const { name, provider, category, amount, renewal_date } = body;
    const userId = await getUserId(app, request.user.uid);

    // Check for similar renewals by name, provider, category+amount, or same date for insurance
    const result = await app.db.query(
      `SELECT id, name, provider, category, amount::text, frequency, renewal_date::text
       FROM renewals
       WHERE user_id = $1 AND status = 'active' AND (
         LOWER(name) = LOWER($2)
         OR (LOWER(provider) = LOWER($3) AND provider IS NOT NULL AND $3 IS NOT NULL AND $3 != '')
         OR (category = $4 AND amount = $5 AND $5 IS NOT NULL)
         OR (category = 'insurance' AND $4 = 'insurance' AND renewal_date = $6::date AND $6 IS NOT NULL)
       )
       LIMIT 3`,
      [userId, name ?? "", provider ?? "", category ?? "", amount ?? null, renewal_date ?? null]
    );

    return reply.send({
      hasDuplicate: result.rows.length > 0,
      matches: result.rows,
    });
  });
}

export default async function renewalRoutes(app: FastifyInstance) {
  await registerListAndGet(app);
  await registerCreate(app);
  await registerUpdateAndDelete(app);
  await registerMarkRenewed(app);
  await registerReminderRoutes(app);
  await registerPriceCheck(app);
  await registerDuplicateCheck(app);
  await registerBackfillLogos(app);
}
