import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { getApp, closeApp, ensureDevUser, cleanupTestData } from "./setup.js";

const auth = { authorization: "Bearer fake" };

describe("Support Tickets", () => {
  let ticketId: string;

  beforeAll(async () => {
    const app = await getApp();
    await ensureDevUser(app);
  });

  afterAll(async () => {
    const app = await getApp();
    if (ticketId) {
      await app.db.query("DELETE FROM ticket_replies WHERE ticket_id = $1", [ticketId]);
      await app.db.query("DELETE FROM support_tickets WHERE id = $1", [ticketId]);
    }
    await closeApp();
  });

  it("POST /support creates a ticket", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/support",
      headers: auth,
      payload: {
        type: "bug",
        subject: "E2E Test Bug",
        description: "Testing ticket creation end-to-end",
        device_info: "iOS 19.0",
      },
    });
    expect(res.statusCode).toBe(201);
    const body = res.json();
    expect(body.ticket).toBeDefined();
    expect(body.ticket.subject).toBe("E2E Test Bug");
    expect(body.ticket.status).toBe("open");
    ticketId = body.ticket.id;
  });

  it("GET /support lists user tickets", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: "/api/v1/support",
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    expect(res.json().tickets.length).toBeGreaterThan(0);
  });

  it("POST /support/:id/reply adds user reply", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: `/api/v1/support/${ticketId}/reply`,
      headers: auth,
      payload: { message: "Adding more details here" },
    });
    expect(res.statusCode).toBe(201);
  });

  it("GET /support/:id returns ticket with replies", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: `/api/v1/support/${ticketId}`,
      headers: auth,
    });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.ticket.id).toBe(ticketId);
    expect(body.replies.length).toBe(1);
    expect(body.replies[0].sender).toBe("user");
    expect(body.replies[0].message).toBe("Adding more details here");
  });

  it("admin reply updates ticket", async () => {
    const app = await getApp();
    // Simulate admin reply via DB
    await app.db.query(
      "INSERT INTO ticket_replies (ticket_id, sender, message) VALUES ($1, 'admin', 'We are looking into this')",
      [ticketId]
    );
    await app.db.query(
      "UPDATE support_tickets SET status = 'in_progress' WHERE id = $1",
      [ticketId]
    );

    const res = await app.inject({
      method: "GET",
      url: `/api/v1/support/${ticketId}`,
      headers: auth,
    });
    const body = res.json();
    expect(body.ticket.status).toBe("in_progress");
    expect(body.replies.length).toBe(2);
    expect(body.replies[1].sender).toBe("admin");
  });

  it("rejects ticket without subject", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "POST",
      url: "/api/v1/support",
      headers: auth,
      payload: { type: "bug", description: "no subject" },
    });
    expect(res.statusCode).toBe(422);
  });

  it("returns 404 for non-existent ticket", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: "/api/v1/support/00000000-0000-0000-0000-000000000000",
      headers: auth,
    });
    expect(res.statusCode).toBe(404);
  });
});
