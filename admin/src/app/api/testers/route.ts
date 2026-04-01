import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { requireAdminAuth } from "@/lib/auth";

export async function POST(request: Request) {
  const authError = await requireAdminAuth();
  if (authError) return authError;

  const body = await request.json();
  const { app_name, description, reward, tester_cap, test_duration_days, platforms, android_test_link, ios_test_link } = body;

  if (!app_name?.trim()) {
    return NextResponse.json({ error: "App name is required" }, { status: 400 });
  }

  const [program] = await query<{ id: string }>(
    `INSERT INTO tester_programs (app_name, description, reward, tester_cap, test_duration_days, platforms, android_test_link, ios_test_link)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING id`,
    [
      app_name.trim(),
      description?.trim() || null,
      reward || "₹100 Amazon Gift Card",
      tester_cap || 20,
      test_duration_days || 7,
      platforms?.length ? platforms : ["android"],
      android_test_link?.trim() || null,
      ios_test_link?.trim() || null,
    ]
  );

  return NextResponse.json({ id: program.id, success: true });
}
