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
  const body = await request.json();
  const { description, reward, tester_cap, status, platforms, android_test_link, ios_test_link } = body;

  await query(
    `UPDATE tester_programs
     SET description = $1, reward = $2, tester_cap = $3, status = $4,
         platforms = $5, android_test_link = $6, ios_test_link = $7,
         updated_at = NOW()
     WHERE id = $8`,
    [
      description || null,
      reward,
      tester_cap,
      status,
      platforms,
      android_test_link || null,
      ios_test_link || null,
      id,
    ]
  );

  return NextResponse.json({ success: true });
}
