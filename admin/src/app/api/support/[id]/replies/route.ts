import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;

  const replies = await query(
    "SELECT id, sender, message, created_at::text FROM ticket_replies WHERE ticket_id = $1 ORDER BY created_at ASC",
    [id]
  );

  return NextResponse.json({ replies });
}
