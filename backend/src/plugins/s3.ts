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
    region: env.AWS_REGION,
    credentials: {
      accessKeyId: env.AWS_ACCESS_KEY_ID,
      secretAccessKey: env.AWS_SECRET_ACCESS_KEY,
    },
  });

  app.decorate("s3", s3);
  app.log.info(`S3 client initialized (region: ${env.AWS_REGION}, bucket: ${env.S3_BUCKET})`);
}

export const s3Plugin = fp(plugin, { name: "s3" });
