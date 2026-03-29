import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { getApp, closeApp, ensureDevUser, cleanupTestData } from "./setup.js";

const auth = { authorization: "Bearer fake" };

describe("Premium Gating", () => {
  beforeAll(async () => {
    const app = await getApp();
    await ensureDevUser(app);
    await cleanupTestData(app);
    // Ensure dev user is NOT premium
    await app.db.query(
      "UPDATE users SET is_premium = FALSE WHERE firebase_uid = 'dev-user'"
    );
    // Set feature flags to 'premium' for gating tests
    await app.db.query(
      "UPDATE app_config SET value = 'premium' WHERE key LIKE 'feature_%'"
    );
  });

  afterAll(async () => {
    const app = await getApp();
    await cleanupTestData(app);
    await app.db.query(
      "UPDATE users SET is_premium = FALSE WHERE firebase_uid = 'dev-user'"
    );
    // Restore feature flags to 'all'
    await app.db.query(
      "UPDATE app_config SET value = 'all' WHERE key LIKE 'feature_%'"
    );
    await closeApp();
  });

  it("free user gets blocked on chat (403)", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/chat",
      headers: auth,
      payload: { message: "hello" },
    });
    expect(res.statusCode).toBe(403);
    expect(res.json().code).toBe("PREMIUM_REQUIRED");
  });

  it("premium user can access chat", async () => {
    const app = await getApp();
    await app.db.query(
      "UPDATE users SET is_premium = TRUE WHERE firebase_uid = 'dev-user'"
    );
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/chat",
      headers: auth,
      payload: { message: "hello" },
    });
    // Should not be 403 — may be 200 or error from Claude API, but not premium blocked
    expect(res.statusCode).not.toBe(403);
  });

  it("renewal limit enforced for free users", async () => {
    const app = await getApp();
    await app.db.query(
      "UPDATE users SET is_premium = FALSE WHERE firebase_uid = 'dev-user'"
    );
    // Set limit to 2 for testing
    await app.db.query(
      "UPDATE app_config SET value = '2' WHERE key = 'free_renewal_limit'"
    );

    // Create 2 renewals
    for (let i = 0; i < 2; i++) {
      const res = await app.inject({
        method: "POST",
        url: "/api/v1/renewals",
        headers: auth,
        payload: {
          name: `Limit Test ${i}`,
          category: "other",
          renewal_date: "2026-12-31",
          frequency: "yearly",
        },
      });
      expect(res.statusCode).toBe(201);
    }

    // 3rd should be blocked
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/renewals",
      headers: auth,
      payload: {
        name: "Over Limit",
        category: "other",
        renewal_date: "2026-12-31",
        frequency: "yearly",
      },
    });
    expect(res.statusCode).toBe(403);
    expect(res.json().code).toBe("RENEWAL_LIMIT");

    // Restore limit
    await app.db.query(
      "UPDATE app_config SET value = '999' WHERE key = 'free_renewal_limit'"
    );
  });

  it("premium user bypasses renewal limit", async () => {
    const app = await getApp();
    await app.db.query(
      "UPDATE users SET is_premium = TRUE WHERE firebase_uid = 'dev-user'"
    );
    await app.db.query(
      "UPDATE app_config SET value = '2' WHERE key = 'free_renewal_limit'"
    );

    const res = await app.inject({
      method: "POST",
      url: "/api/v1/renewals",
      headers: auth,
      payload: {
        name: "Premium No Limit",
        category: "other",
        renewal_date: "2026-12-31",
        frequency: "yearly",
      },
    });
    expect(res.statusCode).toBe(201);

    // Restore
    await app.db.query(
      "UPDATE app_config SET value = '999' WHERE key = 'free_renewal_limit'"
    );
  });

  it("premium auto-expires when past expiry date", async () => {
    const app = await getApp();
    // Set premium with past expiry
    await app.db.query(
      "UPDATE users SET is_premium = TRUE, premium_expires_at = NOW() - INTERVAL '1 day' WHERE firebase_uid = 'dev-user'"
    );

    const res = await app.inject({
      method: "GET",
      url: "/api/v1/users/me",
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().plan.is_premium).toBe(false);
  });
});
