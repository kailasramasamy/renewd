import admin from "firebase-admin";
import { AppError } from "../lib/errors.js";

interface PushPayload {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

export async function sendPushNotification(payload: PushPayload): Promise<string> {
  const { token, title, body, data } = payload;

  try {
    const messageId = await admin.messaging().send({
      token,
      notification: { title, body },
      data,
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    });

    return messageId;
  } catch (err) {
    if (err instanceof Error && err.message.includes("registration-token-not-registered")) {
      throw new AppError("FCM token is no longer valid", 400, "INVALID_FCM_TOKEN");
    }
    throw new AppError("Failed to send push notification", 502, "NOTIFICATION_ERROR");
  }
}
