import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { createHmac, timingSafeEqual } from "crypto";

function verifySession(token: string, secret: string): boolean {
  const lastDot = token.lastIndexOf(".");
  if (lastDot === -1) {
    return token === "authenticated"; // Legacy cookie
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

/**
 * Check admin authentication from cookie.
 * Returns null if authenticated, or a 401 NextResponse if not.
 */
export async function requireAdminAuth(): Promise<NextResponse | null> {
  const cookieStore = await cookies();
  const authCookie = cookieStore.get("renewd_admin_auth");
  const secret = process.env.ADMIN_SESSION_SECRET ?? process.env.ADMIN_KEY ?? "";

  if (!authCookie || !verifySession(authCookie.value, secret)) {
    return NextResponse.json(
      { error: "Unauthorized" },
      { status: 401 }
    );
  }

  return null;
}
