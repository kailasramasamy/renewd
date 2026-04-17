import { buildApp } from "./app.js";
import { env } from "./config/env.js";
import { initScheduler } from "./jobs/scheduler.js";
import { closeJobs } from "./jobs/queue.js";

async function start() {
  const app = await buildApp();

  // Graceful shutdown
  app.addHook("onClose", async () => {
    await closeJobs();
  });

  try {
    await app.listen({ port: env.PORT, host: "0.0.0.0" });
    console.log(`Server running on port ${env.PORT}`);
    try {
      await initScheduler();
    } catch (err) {
      console.error("[Scheduler] Failed to initialize:", err);
    }
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

start();
