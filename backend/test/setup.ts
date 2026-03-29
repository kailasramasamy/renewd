import { buildApp } from "../src/app.js";
import type { FastifyInstance } from "fastify";

let app: FastifyInstance;

export async function getApp(): Promise<FastifyInstance> {
  if (!app) {
    app = await buildApp();
    await app.ready();
  }
  return app;
}

export async function closeApp(): Promise<void> {
  if (app) {
    await app.close();
  }
}

// Dev mode bypasses Firebase auth — requests get user { uid: "dev-user" }
// Ensure the dev user exists in the DB before running tests
export async function ensureDevUser(appInstance: FastifyInstance): Promise<string> {
  const result = await appInstance.db.query(
    "SELECT id FROM users WHERE firebase_uid = 'dev-user'"
  );
  if (result.rows.length > 0) return result.rows[0].id;

  const insert = await appInstance.db.query(
    `INSERT INTO users (firebase_uid, email, name)
     VALUES ('dev-user', 'test@renewd.local', 'Test User')
     RETURNING id`
  );
  return insert.rows[0].id;
}

export async function cleanupTestData(appInstance: FastifyInstance): Promise<void> {
  const userId = await getUserId(appInstance);
  if (!userId) return;

  await appInstance.db.query("DELETE FROM payments WHERE user_id = $1", [userId]);
  await appInstance.db.query(
    "DELETE FROM reminders WHERE renewal_id IN (SELECT id FROM renewals WHERE user_id = $1)",
    [userId]
  );
  await appInstance.db.query("DELETE FROM documents WHERE user_id = $1", [userId]);
  await appInstance.db.query("DELETE FROM renewals WHERE user_id = $1", [userId]);
  await appInstance.db.query("DELETE FROM notification_log WHERE user_id = $1", [userId]);
  await appInstance.db.query("DELETE FROM notification_preferences WHERE user_id = $1", [userId]);
}

async function getUserId(appInstance: FastifyInstance): Promise<string | null> {
  const result = await appInstance.db.query(
    "SELECT id FROM users WHERE firebase_uid = 'dev-user'"
  );
  return result.rows[0]?.id ?? null;
}
