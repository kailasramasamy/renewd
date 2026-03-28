import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export async function PUT(request: Request) {
  const body = await request.json();

  for (const [key, value] of Object.entries(body)) {
    await query(
      "UPDATE app_config SET value = $1, updated_at = NOW() WHERE key = $2",
      [value, key]
    );
  }

  return NextResponse.json({ success: true });
}
