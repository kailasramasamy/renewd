import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const { password } = await request.json();
  const adminKey = process.env.ADMIN_KEY || "renewd-admin-2026";

  if (password !== adminKey) {
    return NextResponse.json({ error: "Invalid password" }, { status: 401 });
  }

  const response = NextResponse.json({ success: true });
  response.cookies.set("renewd_admin_auth", "authenticated", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: 60 * 60 * 24 * 7, // 7 days
    path: "/",
  });

  return response;
}
