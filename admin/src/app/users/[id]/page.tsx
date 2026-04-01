import { query } from "@/lib/db";
import { notFound } from "next/navigation";
import { UserAnalyticsCharts } from "./charts";

export const dynamic = "force-dynamic";

interface UserRow {
  id: string;
  name: string | null;
  email: string | null;
  phone: string | null;
  device_os: string | null;
  device_model: string | null;
  app_version: string | null;
  is_premium: boolean;
  premium_expires_at: string | null;
  default_currency: string | null;
  country: string | null;
  created_at: string;
}

interface CategoryRow { category: string; count: number; total_amount: number }
interface StatusRow { status: string; count: number }
interface ProviderRow { provider: string; category: string; count: number }
interface PaymentCatRow { category: string; count: number; total_amount: number }
interface PaymentMonthRow { month: string; count: number; total_amount: number }
interface AiMonthRow { month: string; messages: number; input_tokens: number; output_tokens: number }

function formatBytes(bytes: number): string {
  if (bytes === 0) return "0 B";
  const units = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  return `${(bytes / Math.pow(1024, i)).toFixed(1)} ${units[i]}`;
}

function formatCurrency(amount: number): string {
  return `₹${amount.toLocaleString("en-IN", { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`;
}

function daysSince(date: string): number {
  return Math.floor((Date.now() - new Date(date).getTime()) / 86400000);
}

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  const [
    users,
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
    query<UserRow>(
      `SELECT id, name, email, phone, device_os, device_model, app_version,
              is_premium, premium_expires_at::text, default_currency, country,
              created_at::text
       FROM users WHERE id = $1`, [id]
    ),
    query<CategoryRow>(
      `SELECT category, COUNT(*)::int AS count,
              COALESCE(SUM(amount), 0)::numeric AS total_amount
       FROM renewals WHERE user_id = $1
       GROUP BY category ORDER BY count DESC`, [id]
    ),
    query<StatusRow>(
      `SELECT status, COUNT(*)::int AS count
       FROM renewals WHERE user_id = $1
       GROUP BY status`, [id]
    ),
    query<ProviderRow>(
      `SELECT COALESCE(provider, 'Unknown') AS provider, category,
              COUNT(*)::int AS count
       FROM renewals WHERE user_id = $1
       GROUP BY provider, category ORDER BY count DESC LIMIT 15`, [id]
    ),
    query<{ total_files: number; types: string[] | null }>(
      `SELECT COUNT(*)::int AS total_files,
              json_agg(DISTINCT mime_type) FILTER (WHERE mime_type IS NOT NULL) AS types
       FROM documents WHERE user_id = $1`, [id]
    ),
    query<{ total_bytes: string }>(
      `SELECT COALESCE(SUM(file_size), 0)::bigint AS total_bytes
       FROM documents WHERE user_id = $1`, [id]
    ),
    query<PaymentCatRow>(
      `SELECT r.category, COUNT(p.id)::int AS count,
              COALESCE(SUM(p.amount), 0)::numeric AS total_amount
       FROM payments p JOIN renewals r ON r.id = p.renewal_id
       WHERE p.user_id = $1
       GROUP BY r.category ORDER BY total_amount DESC`, [id]
    ),
    query<PaymentMonthRow>(
      `SELECT to_char(paid_date, 'YYYY-MM') AS month,
              COUNT(*)::int AS count, SUM(amount)::numeric AS total_amount
       FROM payments WHERE user_id = $1
         AND paid_date >= NOW() - INTERVAL '12 months'
       GROUP BY month ORDER BY month`, [id]
    ),
    query<{ total_messages: number; total_input_tokens: string; total_output_tokens: string }>(
      `SELECT COUNT(*)::int AS total_messages,
              COALESCE(SUM(input_tokens), 0)::bigint AS total_input_tokens,
              COALESCE(SUM(output_tokens), 0)::bigint AS total_output_tokens
       FROM chat_usage WHERE user_id = $1`, [id]
    ),
    query<AiMonthRow>(
      `SELECT to_char(created_at, 'YYYY-MM') AS month,
              COUNT(*)::int AS messages,
              COALESCE(SUM(input_tokens), 0)::bigint AS input_tokens,
              COALESCE(SUM(output_tokens), 0)::bigint AS output_tokens
       FROM chat_usage WHERE user_id = $1
         AND created_at >= NOW() - INTERVAL '6 months'
       GROUP BY month ORDER BY month`, [id]
    ),
    query<{ total: number; read_count: number; unread_count: number }>(
      `SELECT COUNT(*)::int AS total,
              COUNT(*) FILTER (WHERE is_read)::int AS read_count,
              COUNT(*) FILTER (WHERE NOT is_read)::int AS unread_count
       FROM notification_log WHERE user_id = $1`, [id]
    ),
    query<{ total: number; open_count: number; resolved_count: number }>(
      `SELECT COUNT(*)::int AS total,
              COUNT(*) FILTER (WHERE status = 'open')::int AS open_count,
              COUNT(*) FILTER (WHERE status = 'resolved')::int AS resolved_count
       FROM support_tickets WHERE user_id = $1`, [id]
    ),
    query<{ total: number; sent_count: number; snoozed_count: number }>(
      `SELECT COUNT(*)::int AS total,
              COUNT(*) FILTER (WHERE is_sent)::int AS sent_count,
              COUNT(*) FILTER (WHERE snoozed_until IS NOT NULL)::int AS snoozed_count
       FROM reminders WHERE user_id = $1`, [id]
    ),
  ]);

  if (!users.length) notFound();
  const user = users[0];

  const totalRenewals = renewalsByCategory.reduce((s, r) => s + r.count, 0);
  const totalDocs = documents[0]?.total_files ?? 0;
  const totalBytes = Number(storageUsage[0]?.total_bytes ?? 0);
  const totalPayments = paymentsByCategory.reduce((s, r) => s + Number(r.total_amount), 0);
  const paymentCount = paymentsByCategory.reduce((s, r) => s + r.count, 0);
  const ai = aiUsage[0] ?? { total_messages: 0, total_input_tokens: "0", total_output_tokens: "0" };
  const inputTokens = Number(ai.total_input_tokens);
  const outputTokens = Number(ai.total_output_tokens);
  const aiCost = (inputTokens / 1_000_000) * 0.80 + (outputTokens / 1_000_000) * 4.0;
  const notif = notifications[0] ?? { total: 0, read_count: 0, unread_count: 0 };
  const support = supportTickets[0] ?? { total: 0, open_count: 0, resolved_count: 0 };
  const remind = reminders[0] ?? { total: 0, sent_count: 0, snoozed_count: 0 };

  return (
    <div className="space-y-6">
      {/* Back link */}
      <a href="/users" className="text-blue-400 hover:text-blue-300 text-sm">
        ← Back to Users
      </a>

      {/* User header */}
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-6">
        <div className="flex items-start justify-between">
          <div>
            <h2 className="text-2xl font-bold">{user.name ?? "Unnamed User"}</h2>
            <div className="flex gap-4 mt-2 text-gray-400 text-sm">
              {user.email && <span>{user.email}</span>}
              {user.phone && <span>{user.phone}</span>}
            </div>
            <div className="flex gap-4 mt-2 text-gray-500 text-sm">
              {user.device_os && <span>{user.device_os} {user.device_model}</span>}
              {user.app_version && <span>v{user.app_version}</span>}
              {user.country && <span>{user.country}</span>}
              {user.default_currency && <span>{user.default_currency}</span>}
            </div>
          </div>
          <div className="flex items-center gap-3">
            {user.is_premium ? (
              <span className="bg-amber-500/20 text-amber-400 px-3 py-1 rounded-full text-sm font-medium">
                Premium
                {user.premium_expires_at && (
                  <span className="text-amber-500/70 ml-1">
                    expires {new Date(user.premium_expires_at).toLocaleDateString()}
                  </span>
                )}
              </span>
            ) : (
              <span className="bg-gray-500/20 text-gray-400 px-3 py-1 rounded-full text-sm font-medium">
                Free
              </span>
            )}
            <span className="text-gray-500 text-sm">
              Joined {daysSince(user.created_at)}d ago
            </span>
          </div>
        </div>
      </div>

      {/* Stats cards */}
      <div className="grid grid-cols-6 gap-4">
        <StatCard label="Renewals" value={totalRenewals} />
        <StatCard label="Documents" value={totalDocs} />
        <StatCard label="Storage" value={formatBytes(totalBytes)} />
        <StatCard label="Payments" value={formatCurrency(totalPayments)} sub={`${paymentCount} payments`} />
        <StatCard label="AI Messages" value={ai.total_messages} />
        <StatCard label="AI Cost" value={`$${aiCost.toFixed(4)}`} color="text-amber-400" />
      </div>

      {/* Renewals section */}
      <div className="grid grid-cols-2 gap-4">
        {/* By category */}
        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
          <h3 className="font-semibold mb-4">Renewals by Category</h3>
          {renewalsByCategory.length > 0 ? (
            <table className="w-full text-sm">
              <thead>
                <tr className="text-gray-500 border-b border-[#38383A]">
                  <th className="text-left pb-2">Category</th>
                  <th className="text-right pb-2">Count</th>
                  <th className="text-right pb-2">Total Amount</th>
                </tr>
              </thead>
              <tbody>
                {renewalsByCategory.map((r) => (
                  <tr key={r.category} className="border-b border-[#38383A]/50 hover:bg-[#2C2C2E]">
                    <td className="py-2 capitalize">{r.category}</td>
                    <td className="py-2 text-right">{r.count}</td>
                    <td className="py-2 text-right text-gray-400">{formatCurrency(Number(r.total_amount))}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p className="text-gray-500 text-sm">No renewals</p>
          )}
        </div>

        {/* By status */}
        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
          <h3 className="font-semibold mb-4">Renewal Status</h3>
          <div className="grid grid-cols-2 gap-3">
            {renewalsByStatus.map((r) => (
              <div key={r.status} className="bg-[#2C2C2E] rounded-xl p-3">
                <div className="text-2xl font-bold">{r.count}</div>
                <div className="text-gray-500 text-sm capitalize">{r.status}</div>
              </div>
            ))}
          </div>
          <h3 className="font-semibold mt-6 mb-4">Top Providers</h3>
          {renewalsByProvider.length > 0 ? (
            <div className="space-y-2">
              {renewalsByProvider.map((r, i) => (
                <div key={i} className="flex justify-between text-sm">
                  <span>{r.provider}</span>
                  <span className="text-gray-500">{r.category} · {r.count}</span>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-sm">No providers</p>
          )}
        </div>
      </div>

      {/* Charts */}
      <UserAnalyticsCharts
        renewalsByCategory={renewalsByCategory}
        paymentsByMonth={paymentsByMonth}
        aiUsageByMonth={aiUsageByMonth}
      />

      {/* Payments by category */}
      {paymentsByCategory.length > 0 && (
        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
          <h3 className="font-semibold mb-4">Payments by Category</h3>
          <table className="w-full text-sm">
            <thead>
              <tr className="text-gray-500 border-b border-[#38383A]">
                <th className="text-left pb-2">Category</th>
                <th className="text-right pb-2">Payments</th>
                <th className="text-right pb-2">Total Amount</th>
              </tr>
            </thead>
            <tbody>
              {paymentsByCategory.map((r) => (
                <tr key={r.category} className="border-b border-[#38383A]/50 hover:bg-[#2C2C2E]">
                  <td className="py-2 capitalize">{r.category}</td>
                  <td className="py-2 text-right">{r.count}</td>
                  <td className="py-2 text-right text-gray-400">{formatCurrency(Number(r.total_amount))}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* AI Usage details */}
      <div className="grid grid-cols-2 gap-4">
        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
          <h3 className="font-semibold mb-4">AI Token Usage</h3>
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-[#2C2C2E] rounded-xl p-3">
              <div className="text-2xl font-bold">{inputTokens.toLocaleString()}</div>
              <div className="text-gray-500 text-sm">Input Tokens</div>
            </div>
            <div className="bg-[#2C2C2E] rounded-xl p-3">
              <div className="text-2xl font-bold">{outputTokens.toLocaleString()}</div>
              <div className="text-gray-500 text-sm">Output Tokens</div>
            </div>
          </div>
        </div>

        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
          <h3 className="font-semibold mb-4">Engagement</h3>
          <div className="grid grid-cols-3 gap-3">
            <div className="bg-[#2C2C2E] rounded-xl p-3">
              <div className="text-2xl font-bold">{notif.total}</div>
              <div className="text-gray-500 text-sm">Notifications</div>
              <div className="text-xs text-gray-600 mt-1">
                {notif.total > 0 ? `${Math.round((notif.read_count / notif.total) * 100)}% read` : "–"}
              </div>
            </div>
            <div className="bg-[#2C2C2E] rounded-xl p-3">
              <div className="text-2xl font-bold">{remind.total}</div>
              <div className="text-gray-500 text-sm">Reminders</div>
              <div className="text-xs text-gray-600 mt-1">
                {remind.sent_count} sent · {remind.snoozed_count} snoozed
              </div>
            </div>
            <div className="bg-[#2C2C2E] rounded-xl p-3">
              <div className="text-2xl font-bold">{support.total}</div>
              <div className="text-gray-500 text-sm">Tickets</div>
              <div className="text-xs text-gray-600 mt-1">
                {support.open_count} open · {support.resolved_count} resolved
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Documents */}
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
        <h3 className="font-semibold mb-4">Documents</h3>
        <div className="flex gap-6 text-sm">
          <div>
            <span className="text-gray-500">Files:</span> {totalDocs}
          </div>
          <div>
            <span className="text-gray-500">Storage:</span> {formatBytes(totalBytes)}
          </div>
          <div>
            <span className="text-gray-500">Types:</span>{" "}
            {documents[0]?.types?.join(", ") ?? "–"}
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({
  label,
  value,
  sub,
  color,
}: {
  label: string;
  value: string | number;
  sub?: string;
  color?: string;
}) {
  return (
    <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
      <div className={`text-2xl font-bold ${color ?? "text-white"}`}>{value}</div>
      <div className="text-gray-500 text-sm">{label}</div>
      {sub && <div className="text-gray-600 text-xs mt-1">{sub}</div>}
    </div>
  );
}
