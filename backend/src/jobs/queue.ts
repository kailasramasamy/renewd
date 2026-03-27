import { Queue, Worker } from "bullmq";
import { Pool } from "pg";
import { env } from "../config/env.js";
import { processDailyReminderCheck } from "./processors/daily-reminder-check.js";
import { processDailyDigest } from "./processors/daily-digest.js";

const connection = {
  host: new URL(env.REDIS_URL).hostname,
  port: Number(new URL(env.REDIS_URL).port) || 6379,
};

let jobPool: Pool;

export function getJobPool(): Pool {
  if (!jobPool) {
    jobPool = new Pool({ connectionString: env.DATABASE_URL });
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
  { connection }
);

renewdWorker.on("completed", (job) => {
  console.log(`Job ${job.id} (${job.name}) completed`);
});

renewdWorker.on("failed", (job, err) => {
  console.error(`Job ${job?.id} (${job?.name}) failed:`, err.message);
});
