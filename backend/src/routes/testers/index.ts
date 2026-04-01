import { FastifyInstance } from "fastify";

interface SignupBody {
  name: string;
  email: string;
  platform: string;
  device_info?: string;
}

interface FeedbackBody {
  category: string;
  title: string;
  description: string;
}

export default async function testerRoutes(app: FastifyInstance) {
  // GET /api/v1/testers/programs/:id — public program info
  app.get("/programs/:id", async (request, reply) => {
    const { id } = request.params as { id: string };

    const [program] = (
      await app.db.query(
        `SELECT id, app_name, description, reward, platforms, tester_cap, status,
                android_test_link, ios_test_link
         FROM tester_programs WHERE id = $1`,
        [id]
      )
    ).rows;

    if (!program) {
      return reply.status(404).send({ error: "Program not found" });
    }

    const [{ count }] = (
      await app.db.query(
        "SELECT COUNT(*)::int AS count FROM testers WHERE program_id = $1",
        [id]
      )
    ).rows;

    return reply.send({
      ...program,
      spots_taken: count,
      spots_remaining: Math.max(0, program.tester_cap - count),
    });
  });

  // POST /api/v1/testers/programs/:id/signup — join as tester
  app.post("/programs/:id/signup", async (request, reply) => {
    const { id } = request.params as { id: string };
    const { name, email, platform, device_info } = request.body as SignupBody;

    if (!name?.trim() || !email?.trim() || !platform?.trim()) {
      return reply.status(400).send({ error: "Name, email, and platform are required" });
    }

    const [program] = (
      await app.db.query(
        "SELECT id, tester_cap, status, platforms FROM tester_programs WHERE id = $1",
        [id]
      )
    ).rows;

    if (!program) {
      return reply.status(404).send({ error: "Program not found" });
    }

    if (program.status !== "open") {
      return reply.status(400).send({ error: "This program is no longer accepting testers" });
    }

    if (!program.platforms.includes(platform)) {
      return reply.status(400).send({ error: `Platform ${platform} is not available for this program` });
    }

    const [{ count }] = (
      await app.db.query(
        "SELECT COUNT(*)::int AS count FROM testers WHERE program_id = $1",
        [id]
      )
    ).rows;

    if (count >= program.tester_cap) {
      return reply.status(400).send({ error: "All tester spots have been filled" });
    }

    try {
      const [tester] = (
        await app.db.query(
          `INSERT INTO testers (program_id, name, email, platform, device_info)
           VALUES ($1, $2, $3, $4, $5)
           RETURNING id`,
          [id, name.trim(), email.trim().toLowerCase(), platform, device_info?.trim() || null]
        )
      ).rows;

      // Auto-close if cap reached
      if (count + 1 >= program.tester_cap) {
        await app.db.query(
          "UPDATE tester_programs SET status = 'closed', updated_at = NOW() WHERE id = $1",
          [id]
        );
      }

      return reply.status(201).send({ id: tester.id, success: true });
    } catch (err: unknown) {
      if (err instanceof Error && err.message.includes("testers_program_id_email_key")) {
        return reply.status(409).send({ error: "You have already signed up for this program" });
      }
      throw err;
    }
  });

  // POST /api/v1/testers/lookup — find tester by email
  app.post("/lookup", async (request, reply) => {
    const { email } = request.body as { email: string };

    if (!email?.trim()) {
      return reply.status(400).send({ error: "Email is required" });
    }

    const [tester] = (
      await app.db.query(
        `SELECT t.id, t.name, t.email, t.platform, t.status, t.created_at,
                p.app_name, p.android_test_link, p.ios_test_link
         FROM testers t
         JOIN tester_programs p ON p.id = t.program_id
         WHERE LOWER(t.email) = LOWER($1)
         ORDER BY t.created_at DESC LIMIT 1`,
        [email.trim()]
      )
    ).rows;

    if (!tester) {
      return reply.status(404).send({ error: "No tester found with this email. Please sign up first." });
    }

    const feedback = (
      await app.db.query(
        `SELECT id, category, title, description, created_at
         FROM tester_feedback WHERE tester_id = $1
         ORDER BY created_at DESC`,
        [tester.id]
      )
    ).rows;

    return reply.send({ ...tester, feedback });
  });

  // GET /api/v1/testers/:testerId — tester info + program details
  app.get("/:testerId", async (request, reply) => {
    const { testerId } = request.params as { testerId: string };

    const [tester] = (
      await app.db.query(
        `SELECT t.id, t.name, t.email, t.platform, t.status, t.created_at,
                p.app_name, p.android_test_link, p.ios_test_link
         FROM testers t
         JOIN tester_programs p ON p.id = t.program_id
         WHERE t.id = $1`,
        [testerId]
      )
    ).rows;

    if (!tester) {
      return reply.status(404).send({ error: "Tester not found" });
    }

    const feedback = (
      await app.db.query(
        `SELECT id, category, title, description, created_at
         FROM tester_feedback WHERE tester_id = $1
         ORDER BY created_at DESC`,
        [testerId]
      )
    ).rows;

    return reply.send({ ...tester, feedback });
  });

  // POST /api/v1/testers/:testerId/feedback — submit feedback
  app.post("/:testerId/feedback", async (request, reply) => {
    const { testerId } = request.params as { testerId: string };
    const { category, title, description } = request.body as FeedbackBody;

    if (!title?.trim() || !description?.trim()) {
      return reply.status(400).send({ error: "Title and description are required" });
    }

    const validCategories = ["bug", "suggestion", "general"];
    const cat = validCategories.includes(category) ? category : "general";

    const [tester] = (
      await app.db.query(
        "SELECT id, program_id, status FROM testers WHERE id = $1",
        [testerId]
      )
    ).rows;

    if (!tester) {
      return reply.status(404).send({ error: "Tester not found" });
    }

    if (tester.status !== "active") {
      return reply.status(400).send({ error: "Your tester access is no longer active" });
    }

    const [fb] = (
      await app.db.query(
        `INSERT INTO tester_feedback (tester_id, program_id, category, title, description)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id`,
        [testerId, tester.program_id, cat, title.trim(), description.trim()]
      )
    ).rows;

    return reply.status(201).send({ id: fb.id, success: true });
  });
}
