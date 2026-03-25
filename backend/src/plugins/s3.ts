import fp from "fastify-plugin";
import { S3Client } from "@aws-sdk/client-s3";
import type { FastifyInstance } from "fastify";
import { env } from "../config/env.js";

declare module "fastify" {
  interface FastifyInstance {
    s3: S3Client;
  }
}

async function plugin(app: FastifyInstance) {
  const s3 = new S3Client({
    endpoint: env.DO_SPACES_ENDPOINT,
    region: "blr1",
    credentials: {
      accessKeyId: env.DO_SPACES_KEY,
      secretAccessKey: env.DO_SPACES_SECRET,
    },
    forcePathStyle: false,
  });

  app.decorate("s3", s3);
  app.log.info("S3 client (DO Spaces) initialized");
}

export const s3Plugin = fp(plugin, { name: "s3" });
