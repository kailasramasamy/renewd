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

  try {
    const res = await fetch(`${backendUrl}/backfill-logos`, {
      method: "POST",
      headers: {
        "x-admin-key": process.env.ADMIN_KEY || "",
      },
    });

    const text = await res.text();
    if (!text) {
      return NextResponse.json(
        { error: `Backend returned empty response (status ${res.status})` },
        { status: 502 }
      );
    }

    const data = JSON.parse(text);
    if (!res.ok) {
      return NextResponse.json(
        { error: data.error || `Backend error (status ${res.status})` },
        { status: res.status }
      );
    }

    return NextResponse.json(data);
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : "Failed to reach backend" },
      { status: 502 }
    );
  }
}
