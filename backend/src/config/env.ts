import "dotenv/config";
import { z } from "zod";

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  DATABASE_URL: z.string().min(1, "DATABASE_URL is required"),
  REDIS_URL: z.string().min(1, "REDIS_URL is required"),
  FIREBASE_PROJECT_ID: z.string().default(""),
  FIREBASE_CLIENT_EMAIL: z.string().default(""),
  FIREBASE_PRIVATE_KEY: z.string().default(""),
  AWS_ACCESS_KEY_ID: z.string().default(""),
  AWS_SECRET_ACCESS_KEY: z.string().default(""),
  AWS_REGION: z.string().default("us-east-1"),
  S3_BUCKET: z.string().default("renewd-documents"),
  CLAUDE_API_KEY: z.string().default(""),
  CLAUDE_MODEL: z.string().default("claude-haiku-4-5-20251001"),
  GOOGLE_VISION_KEY: z.string().default(""),
  REVENUECAT_WEBHOOK_SECRET: z.string().default(""),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  const errors = parsed.error.flatten().fieldErrors;
  console.error("Invalid environment variables:", JSON.stringify(errors, null, 2));
  process.exit(1);
}

export const env = parsed.data;
export type Env = typeof env;
