import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { getApp, closeApp, ensureDevUser, cleanupTestData } from "./setup.js";

const auth = { authorization: "Bearer fake" };

describe("Renewals", () => {
  let renewalId: string;

  beforeAll(async () => {
    const app = await getApp();
    await ensureDevUser(app);
    await cleanupTestData(app);
  });
  afterAll(async () => {
    const app = await getApp();
    await cleanupTestData(app);
    await closeApp();
  });

  it("POST /renewals creates a renewal", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/renewals",
      headers: auth,
      payload: {
        name: "Test Insurance",
        category: "insurance",
        provider: "Test Provider",
        amount: 5000,
        renewal_date: "2026-12-31",
        frequency: "yearly",
      },
    });
    expect(res.statusCode).toBe(201);
    const body = res.json();
    expect(body.renewal).toBeDefined();
    expect(body.renewal.name).toBe("Test Insurance");
    renewalId = body.renewal.id;
  });

  it("GET /renewals lists all renewals", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: "/api/v1/renewals",
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().renewals.length).toBeGreaterThan(0);
  });

  it("GET /renewals/:id returns single renewal", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: `/api/v1/renewals/${renewalId}`,
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().renewal.id).toBe(renewalId);
  });

  it("PUT /renewals/:id updates a renewal", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "PUT",
      url: `/api/v1/renewals/${renewalId}`,
      headers: auth,
      payload: {
        name: "Updated Insurance",
        category: "insurance",
        renewal_date: "2026-12-31",
        frequency: "yearly",
      },
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().renewal.name).toBe("Updated Insurance");
  });

  it("POST /renewals/:id/renew advances renewal date", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: `/api/v1/renewals/${renewalId}/renew`,
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    const newDate = new Date(res.json().renewal.renewal_date);
    expect(newDate.getFullYear()).toBeGreaterThanOrEqual(2027);
  });

  it("GET /renewals/:id/reminders returns reminders", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: `/api/v1/renewals/${renewalId}/reminders`,
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().reminders).toBeDefined();
  });

  it("DELETE /renewals/:id deletes a renewal", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "DELETE",
      url: `/api/v1/renewals/${renewalId}`,
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().deleted).toBe(true);
  });

  it("GET /renewals/:id returns 404 for deleted renewal", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: `/api/v1/renewals/${renewalId}`,
      headers: auth,
    });
    expect(res.statusCode).toBe(404);
  });
});
