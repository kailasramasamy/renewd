import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export async function PUT(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const body = await request.json();
  const { is_premium, duration_days } = body as {
    is_premium: boolean;
    duration_days?: number;
  };

  if (is_premium && duration_days) {
    await query(
      "UPDATE users SET is_premium = TRUE, premium_expires_at = NOW() + make_interval(days => $1), updated_at = NOW() WHERE id = $2",
      [duration_days, id]
    );
  } else if (is_premium) {
    await query(
      "UPDATE users SET is_premium = TRUE, premium_expires_at = NULL, updated_at = NOW() WHERE id = $1",
      [id]
    );
  } else {
    await query(
      "UPDATE users SET is_premium = FALSE, premium_expires_at = NULL, updated_at = NOW() WHERE id = $1",
      [id]
    );
  }

  return NextResponse.json({ success: true });
}
