import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { NotFoundError } from "../../lib/errors.js";

export default async function documentRoutes(app: FastifyInstance) {
  const auth = { preHandler: authMiddleware };

  app.post("/upload", auth, async (request, reply) => {
    // TODO: Handle multipart upload, store in DO Spaces, save metadata to DB
    return reply.status(202).send({
      message: "Upload accepted",
      status: "pending",
    });
  });

  app.get("/", auth, async (request, reply) => {
    const result = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE u.firebase_uid = $1 ORDER BY d.created_at DESC",
      [request.user.uid]
    );
    return reply.send({ documents: result.rows, total: result.rowCount });
  });

  app.get("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await app.db.query(
      "SELECT d.* FROM documents d JOIN users u ON u.id = d.user_id WHERE d.id=$1 AND u.firebase_uid=$2",
      [id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Document");
    return reply.send({ document: result.rows[0] });
  });

  app.delete("/:id", auth, async (request, reply) => {
    const { id } = request.params as { id: string };
    const result = await app.db.query(
      "DELETE FROM documents WHERE id=$1 AND user_id=(SELECT id FROM users WHERE firebase_uid=$2) RETURNING id",
      [id, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("Document");
    return reply.send({ deleted: true, id: result.rows[0].id });
  });
}
