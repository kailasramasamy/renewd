import { query } from "@/lib/db";
import { LogTable } from "./log-table";

interface NotifStat {
  type: string;
  total: number;
  read: number;
}

interface LogEntry {
  id: string;
  user_name: string | null;
  user_email: string | null;
  renewal_name: string | null;
  title: string;
  body: string;
  type: string;
  is_read: boolean;
  created_at: string;
}

interface Props {
  searchParams: Promise<{
    page?: string;
    type?: string;
    q?: string;
    from?: string;
    to?: string;
  }>;
}

const PAGE_SIZE = 50;

export const dynamic = "force-dynamic";

export default async function NotificationsPage({ searchParams }: Props) {
  const params = await searchParams;
  const page = Math.max(1, parseInt(params.page ?? "1", 10));
  const type = params.type ?? "";
  const search = params.q ?? "";
  const from = params.from ?? "";
  const to = params.to ?? "";

  const conditions: string[] = [];
  const values: unknown[] = [];
  let idx = 1;

  if (type) {
    conditions.push(`n.type = $${idx++}`);
    values.push(type);
  }
  if (search) {
    conditions.push(
      `(u.name ILIKE $${idx} OR u.email ILIKE $${idx} OR n.title ILIKE $${idx} OR n.body ILIKE $${idx})`
    );
    values.push(`%${search}%`);
    idx++;
  }
  if (from) {
    conditions.push(`n.created_at >= $${idx++}::date`);
    values.push(from);
  }
  if (to) {
    conditions.push(`n.created_at < ($${idx++}::date + INTERVAL '1 day')`);
    values.push(to);
  }

  const where = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

  const [{ total }] = await query<{ total: number }>(
    `SELECT COUNT(*)::int AS total FROM notification_log n JOIN users u ON u.id = n.user_id ${where}`,
    values
  );

  const offset = (page - 1) * PAGE_SIZE;
  const logs = await query<LogEntry>(
    `SELECT n.id, u.name AS user_name, u.email AS user_email,
            ren.name AS renewal_name,
            n.title, n.body, n.type, n.is_read, n.created_at
     FROM notification_log n
     JOIN users u ON u.id = n.user_id
     LEFT JOIN renewals ren ON ren.id = n.renewal_id
     ${where}
     ORDER BY n.created_at DESC
     LIMIT ${PAGE_SIZE} OFFSET ${offset}`,
    values
  );

  const stats = await query<NotifStat>(
    `SELECT type,
            COUNT(*)::int AS total,
            COUNT(*) FILTER (WHERE is_read)::int AS read
     FROM notification_log GROUP BY type`
  );

  const [totals] = await query<{ total: number; read: number }>(
    `SELECT COUNT(*)::int AS total,
            COUNT(*) FILTER (WHERE is_read)::int AS read
     FROM notification_log`
  );

  const readRate =
    totals.total > 0 ? ((totals.read / totals.total) * 100).toFixed(1) : "0";

  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Notifications</h2>

      <div className="grid grid-cols-4 gap-4 mb-8">
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Total Sent</p>
          <p className="text-3xl font-bold mt-2">{totals.total}</p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Read</p>
          <p className="text-3xl font-bold mt-2 text-green-400">{totals.read}</p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Unread</p>
          <p className="text-3xl font-bold mt-2 text-orange-400">
            {totals.total - totals.read}
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

      <LogTable
        logs={logs}
        total={total}
        page={page}
        totalPages={totalPages}
        filters={{ type, q: search, from, to }}
      />
    </div>
  );
}
