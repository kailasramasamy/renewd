import type { FastifyRequest, FastifyReply, FastifyInstance } from "fastify";

interface RateLimitOptions {
  /** Max requests allowed in the window */
  max: number;
  /** Window size in seconds */
  windowSeconds: number;
  /** Redis key prefix */
  prefix: string;
  /** Error message when rate limited */
  message?: string;
  /** Error code in response */
  code?: string;
}

/**
 * Sliding-window rate limiter backed by Redis.
 * Falls back to allowing requests if Redis is unavailable.
 */
export function createRateLimit(app: FastifyInstance, opts: RateLimitOptions) {
  const {
    max,
    windowSeconds,
    prefix,
    message = "Too many requests. Please try again later.",
    code = "RATE_LIMITED",
  } = opts;

  return async function rateLimit(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    const uid = request.user?.uid;
    if (!uid) return;

    const key = `${prefix}:${uid}`;
    const now = Date.now();
    const windowStart = now - windowSeconds * 1000;

    try {
      const pipeline = app.redis.pipeline();
      pipeline.zremrangebyscore(key, 0, windowStart);
      pipeline.zcard(key);
      pipeline.zadd(key, now.toString(), `${now}:${Math.random()}`);
      pipeline.expire(key, windowSeconds);

      const results = await pipeline.exec();
      const count = results?.[1]?.[1] as number;

      if (count >= max) {
        reply.status(429).send({
          error: message,
          code,
          retry_after_seconds: windowSeconds,
        });
        return;
      }
    } catch (err) {
      // Redis down — allow request but log the failure
      app.log.warn("Rate limit check failed (Redis unavailable): %s", String(err));
    }
  };
}

/**
 * Daily quota limiter backed by Redis.
 * Falls back to allowing requests if Redis is unavailable.
 */
export function createDailyQuota(
  app: FastifyInstance,
  opts: {
    prefix: string;
    /** Config key in app_config table for the limit */
    configKey: string;
    /** Fallback limit if config key not found */
    defaultLimit: number;
    message?: string;
    code?: string;
  }
) {
  const {
    prefix,
    configKey,
    defaultLimit,
    message = "Daily limit reached. Please try again tomorrow.",
    code = "DAILY_LIMIT_REACHED",
  } = opts;

  return async function dailyQuota(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    const uid = request.user?.uid;
    if (!uid) return;

    // Get configurable limit from app_config
    const configResult = await app.db.query(
      "SELECT value FROM app_config WHERE key = $1",
      [configKey]
    );
    const limit = configResult.rows[0]
      ? parseInt(configResult.rows[0].value, 10)
      : defaultLimit;

    // Key includes today's date so it auto-resets
    const today = new Date().toISOString().slice(0, 10);
    const key = `${prefix}:${uid}:${today}`;

    try {
      const count = await app.redis.get(key);
      const current = count ? parseInt(count, 10) : 0;

      if (current >= limit) {
        reply.status(429).send({
          error: message,
          code,
          daily_limit: limit,
          used: current,
        });
        return;
      }

      // Increment with TTL until next midnight + 1hr buffer
      const now = new Date();
      const tomorrow = new Date(now);
      tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
      tomorrow.setUTCHours(0, 0, 0, 0);
      const ttl = Math.ceil((tomorrow.getTime() - now.getTime()) / 1000) + 3600;

      const pipeline = app.redis.pipeline();
      pipeline.incr(key);
      pipeline.expire(key, ttl);
      await pipeline.exec();
    } catch (err) {
      // Redis down — allow request but log the failure
      app.log.warn("Daily quota check failed (Redis unavailable): %s", String(err));
    }
  };
}
