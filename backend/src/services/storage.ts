import {
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import type { S3Client } from "@aws-sdk/client-s3";
import { env } from "../config/env.js";
import { AppError } from "../lib/errors.js";

const BUCKET = env.S3_BUCKET;

export async function uploadToS3(
  s3: S3Client,
  key: string,
  body: Buffer,
  mimeType: string
): Promise<string> {
  await s3.send(new PutObjectCommand({
    Bucket: BUCKET,
    Key: key,
    Body: body,
    ContentType: mimeType,
  }));
  return `s3://${BUCKET}/${key}`;
}

export async function getSignedDownloadUrl(
  s3: S3Client,
  key: string,
  expiresIn = 3600
): Promise<string> {
  const command = new GetObjectCommand({ Bucket: BUCKET, Key: key });
  return getSignedUrl(s3, command, { expiresIn });
}

export async function getFileFromS3(
  s3: S3Client,
  key: string
): Promise<{ buffer: Buffer; contentType: string }> {
  const response = await s3.send(new GetObjectCommand({ Bucket: BUCKET, Key: key }));
  const stream = response.Body;
  if (!stream) throw new AppError("Empty file", 404, "FILE_NOT_FOUND");

  const chunks: Buffer[] = [];
  for await (const chunk of stream as AsyncIterable<Buffer>) {
    chunks.push(chunk);
  }
  return {
    buffer: Buffer.concat(chunks),
    contentType: response.ContentType ?? "application/octet-stream",
  };
}

export async function deleteFromS3(s3: S3Client, key: string): Promise<void> {
  await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
}

export function s3KeyFromUrl(fileUrl: string): string {
  // fileUrl format: "s3://bucket/key" or just the key
  if (fileUrl.startsWith("s3://")) {
    return fileUrl.split("/").slice(3).join("/");
  }
  return fileUrl;
}
