import { describe, it, expect, afterAll } from "vitest";
import { getApp, closeApp } from "./setup.js";

describe("Health & Config", () => {
  afterAll(closeApp);

  it("GET /health returns ok", async () => {
    const app = await getApp();
    const res = await app.inject({ method: "GET", url: "/api/v1/health" });
    expect(res.statusCode).toBe(200);
    expect(res.json().status).toBe("ok");
  });

  it("GET /premium-config returns structured config", async () => {
    const app = await getApp();
    const res = await app.inject({ method: "GET", url: "/api/v1/premium-config" });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.free_renewal_limit).toBeTypeOf("number");
    expect(body.pricing).toBeDefined();
    expect(body.pricing.monthly).toBeTypeOf("number");
    expect(body.pricing.yearly).toBeTypeOf("number");
    expect(body.pricing.currency).toBeTypeOf("string");
    expect(body.features).toBeDefined();
    expect(body.iap).toBeDefined();
    expect(body.iap.enabled).toBeTypeOf("boolean");
    expect(body.iap.products).toBeDefined();
  });

  it("GET /version-check returns version info", async () => {
    const app = await getApp();
    const res = await app.inject({
      method: "GET",
      url: "/api/v1/version-check?version=1.0.0",
    });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.current_version).toBe("1.0.0");
    expect(body.needs_update).toBeTypeOf("boolean");
  });
});
