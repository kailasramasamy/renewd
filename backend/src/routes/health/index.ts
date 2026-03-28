import type { FastifyInstance } from "fastify";

export default async function healthRoutes(app: FastifyInstance) {
  app.get("/health", async (_request, reply) => {
    return reply.status(200).send({
      status: "ok",
      timestamp: new Date().toISOString(),
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
