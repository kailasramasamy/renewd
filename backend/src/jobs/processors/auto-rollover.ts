import type { Job } from "bullmq";
import { getJobPool } from "../queue.js";
import {
  nextRenewalDate,
  createDefaultReminders,
  deleteUnsentReminders,
} from "../../routes/renewals/helpers.js";

interface OverdueRenewal {
  id: string;
  user_id: string;
  frequency: string;
  frequency_days: number | null;
  renewal_date: string;
  today: string;
}

/**
 * Advance active renewals whose date has passed to their next occurrence and
 * generate the next cycle's reminders. Runs before the daily reminder check so
 * a freshly-created reminder due today can still fire the same morning.
 */
export async function processAutoRollover(
  _job: Job
): Promise<{ processed: number; failed: number }> {
  const pool = getJobPool();

  const { rows } = await pool.query<OverdueRenewal>(
    `SELECT id, user_id, frequency, frequency_days,
            renewal_date::text AS renewal_date, CURRENT_DATE::text AS today
     FROM renewals
     WHERE status = 'active' AND renewal_date < CURRENT_DATE`
  );

  console.log(`[AutoRollover] Found ${rows.length} overdue renewals`);

  let failed = 0;
  for (const r of rows) {
    try {
      const next = nextRenewalDate(
        r.renewal_date,
        r.frequency,
        r.frequency_days,
        r.today
      );
      await pool.query(
        "UPDATE renewals SET renewal_date = $1, updated_at = NOW() WHERE id = $2",
        [next, r.id]
      );
      await deleteUnsentReminders(pool, r.id);
      await createDefaultReminders(pool, r.user_id, r.id, next);
    } catch (err) {
      failed++;
      console.error(`[AutoRollover] Failed to roll renewal ${r.id}:`, err);
    }
  }

  return { processed: rows.length, failed };
}
