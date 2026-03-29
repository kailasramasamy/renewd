import crypto from "crypto";
import type { FastifyInstance } from "fastify";
import { extractDocumentData } from "../../services/ai.js";
import { maskExtractionJson } from "../../services/masking.js";
import { uploadToS3, getFileFromS3, s3KeyFromUrl } from "../../services/storage.js";

export function computeHash(buffer: Buffer): string {
  return crypto.createHash("sha256").update(buffer).digest("hex");
}

export function generateS3Key(userId: string, originalName: string): string {
  const ext = originalName.split(".").pop() ?? "bin";
  return `renewd/${userId}/documents/${crypto.randomUUID()}.${ext}`;
}

export async function saveFileToS3(
  app: FastifyInstance,
  buffer: Buffer,
  originalName: string,
  mimeType: string,
  userId: string
): Promise<string> {
  const key = generateS3Key(userId, originalName);
  return uploadToS3(app.s3, key, buffer, mimeType);
}

export async function findDuplicateDocument(
  app: FastifyInstance,
  userId: string,
  hash: string
): Promise<Record<string, unknown> | null> {
  const result = await app.db.query(
    "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE u.firebase_uid = $1 AND d.file_hash = $2",
    [userId, hash]
  );
  return result.rows[0] ?? null;
}

export async function insertDocument(
  app: FastifyInstance,
  params: {
    userId: string;
    renewalId: string | null;
    fileUrl: string;
    fileName: string;
    fileSize: number;
    fileHash: string;
    mimeType: string;
    docType: string;
  }
): Promise<Record<string, unknown>> {
  const result = await app.db.query(
    `INSERT INTO documents (user_id, renewal_id, file_url, file_name, file_size, file_hash, mime_type, doc_type, is_current)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, true)
     RETURNING *`,
    [
      params.userId, params.renewalId ?? null, params.fileUrl,
      params.fileName, params.fileSize, params.fileHash,
      params.mimeType, params.docType ?? "other",
    ]
  );
  return result.rows[0];
}

export async function deactivatePreviousDoc(
  app: FastifyInstance,
  renewalId: string,
  newDocId: string
): Promise<void> {
  await app.db.query(
    "UPDATE documents SET is_current = false WHERE renewal_id = $1 AND id != $2",
    [renewalId, newDocId]
  );
}

export async function runExtractionAndSave(
  app: FastifyInstance,
  docId: string,
  fileUrl: string,
  mimeType: string,
  fileName: string
): Promise<void> {
  const key = s3KeyFromUrl(fileUrl);
  const { buffer } = await getFileFromS3(app.s3, key);
  const rawExtraction = await extractDocumentData(buffer, mimeType, fileName);
  const extraction = maskExtractionJson(rawExtraction);

  await app.db.query(
    `UPDATE documents SET ocr_text = $1, issue_date = COALESCE($2, issue_date), expiry_date = COALESCE($3, expiry_date)
     WHERE id = $4`,
    [
      JSON.stringify(extraction),
      (extraction.issue_date as string) ?? null,
      (extraction.expiry_date as string) ?? null,
      docId,
    ]
  );
}
