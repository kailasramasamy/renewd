import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { createRequirePremium } from "../../middleware/premium.js";
import { NotFoundError, AppError, ValidationError } from "../../lib/errors.js";
import { extractDocumentData } from "../../services/ai.js";
import { maskExtractionJson } from "../../services/masking.js";
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
  const requirePremium = createRequirePremium(app, "document_vault");

  app.post("/upload", { preHandler: [authMiddleware, requirePremium] }, async (request, reply) => {
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

    // AI extraction is triggered explicitly by the frontend via POST /:id/parse
    // so it can check relevance before saving

    return reply.status(201).send({ document: doc });
  });
}

async function registerParse(app: FastifyInstance) {
  const requirePremium = createRequirePremium(app, "ai_scan");

  app.post("/:id/parse", { preHandler: [authMiddleware, requirePremium] }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const docResult = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE d.id = $1 AND u.firebase_uid = $2",
      [id, request.user.uid]
    );
    if (docResult.rows.length === 0) throw new NotFoundError("Document");

    const doc = docResult.rows[0];
    const key = s3KeyFromUrl(doc.file_url);
    const { buffer } = await getFileFromS3(app.s3, key);
    const rawExtraction = await extractDocumentData(buffer, doc.mime_type, doc.file_name);
    const extraction = maskExtractionJson(rawExtraction);

    // Only save extraction to DB if the document is relevant
    const isRelevant = extraction.is_relevant !== false;
    if (isRelevant) {
      const updateResult = await app.db.query(
        `UPDATE documents SET ocr_text = $1, issue_date = COALESCE($2, issue_date), expiry_date = COALESCE($3, expiry_date)
         WHERE id = $4 RETURNING *`,
        [JSON.stringify(extraction), (extraction.issue_date as string) ?? null,
         (extraction.expiry_date as string) ?? null, id]
      );
      return reply.send({ document: updateResult.rows[0], extraction });
    }

    // Return extraction without saving — frontend decides
    return reply.send({ document: doc, extraction });
  });
}

async function registerQueries(app: FastifyInstance) {
  app.get("/", auth, async (request, reply) => {
    const result = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE u.firebase_uid = $1 ORDER BY d.created_at DESC LIMIT 200",
      [request.user.uid]
    );
    return reply.send({ documents: result.rows, total: result.rowCount });
  });

  app.get("/search", auth, async (request, reply) => {
    const { q } = request.query as { q?: string };
    if (!q || q.trim().length === 0) {
      return reply.send({ documents: [], total: 0 });
    }

    const result = await app.db.query(
      `SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id
       WHERE u.firebase_uid = $1
         AND (d.file_name ILIKE $2
           OR d.doc_type ILIKE $2
           OR to_tsvector('english', COALESCE(d.ocr_text, '')) @@ plainto_tsquery('english', $3))
       ORDER BY d.created_at DESC`,
      [request.user.uid, `%${q}%`, q]
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

async function registerLink(app: FastifyInstance) {
  app.post("/:id/link", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { renewal_id } = request.body as { renewal_id: string };
    const result = await app.db.query(
      `UPDATE documents SET renewal_id = $1, is_current = true
       WHERE id = $2 AND user_id = (SELECT id FROM users WHERE firebase_uid = $3) RETURNING *`,
      [renewal_id, id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Document");
    return reply.send({ document: result.rows[0] });
  });
}

async function registerSuggestLink(app: FastifyInstance) {
  app.get("/:id/suggest-link", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const docResult = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE d.id = $1 AND u.firebase_uid = $2",
      [id, request.user.uid]
    );
    if (docResult.rows.length === 0) throw new NotFoundError("Document");

    const doc = docResult.rows[0];
    let provider: string | null = null;

    if (doc.ocr_text) {
      try {
        const parsed = JSON.parse(doc.ocr_text);
        provider = parsed.provider ?? null;
      } catch { /* not JSON */ }
    }

    const conditions: string[] = [];
    const params: unknown[] = [request.user.uid];

    if (provider) {
      params.push(`%${provider}%`);
      conditions.push(`(r.provider ILIKE $${params.length} OR r.name ILIKE $${params.length})`);
    }
    if (doc.file_name) {
      params.push(`%${doc.file_name.split('.')[0].replace(/[_-]/g, '%')}%`);
      conditions.push(`(r.name ILIKE $${params.length} OR r.provider ILIKE $${params.length})`);
    }

    if (conditions.length === 0) {
      return reply.send({ suggestions: [] });
    }

    const result = await app.db.query(
      `SELECT r.id, r.name, r.provider, r.category FROM renewals r
       JOIN users u ON u.id = r.user_id
       WHERE u.firebase_uid = $1 AND (${conditions.join(" OR ")})
       ORDER BY r.name ASC LIMIT 5`,
      params
    );

    return reply.send({ suggestions: result.rows });
  });
}

async function registerRename(app: FastifyInstance) {
  app.put("/:id/rename", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { file_name } = request.body as { file_name: string };
    if (!file_name) throw new ValidationError("file_name is required");

    const result = await app.db.query(
      "UPDATE documents SET file_name = $1 WHERE id = $2 AND user_id = (SELECT id FROM users WHERE firebase_uid = $3) RETURNING *",
      [file_name, id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Document");
    return reply.send({ document: result.rows[0] });
  });
}

async function registerDelete(app: FastifyInstance) {
  app.delete("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    // Clear any payment references to this document
    await app.db.query(
      "UPDATE payments SET receipt_document_id = NULL WHERE receipt_document_id = $1",
      [id]
    );
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
  await registerLink(app);
  await registerSuggestLink(app);
  await registerRename(app);
  await registerDelete(app);
}
