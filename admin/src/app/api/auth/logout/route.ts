import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export async function GET(request: NextRequest) {
  const host = request.headers.get("host") ?? "localhost:3500";
  const proto = request.headers.get("x-forwarded-proto") ?? "https";
  const loginUrl = `${proto}://${host}/login`;

  const response = NextResponse.redirect(loginUrl);
  response.cookies.set("renewd_admin_auth", "", {
    httpOnly: true,
    maxAge: 0,
    path: "/",
  });
  return response;
}
