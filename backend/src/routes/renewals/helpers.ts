import type { Pool } from "pg";

const DEFAULT_DAYS_BEFORE = [7, 1];

export async function createDefaultReminders(
  db: Pool,
  userId: string,
  renewalId: string,
  renewalDate: string
): Promise<void> {
  const prefsResult = await db.query(
    "SELECT default_days_before FROM notification_preferences WHERE user_id = $1",
    [userId]
  );

  const daysBefore: number[] =
    prefsResult.rows[0]?.default_days_before ?? DEFAULT_DAYS_BEFORE;

  await createRemindersForDays(db, userId, renewalId, renewalDate, daysBefore);
}

export async function createRemindersForDays(
  db: Pool,
  userId: string,
  renewalId: string,
  renewalDate: string,
  daysBefore: number[]
): Promise<void> {
  if (daysBefore.length === 0) return;

  await db.query(
    `INSERT INTO reminders (user_id, renewal_id, days_before, reminder_date)
     SELECT $1, $2, d, ($3::date - d * INTERVAL '1 day')::date
     FROM unnest($4::int[]) AS d
     WHERE ($3::date - d * INTERVAL '1 day')::date >= CURRENT_DATE`,
    [userId, renewalId, renewalDate, daysBefore]
  );
}

export async function deleteUnsentReminders(
  db: Pool,
  renewalId: string
): Promise<void> {
  await db.query(
    "DELETE FROM reminders WHERE renewal_id = $1 AND is_sent = FALSE",
    [renewalId]
  );
}

/** Advance a renewal date by exactly one period of its frequency. */
export function calculateNextDate(
  current: string,
  frequency: string,
  customDays: number | null
): Date {
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

/** Roll a past renewal date forward to its next occurrence on/after `today`. */
export function nextRenewalDate(
  current: string,
  frequency: string,
  customDays: number | null,
  today: string
): string {
  const todayDate = new Date(today);
  let next = new Date(current);
  let guard = 0;
  while (next < todayDate && guard++ < 1000) {
    next = calculateNextDate(
      next.toISOString().split("T")[0],
      frequency,
      customDays
    );
  }
  return next.toISOString().split("T")[0];
}
