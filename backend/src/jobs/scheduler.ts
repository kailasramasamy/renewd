import { renewdQueue } from "./queue.js";

export async function initScheduler(): Promise<void> {
  const existing = await renewdQueue.getRepeatableJobs();
  for (const job of existing) {
    await renewdQueue.removeRepeatableByKey(job.key);
  }

  await renewdQueue.add("daily-reminder-check", {}, {
    repeat: { pattern: "0 8 * * *" },
    removeOnComplete: 100,
    removeOnFail: 50,
  });

  await renewdQueue.add("daily-digest", {}, {
    repeat: { pattern: "0 9 * * *" },
    removeOnComplete: 50,
    removeOnFail: 50,
  });

  console.log("[Scheduler] Repeatable jobs registered");
}
