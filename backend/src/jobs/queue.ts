import { Queue, Worker } from "bullmq";
import { env } from "../config/env.js";
import { processReminder } from "./processors/reminder.js";

const connection = {
  host: new URL(env.REDIS_URL).hostname,
  port: Number(new URL(env.REDIS_URL).port) || 6379,
};

export const renewdQueue = new Queue("renewd-jobs", { connection });

export const renewdWorker = new Worker(
  "renewd-jobs",
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

renewdWorker.on("completed", (job) => {
  console.log(`Job ${job.id} (${job.name}) completed`);
});

renewdWorker.on("failed", (job, err) => {
  console.error(`Job ${job?.id} (${job?.name}) failed:`, err.message);
});
