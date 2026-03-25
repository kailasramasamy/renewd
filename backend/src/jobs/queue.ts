import { Queue, Worker } from "bullmq";
import { env } from "../config/env.js";
import { processReminder } from "./processors/reminder.js";

const connection = {
  host: new URL(env.REDIS_URL).hostname,
  port: Number(new URL(env.REDIS_URL).port) || 6379,
};

export const minderQueue = new Queue("minder-jobs", { connection });

export const minderWorker = new Worker(
  "minder-jobs",
  async (job) => {
    switch (job.name) {
      case "reminder":
        return processReminder(job);
      default:
        throw new Error(`Unknown job type: ${job.name}`);
    }
  },
  { connection }
);

minderWorker.on("completed", (job) => {
  console.log(`Job ${job.id} (${job.name}) completed`);
});

minderWorker.on("failed", (job, err) => {
  console.error(`Job ${job?.id} (${job?.name}) failed:`, err.message);
});
