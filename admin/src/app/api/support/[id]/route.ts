import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { requireAdminAuth } from "@/lib/auth";

export async function PUT(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const authError = await requireAdminAuth();
  if (authError) return authError;

  const { id } = await params;
  const { status } = await request.json();

  await query(
    "UPDATE support_tickets SET status = $1, updated_at = NOW() WHERE id = $2",
    [status, id]
  );

  return NextResponse.json({ success: true });
}
