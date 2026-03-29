import fp from "fastify-plugin";
import { Pool } from "pg";
import type { FastifyInstance } from "fastify";
import { env } from "../config/env.js";

declare module "fastify" {
  interface FastifyInstance {
    db: Pool;
  }
}

async function plugin(app: FastifyInstance) {
  const pool = new Pool({
    connectionString: env.DATABASE_URL,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
  });

  try {
    await pool.query("SELECT 1");
    app.log.info("PostgreSQL connected");
  } catch (err) {
    app.log.error("PostgreSQL connection failed: %s", String(err));
    throw err;
  }

  app.decorate("db", pool);

  // Log pool stats every 60s for monitoring
  const statsInterval = setInterval(() => {
    app.log.info({
      msg: "DB pool stats",
      total: pool.totalCount,
      idle: pool.idleCount,
      waiting: pool.waitingCount,
    });
  }, 60000);

  app.addHook("onClose", async () => {
    clearInterval(statsInterval);
    await pool.end();
    app.log.info("PostgreSQL pool closed");
  });
}

export const postgresPlugin = fp(plugin, { name: "postgres" });
