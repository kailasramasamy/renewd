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

  const ALLOWED_FIELDS: Record<string, string> = {
    title: "title",
    subtitle: "subtitle",
    type: "type",
    bgColor: "bg_color",
    bg_color: "bg_color",
    bgGradientStart: "bg_gradient_start",
    bg_gradient_start: "bg_gradient_start",
    bgGradientEnd: "bg_gradient_end",
    bg_gradient_end: "bg_gradient_end",
    icon: "icon",
    imageUrl: "image_url",
    image_url: "image_url",
    deeplink: "deeplink",
    externalUrl: "external_url",
    external_url: "external_url",
    isActive: "is_active",
    is_active: "is_active",
    priority: "priority",
    startsAt: "starts_at",
    starts_at: "starts_at",
    endsAt: "ends_at",
    ends_at: "ends_at",
  };

  const fields: string[] = [];
  const values: unknown[] = [];
  let idx = 1;

  for (const [key, value] of Object.entries(body)) {
    const dbKey = ALLOWED_FIELDS[key];
    if (!dbKey) continue;
    fields.push(`${dbKey} = $${idx}`);
    values.push(value === "" ? null : value);
    idx++;
  }

  if (fields.length === 0) {
    return NextResponse.json({ success: true });
  }

  fields.push(`updated_at = NOW()`);
  values.push(id);

  await query(
    `UPDATE banners SET ${fields.join(", ")} WHERE id = $${idx}`,
    values
  );

  return NextResponse.json({ success: true });
}

export async function DELETE(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const authError = await requireAdminAuth();
  if (authError) return authError;

  const { id } = await params;
  await query("DELETE FROM banners WHERE id = $1", [id]);
  return NextResponse.json({ success: true });
}
