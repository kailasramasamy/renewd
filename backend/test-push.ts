import admin from "firebase-admin";
import { env } from "./src/config/env.js";

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert({
    projectId: env.FIREBASE_PROJECT_ID,
    clientEmail: env.FIREBASE_CLIENT_EMAIL,
    privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
  }),
});

const FCM_TOKEN = process.argv[2];

if (!FCM_TOKEN) {
  console.error("Usage: npx tsx test-push.ts <fcm_token>");
  process.exit(1);
}

async function sendTestPush() {
  try {
    const result = await admin.messaging().send({
      token: FCM_TOKEN,
      notification: {
        title: "Renewd Test",
        body: "Push notifications are working!",
      },
      data: {
        type: "test",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    });
    console.log("Push sent successfully:", result);
  } catch (err) {
    console.error("Push failed:", err);
  }
  process.exit(0);
}

sendTestPush();
