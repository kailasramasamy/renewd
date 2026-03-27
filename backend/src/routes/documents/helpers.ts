import fs from "fs";
import path from "path";
import crypto from "crypto";
import type { FastifyInstance } from "fastify";
import { extractDocumentData } from "../../services/ai.js";
import { AppError } from "../../lib/errors.js";

export const UPLOADS_DIR = path.join(process.cwd(), "uploads");

export function saveFileToDisk(buffer: Buffer, originalName: string): string {
  const ext = path.extname(originalName);
  const uuid = crypto.randomUUID();
  const fileName = `${uuid}${ext}`;
  const filePath = path.join(UPLOADS_DIR, fileName);
  fs.writeFileSync(filePath, buffer);
  return filePath;
}

export function computeHash(buffer: Buffer): string {
  return crypto.createHash("sha256").update(buffer).digest("hex");
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
    filePath: string;
    fileName: string;
    fileSize: number;
    fileHash: string;
    mimeType: string;
    docType: string;
  }
): Promise<Record<string, unknown>> {
  const result = await app.db.query(
    `INSERT INTO documents (user_id, renewal_id, file_url, file_name, file_size, file_hash, mime_type, doc_type, is_current)
     VALUES ((SELECT id FROM users WHERE firebase_uid = $1), $2, $3, $4, $5, $6, $7, $8, true)
     RETURNING *`,
    [
      params.userId,
      params.renewalId ?? null,
      params.filePath,
      params.fileName,
      params.fileSize,
      params.fileHash,
      params.mimeType,
      params.docType ?? "other",
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
  filePath: string,
  mimeType: string,
  fileName: string
): Promise<void> {
  let buffer: Buffer;
  try {
    buffer = fs.readFileSync(filePath);
  } catch (err) {
    if ((err as NodeJS.ErrnoException).code === "ENOENT") {
      app.log.error(`File not found for extraction: ${filePath}`);
      return;
    }
    throw err;
  }

  const extraction = await extractDocumentData(buffer, mimeType, fileName);

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

export function deleteFileFromDisk(filePath: string): void {
  try {
    fs.unlinkSync(filePath);
  } catch (err) {
    if ((err as NodeJS.ErrnoException).code !== "ENOENT") {
      throw new AppError(`Failed to delete file: ${(err as Error).message}`, 500, "FILE_DELETE_ERROR");
    }
  }
}
