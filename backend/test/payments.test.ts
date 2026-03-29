import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { getApp, closeApp, ensureDevUser, cleanupTestData } from "./setup.js";

const auth = { authorization: "Bearer fake" };

describe("Payments", () => {
  let renewalId: string;
  let paymentId: string;

  beforeAll(async () => {
    const app = await getApp();
    await ensureDevUser(app);
    await cleanupTestData(app);

    // Create a renewal for payment tests
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/renewals",
      headers: auth,
      payload: {
        name: "Payment Test Renewal",
        category: "insurance",
        renewal_date: "2026-12-31",
        frequency: "yearly",
        amount: 5000,
      },
    });
    renewalId = res.json().renewal.id;
  });

  afterAll(async () => {
    const app = await getApp();
    await cleanupTestData(app);
    await closeApp();
  });

  it("POST /payments creates a payment", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/payments",
      headers: auth,
      payload: {
        renewal_id: renewalId,
        amount: 5000,
        paid_date: "2026-03-15",
        method: "UPI",
      },
    });
    expect(res.statusCode).toBe(201);
    expect(res.json().payment).toBeDefined();
    paymentId = res.json().payment.id;
  });

  it("GET /payments lists payments", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: "/api/v1/payments",
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().payments.length).toBeGreaterThan(0);
  });

  it("GET /payments/by-renewal/:id returns payments for renewal", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: `/api/v1/payments/by-renewal/${renewalId}`,
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().payments).toBeDefined();
  });

  it("DELETE /payments/:id deletes a payment", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "DELETE",
      url: `/api/v1/payments/${paymentId}`,
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().deleted).toBe(true);
  });
});
