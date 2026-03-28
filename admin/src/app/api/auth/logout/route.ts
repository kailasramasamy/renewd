import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export async function GET(request: NextRequest) {
  const response = NextResponse.redirect(new URL("/login", request.url));
  response.cookies.set("renewd_admin_auth", "", {
    httpOnly: true,
    maxAge: 0,
    path: "/",
  });
  return response;
}
