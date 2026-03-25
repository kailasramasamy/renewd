import Fastify from "fastify";
import cors from "@fastify/cors";
import { env } from "./config/env.js";
import { postgresPlugin } from "./plugins/postgres.js";
import { redisPlugin } from "./plugins/redis.js";
import { firebasePlugin } from "./plugins/firebase.js";
import { s3Plugin } from "./plugins/s3.js";
import { authMiddleware } from "./middleware/auth.js";
import healthRoutes from "./routes/health/index.js";
import authRoutes from "./routes/auth/index.js";
import renewalRoutes from "./routes/renewals/index.js";
import documentRoutes from "./routes/documents/index.js";
import chatRoutes from "./routes/chat/index.js";
import userRoutes from "./routes/users/index.js";

export async function buildApp() {
  const app = Fastify({
    logger: env.NODE_ENV !== "test",
  });

  await app.register(cors, {
    origin: env.NODE_ENV === "production" ? false : true,
    credentials: true,
  });

  await app.register(postgresPlugin);
  await app.register(redisPlugin);
  await app.register(firebasePlugin);
  await app.register(s3Plugin);

  app.decorate("authenticate", authMiddleware);

  await app.register(healthRoutes, { prefix: "/api/v1" });
  await app.register(authRoutes, { prefix: "/api/v1/auth" });
  await app.register(renewalRoutes, { prefix: "/api/v1/renewals" });
  await app.register(documentRoutes, { prefix: "/api/v1/documents" });
  await app.register(chatRoutes, { prefix: "/api/v1/chat" });
  await app.register(userRoutes, { prefix: "/api/v1/users" });

  return app;
}
