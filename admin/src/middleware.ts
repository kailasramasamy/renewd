import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { createHmac, timingSafeEqual } from "crypto";

function verifySession(token: string, secret: string): boolean {
  const lastDot = token.lastIndexOf(".");
  if (lastDot === -1) {
    // Legacy plain "authenticated" cookie — accept but it'll be replaced on next login
    return token === "authenticated";
  }
  const payload = token.slice(0, lastDot);
  const sig = token.slice(lastDot + 1);
  const expected = createHmac("sha256", secret).update(payload).digest("hex");
  try {
    return timingSafeEqual(Buffer.from(sig), Buffer.from(expected));
  } catch {
    return false;
  }
}

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Skip auth for login page, API auth routes, and static assets
  if (
    pathname === "/login" ||
    pathname.startsWith("/api/auth") ||
    pathname.startsWith("/_next") ||
    pathname.startsWith("/favicon")
  ) {
    return NextResponse.next();
  }

  // Check for auth cookie
  const authCookie = request.cookies.get("renewd_admin_auth");
  const secret = process.env.ADMIN_SESSION_SECRET ?? process.env.ADMIN_KEY ?? "";

  if (!authCookie || !verifySession(authCookie.value, secret)) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
