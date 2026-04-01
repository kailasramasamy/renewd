import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { requireAdminAuth } from "@/lib/auth";

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const authError = await requireAdminAuth();
  if (authError) return authError;

  const { id } = await params;

  const [
    user,
    renewalsByCategory,
    renewalsByStatus,
    renewalsByProvider,
    documents,
    storageUsage,
    paymentsByCategory,
    paymentsByMonth,
    aiUsage,
    aiUsageByMonth,
    notifications,
    supportTickets,
    reminders,
  ] = await Promise.all([
    // User profile
    query(
      `SELECT id, name, email, phone, device_os, device_model, app_version,
              is_premium, premium_expires_at::text, default_currency, country,
              created_at::text, updated_at::text
       FROM users WHERE id = $1`,
      [id]
    ),
    // Renewals by category
    query(
      `SELECT category, COUNT(*)::int AS count,
              COALESCE(SUM(amount), 0)::numeric AS total_amount
       FROM renewals WHERE user_id = $1
       GROUP BY category ORDER BY count DESC`,
      [id]
    ),
    // Renewals by status
    query(
      `SELECT status, COUNT(*)::int AS count
       FROM renewals WHERE user_id = $1
       GROUP BY status`,
      [id]
    ),
    // Top providers
    query(
      `SELECT COALESCE(provider, 'Unknown') AS provider, category,
              COUNT(*)::int AS count
       FROM renewals WHERE user_id = $1
       GROUP BY provider, category ORDER BY count DESC LIMIT 15`,
      [id]
    ),
    // Document stats
    query(
      `SELECT COUNT(*)::int AS total_files,
              COUNT(DISTINCT mime_type) AS mime_types,
              json_agg(DISTINCT mime_type) FILTER (WHERE mime_type IS NOT NULL) AS types
       FROM documents WHERE user_id = $1`,
      [id]
    ),
    // Storage usage
    query(
      `SELECT COALESCE(SUM(file_size), 0)::bigint AS total_bytes,
              COUNT(*)::int AS file_count
       FROM documents WHERE user_id = $1`,
      [id]
    ),
    // Payments by category
    query(
      `SELECT r.category, COUNT(p.id)::int AS count,
              COALESCE(SUM(p.amount), 0)::numeric AS total_amount
       FROM payments p
       JOIN renewals r ON r.id = p.renewal_id
       WHERE p.user_id = $1
       GROUP BY r.category ORDER BY total_amount DESC`,
      [id]
    ),
    // Payments by month (last 12 months)
    query(
      `SELECT to_char(paid_date, 'YYYY-MM') AS month,
              COUNT(*)::int AS count,
              SUM(amount)::numeric AS total_amount
       FROM payments WHERE user_id = $1
         AND paid_date >= NOW() - INTERVAL '12 months'
       GROUP BY month ORDER BY month`,
      [id]
    ),
    // AI usage totals
    query(
      `SELECT COUNT(*)::int AS total_messages,
              COALESCE(SUM(input_tokens), 0)::bigint AS total_input_tokens,
              COALESCE(SUM(output_tokens), 0)::bigint AS total_output_tokens
       FROM chat_usage WHERE user_id = $1`,
      [id]
    ),
    // AI usage by month (last 6 months)
    query(
      `SELECT to_char(created_at, 'YYYY-MM') AS month,
              COUNT(*)::int AS messages,
              COALESCE(SUM(input_tokens), 0)::bigint AS input_tokens,
              COALESCE(SUM(output_tokens), 0)::bigint AS output_tokens
       FROM chat_usage WHERE user_id = $1
         AND created_at >= NOW() - INTERVAL '6 months'
       GROUP BY month ORDER BY month`,
      [id]
    ),
    // Notifications
    query(
      `SELECT COUNT(*)::int AS total,
              COUNT(*) FILTER (WHERE is_read)::int AS read_count,
              COUNT(*) FILTER (WHERE NOT is_read)::int AS unread_count
       FROM notification_log WHERE user_id = $1`,
      [id]
    ),
    // Support tickets
    query(
      `SELECT COUNT(*)::int AS total,
              COUNT(*) FILTER (WHERE status = 'open')::int AS open_count,
              COUNT(*) FILTER (WHERE status = 'resolved')::int AS resolved_count
       FROM support_tickets WHERE user_id = $1`,
      [id]
    ),
    // Reminders
    query(
      `SELECT COUNT(*)::int AS total,
              COUNT(*) FILTER (WHERE is_sent)::int AS sent_count,
              COUNT(*) FILTER (WHERE snoozed_until IS NOT NULL)::int AS snoozed_count
       FROM reminders WHERE user_id = $1`,
      [id]
    ),
  ]);

  if (!user.length) {
    return NextResponse.json({ error: "User not found" }, { status: 404 });
  }

  const ai = aiUsage[0] || { total_messages: 0, total_input_tokens: 0, total_output_tokens: 0 };
  const inputCost = (Number(ai.total_input_tokens) / 1_000_000) * 0.80;
  const outputCost = (Number(ai.total_output_tokens) / 1_000_000) * 4.0;

  return NextResponse.json({
    user: user[0],
    renewals: {
      byCategory: renewalsByCategory,
      byStatus: renewalsByStatus,
      byProvider: renewalsByProvider,
      total: renewalsByCategory.reduce((s: number, r: Record<string, unknown>) => s + (r.count as number), 0),
    },
    documents: {
      ...documents[0],
      totalBytes: Number((storageUsage[0] as Record<string, unknown>).total_bytes),
    },
    payments: {
      byCategory: paymentsByCategory,
      byMonth: paymentsByMonth,
      total: paymentsByCategory.reduce((s: number, r: Record<string, unknown>) => s + Number(r.total_amount), 0),
      count: paymentsByCategory.reduce((s: number, r: Record<string, unknown>) => s + (r.count as number), 0),
    },
    ai: {
      ...ai,
      byMonth: aiUsageByMonth,
      estimatedCost: (inputCost + outputCost).toFixed(4),
    },
    notifications: notifications[0],
    support: supportTickets[0],
    reminders: reminders[0],
  });
}
