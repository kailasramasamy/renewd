import type { FastifyInstance } from "fastify";
import { renewdQueue } from "../../jobs/queue.js";

export default async function healthRoutes(app: FastifyInstance) {
  app.post("/admin/trigger-reminders", async (request, reply) => {
    const { key } = request.body as { key?: string };
    if (key !== "renewd-admin-2026") {
      return reply.status(403).send({ error: "Forbidden" });
    }
    await renewdQueue.add("daily-reminder-check", {}, {
      removeOnComplete: { age: 3600 },
    });
    return reply.send({ status: "queued", job: "daily-reminder-check" });
  });

  app.get("/health", async (_request, reply) => {
    return reply.status(200).send({
      status: "ok",
      timestamp: new Date().toISOString(),
    });
  });

  app.get("/premium-config", async (_request, reply) => {
    const result = await app.db.query(
      "SELECT key, value FROM app_config WHERE key LIKE 'free_%' OR key LIKE 'premium_%' OR key LIKE 'feature_%' OR key LIKE 'iap_%'"
    );

    const raw: Record<string, string> = {};
    for (const row of result.rows) {
      raw[row.key] = row.value;
    }

    const features: Record<string, string> = {};
    for (const [k, v] of Object.entries(raw)) {
      if (k.startsWith("feature_")) {
        features[k.replace("feature_", "")] = v;
      }
    }

    return reply.send({
      free_renewal_limit: parseInt(raw.free_renewal_limit ?? "5", 10),
      free_reminder_days: JSON.parse(raw.free_reminder_days ?? "[1]"),
      premium_reminder_days: JSON.parse(raw.premium_reminder_days ?? "[7,1]"),
      pricing: {
        monthly: parseInt(raw.premium_monthly_price ?? "99", 10),
        yearly: parseInt(raw.premium_yearly_price ?? "799", 10),
        currency: raw.premium_currency ?? "INR",
      },
      features,
      iap: {
        enabled: raw.iap_enabled === "true",
        products: {
          monthly: raw.iap_product_monthly ?? "renewd_monthly",
          yearly: raw.iap_product_yearly ?? "renewd_yearly",
          lifetime: raw.iap_product_lifetime ?? "renewd_lifetime",
        },
      },
    });
  });

  app.get("/version-check", async (request, reply) => {
    const { version } = request.query as { version?: string };

    const result = await app.db.query(
      "SELECT key, value FROM app_config WHERE key IN ('min_version', 'latest_version', 'force_update', 'update_message')"
    );

    const config: Record<string, string> = {};
    for (const row of result.rows) {
      config[row.key] = row.value;
    }

    const minVersion = config.min_version ?? "1.0.0";
    const latestVersion = config.latest_version ?? "1.0.0";
    const forceUpdate = config.force_update === "true";
    const message = config.update_message ?? "";

    const currentVersion = version ?? "0.0.0";
    const needsUpdate = compareVersions(currentVersion, minVersion) < 0;
    const updateAvailable = compareVersions(currentVersion, latestVersion) < 0;

    return reply.send({
      current_version: currentVersion,
      min_version: minVersion,
      latest_version: latestVersion,
      needs_update: needsUpdate,
      update_available: updateAvailable,
      force_update: forceUpdate && needsUpdate,
      message,
    });
  });
}

function compareVersions(a: string, b: string): number {
  const pa = a.split(".").map(Number);
  const pb = b.split(".").map(Number);
  for (let i = 0; i < 3; i++) {
    const va = pa[i] ?? 0;
    const vb = pb[i] ?? 0;
    if (va < vb) return -1;
    if (va > vb) return 1;
  }
  return 0;
}
