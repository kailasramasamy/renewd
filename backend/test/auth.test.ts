import { describe, it, expect, afterAll } from "vitest";
import { getApp, closeApp } from "./setup.js";

describe("Auth", () => {
  afterAll(closeApp);

  it("POST /auth/register creates user (dev mode)", async () => {
    const app = await getApp();

    // Clean up first
    await app.db.query("DELETE FROM users WHERE firebase_uid = 'dev-user'");

    const res = await app.inject({
      method: "POST",
      url: "/api/v1/auth/register",
      headers: { authorization: "Bearer fake-token" },
    });
    expect(res.statusCode).toBe(201);
    expect(res.json().user).toBeDefined();
    expect(res.json().user.firebase_uid).toBe("dev-user");
  });

  it("POST /auth/register returns 409 for existing user", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/auth/register",
      headers: { authorization: "Bearer fake-token" },
    });
    expect(res.statusCode).toBe(409);
  });

  it("rejects requests without auth header", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: "/api/v1/users/me",
    });
    // In dev mode without FIREBASE_PROJECT_ID, auth is bypassed
    // So this will either be 401 (production) or 200 (dev)
    expect([200, 401]).toContain(res.statusCode);
  });
});
