import { NextResponse } from "next/server";
import { createHmac, timingSafeEqual } from "crypto";

// In-memory rate limiter for login attempts
const attempts = new Map<string, { count: number; resetAt: number }>();
const MAX_ATTEMPTS = 5;
const WINDOW_MS = 15 * 60 * 1000; // 15 minutes

function isRateLimited(ip: string): boolean {
  const now = Date.now();
  const entry = attempts.get(ip);
  if (!entry || entry.resetAt < now) {
    attempts.set(ip, { count: 1, resetAt: now + WINDOW_MS });
    return false;
  }
  entry.count++;
  return entry.count > MAX_ATTEMPTS;
}

export function signSession(secret: string): string {
  const payload = `admin:${Date.now()}`;
  const sig = createHmac("sha256", secret).update(payload).digest("hex");
  return `${payload}.${sig}`;
}

export function verifySession(token: string, secret: string): boolean {
  const lastDot = token.lastIndexOf(".");
  if (lastDot === -1) return false;
  const payload = token.slice(0, lastDot);
  const sig = token.slice(lastDot + 1);
  const expected = createHmac("sha256", secret).update(payload).digest("hex");
  try {
    return timingSafeEqual(Buffer.from(sig), Buffer.from(expected));
  } catch {
    return false;
  }
}

export async function POST(request: Request) {
  const ip = request.headers.get("x-forwarded-for") ?? "unknown";
  if (isRateLimited(ip)) {
    return NextResponse.json(
      { error: "Too many login attempts. Try again in 15 minutes." },
      { status: 429 }
    );
  }

  const { password } = await request.json();
  const adminKey = process.env.ADMIN_KEY;
  if (!adminKey) {
    return NextResponse.json({ error: "ADMIN_KEY not configured" }, { status: 500 });
  }

  // Timing-safe password comparison
  const pwBuf = Buffer.from(password ?? "");
  const keyBuf = Buffer.from(adminKey);
  if (pwBuf.length !== keyBuf.length || !timingSafeEqual(pwBuf, keyBuf)) {
    return NextResponse.json({ error: "Invalid password" }, { status: 401 });
  }

  const sessionSecret = process.env.ADMIN_SESSION_SECRET ?? adminKey;
  const sessionToken = signSession(sessionSecret);

  const response = NextResponse.json({ success: true });
  response.cookies.set("renewd_admin_auth", sessionToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "strict",
    maxAge: 60 * 60 * 24 * 7, // 7 days
    path: "/",
  });

  return response;
}
