import type { Job } from "bullmq";
import { getJobPool } from "../queue.js";
import { sendPushNotification } from "../../services/notification.js";
import { OVERDUE_GRACE_DAYS } from "../../routes/renewals/helpers.js";

interface DueReminder {
  id: string;
  renewal_id: string;
  days_left: number;
  user_id: string;
  renewal_name: string;
  fcm_token: string | null;
}

export async function processDailyReminderCheck(_job: Job): Promise<{ processed: number; failed: number }> {
  const pool = getJobPool();

  // One notification per renewal per day: if several reminders are due (missed
  // runs, snoozes), send only the latest and mark the rest handled.
  const { rows } = await pool.query<DueReminder>(
    `SELECT DISTINCT ON (r.renewal_id) r.id, r.renewal_id, r.user_id,
            ren.renewal_date - CURRENT_DATE AS days_left,
            ren.name AS renewal_name, u.fcm_token
     FROM reminders r
     JOIN renewals ren ON ren.id = r.renewal_id
     JOIN users u ON u.id = r.user_id
     LEFT JOIN notification_preferences np ON np.user_id = r.user_id
     WHERE r.is_sent = FALSE
       AND COALESCE(r.snoozed_until, r.reminder_date) <= CURRENT_DATE
       AND ren.renewal_date >= CURRENT_DATE - $1::int
       AND ren.status = 'active'
       AND COALESCE(np.enabled, TRUE)
     ORDER BY r.renewal_id, COALESCE(r.snoozed_until, r.reminder_date) DESC`,
    [OVERDUE_GRACE_DAYS]
  );

  console.log(`[ReminderCheck] Found ${rows.length} due reminders`);

  let failed = 0;
  for (const reminder of rows) {
    const ok = await sendSingleReminder(pool, reminder);
    if (!ok) failed++;
  }

  return { processed: rows.length, failed };
}

async function sendSingleReminder(pool: ReturnType<typeof getJobPool>, reminder: DueReminder): Promise<boolean> {
  const { title, body } = formatMessage(reminder.renewal_name, reminder.days_left);

  // In-app inbox is the reliable channel — record it and mark the reminder
  // handled regardless of whether the push delivers.
  await pool.query(
    `INSERT INTO notification_log (user_id, renewal_id, title, body, type)
     VALUES ($1, $2, $3, $4, 'reminder')`,
    [reminder.user_id, reminder.renewal_id, title, body]
  );
  await pool.query(
    `UPDATE reminders SET is_sent = TRUE, sent_at = NOW()
     WHERE renewal_id = $1 AND is_sent = FALSE
       AND COALESCE(snoozed_until, reminder_date) <= CURRENT_DATE`,
    [reminder.renewal_id]
  );

  // Push is best-effort; users without a token still get the in-app record.
  if (!reminder.fcm_token) return true;

  try {
    await sendPushNotification({
      token: reminder.fcm_token,
      title,
      body,
      data: {
        renewal_id: reminder.renewal_id,
        reminder_id: reminder.id,
      },
    });
    return true;
  } catch (err) {
    if (err instanceof Error && err.message.includes("INVALID_FCM_TOKEN")) {
      await pool.query(
        "UPDATE users SET fcm_token = NULL WHERE id = $1",
        [reminder.user_id]
      );
      console.warn(`[ReminderCheck] Cleared invalid FCM token for user ${reminder.user_id}`);
    } else {
      console.error(`[ReminderCheck] Failed to send reminder ${reminder.id}:`, err);
    }
    return false;
  }
}

function formatMessage(name: string, daysLeft: number): { title: string; body: string } {
  if (daysLeft < 0) {
    const overdue = -daysLeft;
    const unit = overdue === 1 ? "day" : "days";
    return {
      title: "Renewal Overdue",
      body: `${name} was due ${overdue} ${unit} ago. Mark it renewed or update the date.`,
    };
  }
  if (daysLeft === 0) {
    return { title: "Renews Today", body: `${name} is due today!` };
  }
  if (daysLeft === 1) {
    return { title: "Renewal Tomorrow", body: `${name} renews tomorrow!` };
  }
  if (daysLeft <= 3) {
    return { title: `Renewal in ${daysLeft} Days`, body: `${name} renews in ${daysLeft} days` };
  }
  if (daysLeft <= 7) {
    return { title: "Renewal Next Week", body: `${name} renews in ${daysLeft} days` };
  }
  return { title: "Upcoming Renewal", body: `${name} renews in ${daysLeft} days` };
}
