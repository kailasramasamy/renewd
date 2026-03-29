import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export async function POST(request: Request) {
  const body = await request.json();
  const {
    title, subtitle, type, bg_color, bg_gradient_start, bg_gradient_end,
    icon, deeplink, external_url, priority, starts_at, ends_at,
  } = body;

  await query(
    `INSERT INTO banners (title, subtitle, type, bg_color, bg_gradient_start, bg_gradient_end,
      icon, deeplink, external_url, priority, starts_at, ends_at)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)`,
    [
      title, subtitle || null, type || "info", bg_color || null,
      bg_gradient_start || null, bg_gradient_end || null,
      icon || null, deeplink || null, external_url || null,
      priority || 0, starts_at || null, ends_at || null,
    ]
  );

  return NextResponse.json({ success: true });
}
