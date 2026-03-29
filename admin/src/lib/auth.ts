import { cookies } from "next/headers";
import { NextResponse } from "next/server";

/**
 * Check admin authentication from cookie.
 * Returns null if authenticated, or a 401 NextResponse if not.
 */
export async function requireAdminAuth(): Promise<NextResponse | null> {
  const cookieStore = await cookies();
  const authCookie = cookieStore.get("renewd_admin_auth");

  if (!authCookie || authCookie.value !== "authenticated") {
    return NextResponse.json(
      { error: "Unauthorized" },
      { status: 401 }
    );
  }

  return null;
}
