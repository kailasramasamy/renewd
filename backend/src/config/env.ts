import "dotenv/config";
import { z } from "zod";

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  DATABASE_URL: z.string().min(1, "DATABASE_URL is required"),
  REDIS_URL: z.string().min(1, "REDIS_URL is required"),
  FIREBASE_PROJECT_ID: z.string().min(1, "FIREBASE_PROJECT_ID is required"),
  FIREBASE_CLIENT_EMAIL: z.string().email("FIREBASE_CLIENT_EMAIL must be a valid email"),
  FIREBASE_PRIVATE_KEY: z.string().min(1, "FIREBASE_PRIVATE_KEY is required"),
  DO_SPACES_ENDPOINT: z.string().url("DO_SPACES_ENDPOINT must be a valid URL"),
  DO_SPACES_BUCKET: z.string().min(1, "DO_SPACES_BUCKET is required"),
  DO_SPACES_KEY: z.string().min(1, "DO_SPACES_KEY is required"),
  DO_SPACES_SECRET: z.string().min(1, "DO_SPACES_SECRET is required"),
  DO_SPACES_CDN_URL: z.string().url("DO_SPACES_CDN_URL must be a valid URL").optional(),
  CLAUDE_API_KEY: z.string().min(1, "CLAUDE_API_KEY is required"),
  GOOGLE_VISION_KEY: z.string().optional(),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  const errors = parsed.error.flatten().fieldErrors;
  console.error("Invalid environment variables:", JSON.stringify(errors, null, 2));
  process.exit(1);
}

export const env = parsed.data;
export type Env = typeof env;
