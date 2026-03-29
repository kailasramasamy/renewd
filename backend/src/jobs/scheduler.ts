import { renewdQueue } from "./queue.js";
import Redis from "ioredis";
import { env } from "../config/env.js";

const LOCK_KEY = "renewd:scheduler:lock";
const LOCK_TTL = 60; // seconds

/**
 * Initialize scheduled jobs using a distributed lock.
 * Only one instance will register the repeatable jobs.
 * Others will skip gracefully.
 */
export async function initScheduler(): Promise<void> {
  const redis = new Redis(env.REDIS_URL);

  try {
    // Try to acquire lock — only one instance wins
    const acquired = await redis.set(LOCK_KEY, process.pid.toString(), "EX", LOCK_TTL, "NX");
    if (!acquired) {
      console.log("[Scheduler] Another instance holds the lock — skipping registration");
      return;
    }

    // Clean up old repeatable jobs
    const existing = await renewdQueue.getRepeatableJobs();
    for (const job of existing) {
      await renewdQueue.removeRepeatableByKey(job.key);
    }

    await renewdQueue.add("daily-reminder-check", {}, {
      repeat: { pattern: "0 8 * * *" },
      removeOnComplete: { age: 3600 },    // Keep completed jobs 1 hour
      removeOnFail: { age: 86400 },       // Keep failed jobs 24 hours
    });

    await renewdQueue.add("daily-digest", {}, {
      repeat: { pattern: "0 9 * * *" },
      removeOnComplete: { age: 3600 },
      removeOnFail: { age: 86400 },
    });

    console.log("[Scheduler] Repeatable jobs registered");
  } finally {
    await redis.quit();
  }
}
