import { Queue, Worker } from "bullmq";
import { Pool } from "pg";
import { env } from "../config/env.js";
import { processDailyReminderCheck } from "./processors/daily-reminder-check.js";
import { processDailyDigest } from "./processors/daily-digest.js";

const redisUrl = new URL(env.REDIS_URL);
const connection = {
  host: redisUrl.hostname,
  port: Number(redisUrl.port) || 6379,
  password: redisUrl.password || undefined,
  username: redisUrl.username || undefined,
};

let jobPool: Pool;

export function getJobPool(): Pool {
  if (!jobPool) {
    jobPool = new Pool({
      connectionString: env.DATABASE_URL,
      max: 5,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
    });
  }
  return jobPool;
}

export const renewdQueue = new Queue("renewd-jobs", { connection });

export const renewdWorker = new Worker(
  "renewd-jobs",
  async (job) => {
    switch (job.name) {
      case "daily-reminder-check":
        return processDailyReminderCheck(job);
      case "daily-digest":
        return processDailyDigest(job);
      default:
        throw new Error(`Unknown job type: ${job.name}`);
    }
  },
  { connection, concurrency: 5 }
);

renewdWorker.on("completed", (job) => {
  console.log(`Job ${job.id} (${job.name}) completed`);
});

renewdWorker.on("failed", (job, err) => {
  console.error(`Job ${job?.id} (${job?.name}) failed:`, err.message);
});

/** Graceful shutdown — call from server close hook */
export async function closeJobs(): Promise<void> {
  await renewdWorker.close();
  await renewdQueue.close();
  if (jobPool) await jobPool.end();
}
