import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { getApp, closeApp, ensureDevUser } from "./setup.js";

describe("RevenueCat Webhooks", () => {
  beforeAll(async () => {
    const app = await getApp();
    await ensureDevUser(app);
    await app.db.query(
      "UPDATE users SET is_premium = FALSE, premium_expires_at = NULL WHERE firebase_uid = 'dev-user'"
    );
  });

  afterAll(async () => {
    const app = await getApp();
    await app.db.query(
      "UPDATE users SET is_premium = FALSE, premium_expires_at = NULL WHERE firebase_uid = 'dev-user'"
    );
    await closeApp();
  });

  it("INITIAL_PURCHASE activates premium", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/webhooks/revenuecat",
      payload: {
        event: {
          type: "INITIAL_PURCHASE",
          app_user_id: "dev-user",
          expiration_at_ms: Date.now() + 30 * 24 * 60 * 60 * 1000,
          product_id: "renewd_monthly",
        },
      },
    });
    expect(res.statusCode).toBe(200);

    const user = await app.db.query(
      "SELECT is_premium, premium_expires_at FROM users WHERE firebase_uid = 'dev-user'"
    );
    expect(user.rows[0].is_premium).toBe(true);
    expect(user.rows[0].premium_expires_at).not.toBeNull();
  });

  it("EXPIRATION deactivates premium", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/webhooks/revenuecat",
      payload: {
        event: {
          type: "EXPIRATION",
          app_user_id: "dev-user",
          product_id: "renewd_monthly",
        },
      },
    });
    expect(res.statusCode).toBe(200);

    const user = await app.db.query(
      "SELECT is_premium FROM users WHERE firebase_uid = 'dev-user'"
    );
    expect(user.rows[0].is_premium).toBe(false);
  });

  it("NON_RENEWING_PURCHASE sets lifetime (no expiry)", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/webhooks/revenuecat",
      payload: {
        event: {
          type: "NON_RENEWING_PURCHASE",
          app_user_id: "dev-user",
          product_id: "renewd_lifetime",
        },
      },
    });
    expect(res.statusCode).toBe(200);

    const user = await app.db.query(
      "SELECT is_premium, premium_expires_at FROM users WHERE firebase_uid = 'dev-user'"
    );
    expect(user.rows[0].is_premium).toBe(true);
    expect(user.rows[0].premium_expires_at).toBeNull();
  });

  it("CANCELLATION keeps premium (paid period)", async () => {
    const app = await getApp();
    // First activate
    await app.db.query(
      "UPDATE users SET is_premium = TRUE WHERE firebase_uid = 'dev-user'"
    );

    const res = await app.inject({
      method: "POST",
      url: "/api/v1/webhooks/revenuecat",
      payload: {
        event: {
          type: "CANCELLATION",
          app_user_id: "dev-user",
          product_id: "renewd_monthly",
        },
      },
    });
    expect(res.statusCode).toBe(200);

    // Should still be premium
    const user = await app.db.query(
      "SELECT is_premium FROM users WHERE firebase_uid = 'dev-user'"
    );
    expect(user.rows[0].is_premium).toBe(true);
  });

  it("handles unknown user gracefully", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/webhooks/revenuecat",
      payload: {
        event: {
          type: "INITIAL_PURCHASE",
          app_user_id: "nonexistent-user-id",
          product_id: "renewd_monthly",
        },
      },
    });
    expect(res.statusCode).toBe(200);
  });
});
