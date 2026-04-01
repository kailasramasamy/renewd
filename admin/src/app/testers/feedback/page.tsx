import { query } from "@/lib/db";
import { FeedbackTable } from "./feedback-table";

interface FeedbackEntry {
  id: string;
  tester_name: string;
  tester_email: string;
  platform: string;
  category: string;
  title: string;
  description: string;
  created_at: string;
}

interface FeedbackStat {
  category: string;
  count: number;
}

interface Props {
  searchParams: Promise<{
    page?: string;
    category?: string;
    q?: string;
  }>;
}

const PAGE_SIZE = 50;

export const dynamic = "force-dynamic";

export default async function TesterFeedbackPage({ searchParams }: Props) {
  const params = await searchParams;
  const page = Math.max(1, parseInt(params.page ?? "1", 10));
  const category = params.category ?? "";
  const search = params.q ?? "";

  const conditions: string[] = [];
  const values: unknown[] = [];
  let idx = 1;

  if (category) {
    conditions.push(`f.category = $${idx++}`);
    values.push(category);
  }
  if (search) {
    conditions.push(
      `(t.name ILIKE $${idx} OR f.title ILIKE $${idx} OR f.description ILIKE $${idx})`
    );
    values.push(`%${search}%`);
    idx++;
  }

  const where = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

  const [{ total }] = await query<{ total: number }>(
    `SELECT COUNT(*)::int AS total
     FROM tester_feedback f JOIN testers t ON t.id = f.tester_id
     ${where}`,
    values
  );

  const offset = (page - 1) * PAGE_SIZE;
  const feedback = await query<FeedbackEntry>(
    `SELECT f.id, t.name AS tester_name, t.email AS tester_email, t.platform,
            f.category, f.title, f.description, f.created_at
     FROM tester_feedback f
     JOIN testers t ON t.id = f.tester_id
     ${where}
     ORDER BY f.created_at DESC
     LIMIT ${PAGE_SIZE} OFFSET ${offset}`,
    values
  );

  const stats = await query<FeedbackStat>(
    `SELECT category, COUNT(*)::int AS count FROM tester_feedback GROUP BY category`
  );

  const totalAll = stats.reduce((s, r) => s + r.count, 0);
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Tester Feedback</h2>

      <div className="grid grid-cols-4 gap-4 mb-8">
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Total</p>
          <p className="text-3xl font-bold mt-2">{totalAll}</p>
        </div>
        {["bug", "suggestion", "general"].map((cat) => {
          const count = stats.find((s) => s.category === cat)?.count ?? 0;
          const colors: Record<string, string> = {
            bug: "text-red-400",
            suggestion: "text-orange-400",
            general: "text-blue-400",
          };
          return (
            <div key={cat} className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
              <p className="text-gray-500 text-sm capitalize">{cat}s</p>
              <p className={`text-3xl font-bold mt-2 ${colors[cat]}`}>{count}</p>
            </div>
          );
        })}
      </div>

      <FeedbackTable
        feedback={feedback}
        total={total}
        page={page}
        totalPages={totalPages}
        filters={{ category, q: search }}
      />
    </div>
  );
}
