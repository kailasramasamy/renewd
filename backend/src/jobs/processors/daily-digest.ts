import type { Job } from "bullmq";
import { getJobPool } from "../queue.js";
import { sendPushNotification } from "../../services/notification.js";

interface DigestUser {
  user_id: string;
  fcm_token: string;
}

interface UpcomingRenewal {
  name: string;
  renewal_date: string;
  amount: number | null;
}

export async function processDailyDigest(_job: Job): Promise<void> {
  const pool = getJobPool();

  const { rows: users } = await pool.query<DigestUser>(
    `SELECT np.user_id, u.fcm_token
     FROM notification_preferences np
     JOIN users u ON u.id = np.user_id
     WHERE np.daily_digest_enabled = TRUE
       AND u.fcm_token IS NOT NULL`
  );

  console.log(`[Digest] Processing digest for ${users.length} users`);

  for (const user of users) {
    await sendDigestForUser(pool, user);
  }
}

async function sendDigestForUser(
  pool: ReturnType<typeof getJobPool>,
  user: DigestUser
): Promise<void> {
  const { rows } = await pool.query<UpcomingRenewal>(
    `SELECT name, renewal_date, amount
     FROM renewals
     WHERE user_id = $1 AND status = 'active'
       AND renewal_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
     ORDER BY renewal_date ASC`,
    [user.user_id]
  );

  if (rows.length === 0) return;

  const names = rows.slice(0, 3).map((r) => r.name).join(", ");
  const suffix = rows.length > 3 ? ` and ${rows.length - 3} more` : "";

  try {
    await sendPushNotification({
      token: user.fcm_token,
      title: "Your Week Ahead",
      body: `${rows.length} renewal${rows.length > 1 ? "s" : ""} coming up: ${names}${suffix}`,
      data: { action: "digest" },
    });
  } catch (err) {
    if (err instanceof Error && err.message.includes("INVALID_FCM_TOKEN")) {
      await pool.query("UPDATE users SET fcm_token = NULL WHERE id = $1", [user.user_id]);
    } else {
      console.error(`[Digest] Failed for user ${user.user_id}:`, err);
    }
  }
}
