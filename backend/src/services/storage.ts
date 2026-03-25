import {
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import type { S3Client } from "@aws-sdk/client-s3";
import { env } from "../config/env.js";
import { AppError } from "../lib/errors.js";

const BUCKET = env.DO_SPACES_BUCKET;

export async function uploadFile(
  s3: S3Client,
  key: string,
  body: Buffer,
  mimeType: string
): Promise<string> {
  try {
    await s3.send(new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      Body: body,
      ContentType: mimeType,
      ACL: "private",
    }));

    const cdnBase = env.DO_SPACES_CDN_URL;
    return cdnBase ? `${cdnBase}/${key}` : `${env.DO_SPACES_ENDPOINT}/${BUCKET}/${key}`;
  } catch (err) {
    if (err instanceof Error) {
      throw new AppError(`Upload failed: ${err.message}`, 502, "STORAGE_ERROR");
    }
    throw new AppError("Upload failed", 502, "STORAGE_ERROR");
  }
}

export async function getSignedDownloadUrl(s3: S3Client, key: string, expiresIn = 3600): Promise<string> {
  const command = new GetObjectCommand({ Bucket: BUCKET, Key: key });
  return getSignedUrl(s3, command, { expiresIn });
}

export async function deleteFile(s3: S3Client, key: string): Promise<void> {
  try {
    await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
  } catch (err) {
    if (err instanceof Error) {
      throw new AppError(`Delete failed: ${err.message}`, 502, "STORAGE_ERROR");
    }
    throw new AppError("Delete failed", 502, "STORAGE_ERROR");
  }
}
