import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { requireAdminAuth } from "@/lib/auth";

export async function DELETE(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const authError = await requireAdminAuth();
  if (authError) return authError;

  const { id } = await params;

  // Recursive delete: payments → documents → reminders → renewals → notifications → preferences → user
  await query("DELETE FROM payments WHERE user_id = $1", [id]);
  await query("DELETE FROM documents WHERE user_id = $1", [id]);
  await query(
    "DELETE FROM reminders WHERE renewal_id IN (SELECT id FROM renewals WHERE user_id = $1)",
    [id]
  );
  await query("DELETE FROM renewals WHERE user_id = $1", [id]);
  await query("DELETE FROM notification_log WHERE user_id = $1", [id]);
  await query("DELETE FROM notification_preferences WHERE user_id = $1", [id]);
  await query("DELETE FROM users WHERE id = $1", [id]);

  return NextResponse.json({ success: true });
}
