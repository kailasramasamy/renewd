import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { chat } from "../../services/ai.js";
import { ValidationError } from "../../lib/errors.js";

export default async function chatRoutes(app: FastifyInstance) {
  app.post("/", { preHandler: authMiddleware }, async (request, reply) => {
    const body = request.body as { message?: string; context?: string };

    if (!body.message || typeof body.message !== "string") {
      throw new ValidationError("message is required and must be a string");
    }

    const response = await chat(body.message, body.context);

    return reply.send({
      reply: response,
      timestamp: new Date().toISOString(),
    });
  });
}
