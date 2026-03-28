import { query } from "@/lib/db";

interface Stat {
  label: string;
  value: string | number;
  sub?: string;
}

async function getStats(): Promise<Stat[]> {
  const [users] = await query<{ count: number }>(
    "SELECT COUNT(*)::int AS count FROM users"
  );
  const [renewals] = await query<{ count: number }>(
    "SELECT COUNT(*)::int AS count FROM renewals WHERE status = 'active'"
  );
  const [documents] = await query<{ count: number }>(
    "SELECT COUNT(*)::int AS count FROM documents"
  );
  const [payments] = await query<{ count: number; total: string }>(
    "SELECT COUNT(*)::int AS count, COALESCE(SUM(amount), 0)::text AS total FROM payments"
  );
  const [notifications] = await query<{ count: number }>(
    "SELECT COUNT(*)::int AS count FROM notification_log"
  );
  const [unread] = await query<{ count: number }>(
    "SELECT COUNT(*)::int AS count FROM notification_log WHERE is_read = FALSE"
  );
  const [expiringSoon] = await query<{ count: number }>(
    "SELECT COUNT(*)::int AS count FROM renewals WHERE status = 'active' AND renewal_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'"
  );

  return [
    { label: "Total Users", value: users.count },
    { label: "Active Renewals", value: renewals.count },
    { label: "Expiring This Week", value: expiringSoon.count },
    { label: "Documents", value: documents.count },
    {
      label: "Payments",
      value: payments.count,
      sub: `₹${parseFloat(payments.total).toLocaleString()}`,
    },
    {
      label: "Notifications",
      value: notifications.count,
      sub: `${unread.count} unread`,
    },
  ];
}

export const dynamic = "force-dynamic";

export default async function Dashboard() {
  const stats = await getStats();

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Dashboard</h2>
      <div className="grid grid-cols-3 gap-4">
        {stats.map((stat) => (
          <div
            key={stat.label}
            className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]"
          >
            <p className="text-gray-500 text-sm">{stat.label}</p>
            <p className="text-3xl font-bold mt-2">{stat.value}</p>
            {stat.sub && (
              <p className="text-sm text-gray-400 mt-1">{stat.sub}</p>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
