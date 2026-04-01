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
    const pool = getJobPool();
    const [{ id: runId }] = (
      await pool.query(
        `INSERT INTO job_runs (job_name, status) VALUES ($1, 'running') RETURNING id`,
        [job.name]
      )
    ).rows;

    const start = Date.now();
    try {
      let result: { processed: number; failed: number } | undefined;
      switch (job.name) {
        case "daily-reminder-check":
          result = await processDailyReminderCheck(job);
          break;
        case "daily-digest":
          result = await processDailyDigest(job);
          break;
        default:
          throw new Error(`Unknown job type: ${job.name}`);
      }

      const durationMs = Date.now() - start;
      await pool.query(
        `UPDATE job_runs
         SET status = 'completed', finished_at = NOW(), duration_ms = $1,
             processed = $2, failed = $3
         WHERE id = $4`,
        [durationMs, result?.processed ?? 0, result?.failed ?? 0, runId]
      );
      console.log(`Job ${job.id} (${job.name}) completed in ${durationMs}ms`);
    } catch (err) {
      const durationMs = Date.now() - start;
      const message = err instanceof Error ? err.message : String(err);
      await pool.query(
        `UPDATE job_runs
         SET status = 'failed', finished_at = NOW(), duration_ms = $1, error = $2
         WHERE id = $3`,
        [durationMs, message, runId]
      );
      console.error(`Job ${job?.id} (${job?.name}) failed:`, message);
      throw err;
    }
  },
  { connection, concurrency: 5 }
);

/** Graceful shutdown — call from server close hook */
export async function closeJobs(): Promise<void> {
  await renewdWorker.close();
  await renewdQueue.close();
  if (jobPool) await jobPool.end();
}
