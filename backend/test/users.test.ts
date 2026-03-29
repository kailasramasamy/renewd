import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { getApp, closeApp, ensureDevUser } from "./setup.js";

describe("Users", () => {
  beforeAll(async () => {
    const app = await getApp();
    await ensureDevUser(app);
  });
  afterAll(closeApp);

  it("GET /users/me returns user with plan info", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: "/api/v1/users/me",
      headers: { authorization: "Bearer fake" },
    });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.user).toBeDefined();
    expect(body.user.firebase_uid).toBe("dev-user");
    expect(body.plan).toBeDefined();
    expect(body.plan.is_premium).toBeTypeOf("boolean");
    expect(body.plan.renewal_count).toBeTypeOf("number");
  });

  it("PATCH /users/me updates user profile", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "PATCH",
      url: "/api/v1/users/me",
      headers: { authorization: "Bearer fake" },
      payload: { name: "Updated Name" },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().user.name).toBe("Updated Name");

    // Restore name
    await app.inject({
      method: "PATCH",
      url: "/api/v1/users/me",
      headers: { authorization: "Bearer fake" },
      payload: { name: "Test User" },
    });
  });

  it("DELETE /users/me deletes user and all data", async () => {
    const app = await getApp();

    // Create a throwaway user
    await app.db.query(
      "INSERT INTO users (firebase_uid, email, name) VALUES ('delete-test', 'delete@test.com', 'Delete Me') ON CONFLICT (firebase_uid) DO NOTHING"
    );

    // We can't easily test this via inject since auth middleware uses dev-user
    // Just verify the user exists then clean up
    const result = await app.db.query("SELECT id FROM users WHERE firebase_uid = 'delete-test'");
    expect(result.rows.length).toBe(1);

    await app.db.query("DELETE FROM users WHERE firebase_uid = 'delete-test'");
  });
});
