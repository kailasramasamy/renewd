import { query } from "@/lib/db";

interface NotifStat {
  type: string;
  total: number;
  read: number;
}

interface RecentNotif {
  title: string;
  body: string;
  type: string;
  is_read: boolean;
  created_at: string;
  user_name: string | null;
}

async function getData() {
  const stats = await query<NotifStat>(
    `SELECT type,
            COUNT(*)::int AS total,
            COUNT(*) FILTER (WHERE is_read)::int AS read
     FROM notification_log GROUP BY type`
  );

  const recent = await query<RecentNotif>(
    `SELECT n.title, n.body, n.type, n.is_read, n.created_at,
            u.name AS user_name
     FROM notification_log n
     JOIN users u ON u.id = n.user_id
     ORDER BY n.created_at DESC LIMIT 20`
  );

  const [total] = await query<{ total: number; read: number }>(
    `SELECT COUNT(*)::int AS total,
            COUNT(*) FILTER (WHERE is_read)::int AS read
     FROM notification_log`
  );

  return { stats, recent, total };
}

export const dynamic = "force-dynamic";

export default async function NotificationsPage() {
  const { stats, recent, total } = await getData();
  const readRate =
    total.total > 0 ? ((total.read / total.total) * 100).toFixed(1) : "0";

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Notifications</h2>

      <div className="grid grid-cols-4 gap-4 mb-8">
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Total Sent</p>
          <p className="text-3xl font-bold mt-2">{total.total}</p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Read</p>
          <p className="text-3xl font-bold mt-2 text-green-400">{total.read}</p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Unread</p>
          <p className="text-3xl font-bold mt-2 text-orange-400">
            {total.total - total.read}
          </p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Read Rate</p>
          <p className="text-3xl font-bold mt-2 text-blue-400">{readRate}%</p>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-4 mb-8">
        {stats.map((s) => (
          <div
            key={s.type}
            className="bg-[#1C1C1E] rounded-2xl p-4 border border-[#38383A]"
          >
            <p className="text-gray-500 text-xs uppercase tracking-wider">
              {s.type}
            </p>
            <p className="text-xl font-bold mt-1">
              {s.total} sent · {s.read} read
            </p>
          </div>
        ))}
      </div>

      <h3 className="text-lg font-semibold mb-4">Recent Notifications</h3>
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#38383A] text-gray-500 text-left">
              <th className="px-5 py-3">User</th>
              <th className="px-5 py-3">Title</th>
              <th className="px-5 py-3">Type</th>
              <th className="px-5 py-3">Status</th>
              <th className="px-5 py-3">Sent</th>
            </tr>
          </thead>
          <tbody>
            {recent.map((n, i) => (
              <tr
                key={i}
                className="border-b border-[#38383A] hover:bg-[#2C2C2E]"
              >
                <td className="px-5 py-3">{n.user_name || "—"}</td>
                <td className="px-5 py-3 font-medium">{n.title}</td>
                <td className="px-5 py-3">
                  <span
                    className={`px-2 py-0.5 rounded-full text-xs ${
                      n.type === "reminder"
                        ? "bg-orange-500/20 text-orange-400"
                        : "bg-blue-500/20 text-blue-400"
                    }`}
                  >
                    {n.type}
                  </span>
                </td>
                <td className="px-5 py-3">
                  {n.is_read ? (
                    <span className="text-green-400">Read</span>
                  ) : (
                    <span className="text-gray-500">Unread</span>
                  )}
                </td>
                <td className="px-5 py-3 text-gray-500">
                  {new Date(n.created_at).toLocaleString()}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
