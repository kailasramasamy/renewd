import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { NotFoundError } from "../../lib/errors.js";

export default async function userRoutes(app: FastifyInstance) {
  const auth = { preHandler: authMiddleware };

  app.get("/me", auth, async (request, reply) => {
    const result = await app.db.query(
      "SELECT * FROM users WHERE firebase_uid = $1",
      [request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("User");
    return reply.send({ user: result.rows[0] });
  });

  app.patch("/me", auth, async (request, reply) => {
    const body = request.body as Record<string, unknown>;
    const { name, phone, avatar_url } = body;

    const result = await app.db.query(
      `UPDATE users SET
        name = COALESCE($1, name),
        phone = COALESCE($2, phone),
        avatar_url = COALESCE($3, avatar_url),
        updated_at = NOW()
       WHERE firebase_uid = $4 RETURNING *`,
      [name ?? null, phone ?? null, avatar_url ?? null, request.user.uid]
    );
    if (result.rows.length === 0) throw new NotFoundError("User");
    return reply.send({ user: result.rows[0] });
  });
}
