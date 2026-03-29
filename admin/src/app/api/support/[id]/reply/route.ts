import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import admin from "firebase-admin";

// Initialize Firebase Admin if not already
if (!admin.apps.length && process.env.FIREBASE_PROJECT_ID) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    }),
  });
}

export async function POST(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const { message } = await request.json();

  // Save reply
  await query(
    "INSERT INTO ticket_replies (ticket_id, sender, message) VALUES ($1, 'admin', $2)",
    [id, message]
  );

  // Update ticket status
  await query(
    "UPDATE support_tickets SET status = 'in_progress', updated_at = NOW() WHERE id = $1 AND status = 'open'",
    [id]
  );

  // Get ticket subject and user FCM token
  const ticketResult = await query<{ subject: string; fcm_token: string | null; user_id: string }>(
    `SELECT t.subject, u.fcm_token, u.id AS user_id
     FROM support_tickets t JOIN users u ON u.id = t.user_id
     WHERE t.id = $1`,
    [id]
  );

  if (ticketResult.length > 0) {
    const { subject, fcm_token, user_id } = ticketResult[0];

    // Log to notification inbox with ticket_id in metadata
    await query(
      `INSERT INTO notification_log (user_id, title, body, type, metadata)
       VALUES ($1, $2, $3, 'support', $4)`,
      [user_id, `Reply: ${subject}`, message, JSON.stringify({ ticket_id: id })]
    );

    // Send push notification
    if (fcm_token && admin.apps.length > 0) {
      try {
        await admin.messaging().send({
          token: fcm_token,
          notification: {
            title: `Reply: ${subject}`,
            body: message.length > 100 ? message.substring(0, 100) + "..." : message,
          },
          data: {
            type: "support",
            ticket_id: id,
          },
          apns: {
            payload: { aps: { sound: "default", badge: 1 } },
          },
        });
      } catch {
        // FCM send failed — token may be invalid
      }
    }
  }

  return NextResponse.json({ success: true });
}
