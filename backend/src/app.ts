import Fastify from "fastify";
import cors from "@fastify/cors";
import multipart from "@fastify/multipart";
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
import notificationLogRoutes from "./routes/notifications/index.js";
import paymentRoutes from "./routes/payments/index.js";
import userRoutes from "./routes/users/index.js";
import bannerRoutes from "./routes/banners/index.js";
import supportRoutes from "./routes/support/index.js";
import revenueCatWebhookRoutes from "./routes/webhooks/revenuecat.js";

export async function buildApp() {
  const app = Fastify({
    logger: env.NODE_ENV !== "test",
    bodyLimit: 10 * 1024 * 1024,
  });

  app.addContentTypeParser('application/json', { parseAs: 'string' }, (req, body, done) => {
    try {
      const str = (body as string).trim();
      done(null, str ? JSON.parse(str) : undefined);
    } catch (err) {
      done(err as Error, undefined);
    }
  });

  await app.register(cors, {
    origin: env.NODE_ENV === "production"
      ? (process.env.CORS_ORIGIN || false)
      : "http://localhost:3000",
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  });

  await app.register(multipart, { limits: { fileSize: 10 * 1024 * 1024 } });

  await app.register(postgresPlugin);
  await app.register(redisPlugin);

  if (env.FIREBASE_PROJECT_ID) {
    await app.register(firebasePlugin);
  } else {
    app.log.warn("Firebase not configured — auth will be skipped in dev");
  }

  if (env.AWS_ACCESS_KEY_ID) {
    await app.register(s3Plugin);
  } else {
    app.log.warn("AWS S3 not configured — file uploads disabled");
  }

  app.decorate("authenticate", authMiddleware);

  await app.register(healthRoutes, { prefix: "/api/v1" });
  await app.register(authRoutes, { prefix: "/api/v1/auth" });
  await app.register(renewalRoutes, { prefix: "/api/v1/renewals" });
  await app.register(documentRoutes, { prefix: "/api/v1/documents" });
  await app.register(chatRoutes, { prefix: "/api/v1/chat" });
  await app.register(notificationLogRoutes, { prefix: "/api/v1/notifications" });
  await app.register(paymentRoutes, { prefix: "/api/v1/payments" });
  await app.register(userRoutes, { prefix: "/api/v1/users" });
  await app.register(bannerRoutes, { prefix: "/api/v1/banners" });
  await app.register(supportRoutes, { prefix: "/api/v1/support" });
  await app.register(revenueCatWebhookRoutes, { prefix: "/api/v1/webhooks" });

  return app;
}
