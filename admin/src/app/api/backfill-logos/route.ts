import { NextResponse } from "next/server";
import { requireAdminAuth } from "@/lib/auth";

export async function POST() {
  const authError = await requireAdminAuth();
  if (authError) return authError;

  const backendUrl = process.env.BACKEND_URL;
  if (!backendUrl) {
    return NextResponse.json(
      { error: "BACKEND_URL not configured" },
      { status: 500 }
    );
  }

  const res = await fetch(`${backendUrl}/backfill-logos`, {
    method: "POST",
    headers: {
      "x-admin-key": process.env.ADMIN_KEY || "",
    },
  });

  const data = await res.json();
  if (!res.ok) {
    return NextResponse.json(
      { error: data.error || "Backend call failed" },
      { status: res.status }
    );
  }

  return NextResponse.json(data);
}
