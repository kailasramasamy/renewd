import fp from "fastify-plugin";
import admin from "firebase-admin";
import type { FastifyInstance } from "fastify";
import { env } from "../config/env.js";

declare module "fastify" {
  interface FastifyInstance {
    firebase: admin.app.App;
  }
}

async function plugin(app: FastifyInstance) {
  const firebaseApp = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
    }),
  });

  app.decorate("firebase", firebaseApp);
  app.log.info("Firebase Admin initialized");
}

export const firebasePlugin = fp(plugin, { name: "firebase" });
