import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export async function PUT(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const body = await request.json();

  const fields: string[] = [];
  const values: unknown[] = [];
  let idx = 1;

  for (const [key, value] of Object.entries(body)) {
    const dbKey = key === "bgColor" ? "bg_color" : key;
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
  const { id } = await params;
  await query("DELETE FROM banners WHERE id = $1", [id]);
  return NextResponse.json({ success: true });
}
