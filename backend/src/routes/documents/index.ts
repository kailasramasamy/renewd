import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { NotFoundError, AppError } from "../../lib/errors.js";
import { extractDocumentData } from "../../services/ai.js";
import { getFileFromS3, deleteFromS3, s3KeyFromUrl } from "../../services/storage.js";
import {
  saveFileToS3,
  computeHash,
  findDuplicateDocument,
  insertDocument,
  deactivatePreviousDoc,
  runExtractionAndSave,
} from "./helpers.js";

const auth = { preHandler: authMiddleware };

async function registerUpload(app: FastifyInstance) {
  app.post("/upload", auth, async (request, reply) => {
    const data = await request.file();
    if (!data) throw new AppError("No file provided", 400, "MISSING_FILE");

    const buffer = await data.toBuffer();
    const hash = computeHash(buffer);

    const duplicate = await findDuplicateDocument(app, request.user.uid, hash);
    if (duplicate) {
      return reply.status(409).send({
        error: "Duplicate file", code: "DUPLICATE_DOCUMENT", document: duplicate,
      });
    }

    const renewalId = (data.fields.renewal_id as { value: string } | undefined)?.value ?? null;
    const docType = (data.fields.doc_type as { value: string } | undefined)?.value ?? "other";

    const fileUrl = await saveFileToS3(app, buffer, data.filename, data.mimetype, request.user.uid);

    const doc = await insertDocument(app, {
      userId: request.user.uid,
      renewalId,
      fileUrl,
      fileName: data.filename,
      fileSize: buffer.length,
      fileHash: hash,
      mimeType: data.mimetype,
      docType,
    });

    if (renewalId) {
      await deactivatePreviousDoc(app, renewalId, doc.id as string);
    }

    setImmediate(() => {
      runExtractionAndSave(app, doc.id as string, fileUrl, data.mimetype, data.filename)
        .catch((err) => app.log.error({ err }, "Background AI extraction failed"));
    });

    return reply.status(201).send({ document: doc });
  });
}

async function registerParse(app: FastifyInstance) {
  app.post("/:id/parse", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const docResult = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE d.id = $1 AND u.firebase_uid = $2",
      [id, request.user.uid]
    );
    if (docResult.rows.length === 0) throw new NotFoundError("Document");

    const doc = docResult.rows[0];
    const key = s3KeyFromUrl(doc.file_url);
    const { buffer } = await getFileFromS3(app.s3, key);
    const extraction = await extractDocumentData(buffer, doc.mime_type, doc.file_name);

    const updateResult = await app.db.query(
      `UPDATE documents SET ocr_text = $1, issue_date = COALESCE($2, issue_date), expiry_date = COALESCE($3, expiry_date)
       WHERE id = $4 RETURNING *`,
      [JSON.stringify(extraction), (extraction.issue_date as string) ?? null,
       (extraction.expiry_date as string) ?? null, id]
    );

    return reply.send({ document: updateResult.rows[0], extraction });
  });
}

async function registerQueries(app: FastifyInstance) {
  app.get("/", auth, async (request, reply) => {
    const result = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE u.firebase_uid = $1 ORDER BY d.created_at DESC",
      [request.user.uid]
    );
    return reply.send({ documents: result.rows, total: result.rowCount });
  });

  app.get("/by-renewal/:renewalId", auth, async (request, reply) => {
    const { renewalId } = request.params as { renewalId: string };
    const result = await app.db.query(
      `SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id
       WHERE u.firebase_uid = $1 AND d.renewal_id = $2 ORDER BY d.created_at DESC`,
      [request.user.uid, renewalId]
    );
    return reply.send({ documents: result.rows, total: result.rowCount });
  });

  app.get("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE d.id = $1 AND u.firebase_uid = $2",
      [id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Document");
    return reply.send({ document: result.rows[0] });
  });
}

async function registerFileServe(app: FastifyInstance) {
  app.get("/:id/file", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE d.id = $1 AND u.firebase_uid = $2",
      [id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Document");

    const doc = result.rows[0];
    const key = s3KeyFromUrl(doc.file_url);
    const { buffer, contentType } = await getFileFromS3(app.s3, key);
    return reply.type(contentType).send(buffer);
  });
}

async function registerDelete(app: FastifyInstance) {
  app.delete("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await app.db.query(
      "DELETE FROM documents WHERE id = $1 AND user_id = (SELECT id FROM users WHERE firebase_uid = $2) RETURNING id, file_url",
      [id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Document");

    const key = s3KeyFromUrl(result.rows[0].file_url);
    await deleteFromS3(app.s3, key).catch((err) =>
      app.log.error({ err }, "Failed to delete file from S3")
    );

    return reply.send({ deleted: true, id: result.rows[0].id });
  });
}

export default async function documentRoutes(app: FastifyInstance) {
  await registerUpload(app);
  await registerParse(app);
  await registerQueries(app);
  await registerFileServe(app);
  await registerDelete(app);
}
