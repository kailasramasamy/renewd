import type { Job } from "bullmq";
import { getJobPool } from "../queue.js";
import { sendPushNotification } from "../../services/notification.js";

interface DueReminder {
  id: string;
  renewal_id: string;
  days_before: number;
  user_id: string;
  renewal_name: string;
  fcm_token: string | null;
}

export async function processDailyReminderCheck(_job: Job): Promise<void> {
  const pool = getJobPool();

  const { rows } = await pool.query<DueReminder>(
    `SELECT r.id, r.renewal_id, r.days_before, r.user_id,
            ren.name AS renewal_name, u.fcm_token
     FROM reminders r
     JOIN renewals ren ON ren.id = r.renewal_id
     JOIN users u ON u.id = r.user_id
     WHERE r.is_sent = FALSE
       AND COALESCE(r.snoozed_until, r.reminder_date) <= CURRENT_DATE
       AND u.fcm_token IS NOT NULL
       AND ren.status = 'active'`
  );

  console.log(`[ReminderCheck] Found ${rows.length} due reminders`);

  for (const reminder of rows) {
    await sendSingleReminder(pool, reminder);
  }
}

async function sendSingleReminder(pool: ReturnType<typeof getJobPool>, reminder: DueReminder): Promise<void> {
  const { title, body } = formatMessage(reminder.renewal_name, reminder.days_before);

  try {
    await sendPushNotification({
      token: reminder.fcm_token!,
      title,
      body,
      data: {
        renewal_id: reminder.renewal_id,
        reminder_id: reminder.id,
      },
    });

    await pool.query(
      "UPDATE reminders SET is_sent = TRUE, sent_at = NOW() WHERE id = $1",
      [reminder.id]
    );
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
  }
}

function formatMessage(name: string, daysBefore: number): { title: string; body: string } {
  if (daysBefore <= 1) {
    return { title: "Renewal Tomorrow", body: `${name} renews tomorrow!` };
  }
  if (daysBefore <= 7) {
    return { title: "Renewal Next Week", body: `${name} renews in ${daysBefore} days` };
  }
  return { title: "Upcoming Renewal", body: `${name} renews in ${daysBefore} days` };
}
