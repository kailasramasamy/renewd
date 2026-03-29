import type { FastifyInstance } from "fastify";

const CACHE_TTL = 3600; // 1 hour

/**
 * Get an app_config value with Redis caching.
 * Falls back to direct DB query if Redis is unavailable.
 */
export async function getConfigValue(
  app: FastifyInstance,
  key: string
): Promise<string | null> {
  const cacheKey = `config:${key}`;

  try {
    const cached = await app.redis.get(cacheKey);
    if (cached !== null) return cached;
  } catch {
    // Redis unavailable — fall through to DB
  }

  const result = await app.db.query(
    "SELECT value FROM app_config WHERE key = $1",
    [key]
  );

  const value = result.rows[0]?.value ?? null;

  if (value !== null) {
    try {
      await app.redis.setex(cacheKey, CACHE_TTL, value);
    } catch {
      // Redis unavailable — ignore
    }
  }

  return value;
}

/**
 * Invalidate a cached config value (call after admin updates config).
 */
export async function invalidateConfig(
  app: FastifyInstance,
  key: string
): Promise<void> {
  try {
    await app.redis.del(`config:${key}`);
  } catch {
    // Redis unavailable — ignore
  }
}
