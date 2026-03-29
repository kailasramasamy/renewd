import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { requireAdminAuth } from "@/lib/auth";

export async function GET() {
  const authError = await requireAdminAuth();
  if (authError) return authError;
  // Count tickets where the latest reply is from a user (needs admin response)
  // or tickets with no replies yet (new tickets)
  const result = await query<{ count: number }>(`
    SELECT COUNT(*)::int AS count FROM support_tickets t
    WHERE t.status IN ('open', 'in_progress')
    AND (
      NOT EXISTS (SELECT 1 FROM ticket_replies r WHERE r.ticket_id = t.id)
      OR (
        SELECT sender FROM ticket_replies r
        WHERE r.ticket_id = t.id
        ORDER BY r.created_at DESC LIMIT 1
      ) = 'user'
    )
  `);

  return NextResponse.json({ count: result[0]?.count ?? 0 });
}
