import fp from "fastify-plugin";
import Redis from "ioredis";
import type { FastifyInstance } from "fastify";
import { env } from "../config/env.js";

declare module "fastify" {
  interface FastifyInstance {
    redis: Redis;
  }
}

async function plugin(app: FastifyInstance) {
  const redis = new Redis(env.REDIS_URL, {
    maxRetriesPerRequest: 3,
    lazyConnect: true,
  });

  try {
    await redis.connect();
    app.log.info("Redis connected");
  } catch (err) {
    app.log.error("Redis connection failed:", err);
    throw err;
  }

  app.decorate("redis", redis);

  app.addHook("onClose", async () => {
    await redis.quit();
    app.log.info("Redis connection closed");
  });
}

export const redisPlugin = fp(plugin, { name: "redis" });
