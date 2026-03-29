import type { FastifyInstance } from "fastify";
import { authMiddleware } from "../../middleware/auth.js";
import { AppError } from "../../lib/errors.js";
import { PutObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";
import { env } from "../../config/env.js";
import crypto from "crypto";

export default async function bannerRoutes(app: FastifyInstance) {
  // Public — returns active banners
  app.get("/", async (_request, reply) => {
    const result = await app.db.query(
      `SELECT id, title, subtitle, type, bg_color, bg_gradient_start, bg_gradient_end,
              icon, image_url, deeplink, external_url
       FROM banners
       WHERE is_active = TRUE
         AND (starts_at IS NULL OR starts_at <= NOW())
         AND (ends_at IS NULL OR ends_at > NOW())
       ORDER BY priority DESC, created_at DESC
       LIMIT 10`
    );

    // Convert image_url to serve URL
    const banners = result.rows.map((b: Record<string, unknown>) => ({
      ...b,
      image_url: b.image_url
        ? `/api/v1/banners/${b.id}/image`
        : null,
    }));

    return reply.send({ banners });
  });

  // Upload banner image
  app.post("/upload", { preHandler: authMiddleware }, async (request, reply) => {
    const data = await request.file();
    if (!data) throw new AppError("No file provided", 400, "MISSING_FILE");

    const buffer = await data.toBuffer();
    const ext = data.filename.split(".").pop()?.toLowerCase() ?? "png";
    const key = `banners/${crypto.randomUUID()}.${ext}`;

    await app.s3.send(
      new PutObjectCommand({
        Bucket: env.S3_BUCKET,
        Key: key,
        Body: buffer,
        ContentType: data.mimetype,
      })
    );

    const imageUrl = `s3://${env.S3_BUCKET}/${key}`;
    return reply.send({ image_url: imageUrl });
  });

  // Serve banner image
  app.get("/:id/image", async (request, reply) => {
    const { id } = request.params as { id: string };

    const result = await app.db.query(
      "SELECT image_url FROM banners WHERE id = $1",
      [id]
    );
    if (result.rows.length === 0 || !result.rows[0].image_url) {
      throw new AppError("Image not found", 404, "NOT_FOUND");
    }

    const fileUrl = result.rows[0].image_url as string;
    const key = fileUrl.startsWith("s3://")
      ? fileUrl.split("/").slice(3).join("/")
      : fileUrl;

    const response = await app.s3.send(
      new GetObjectCommand({ Bucket: env.S3_BUCKET, Key: key })
    );

    const body = await response.Body?.transformToByteArray();
    if (!body) throw new AppError("Image not found", 404, "NOT_FOUND");

    return reply
      .type(response.ContentType ?? "image/png")
      .send(Buffer.from(body));
  });
}
