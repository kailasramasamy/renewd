import type { Job } from "bullmq";

interface ReminderJobData {
  renewalId: string;
  userId: string;
  renewalName: string;
  daysUntilDue: number;
  fcmToken?: string;
}

export async function processReminder(job: Job<ReminderJobData>): Promise<void> {
  const { renewalId, userId, renewalName, daysUntilDue } = job.data;

  console.log(
    `[Reminder] Processing reminder for renewal "${renewalName}" (${renewalId}) — user ${userId}, due in ${daysUntilDue} day(s)`
  );

  // TODO: call notification service to send FCM push
  // await sendPushNotification({ userId, fcmToken, title, body })
}
