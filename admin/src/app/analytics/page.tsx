import { query } from "@/lib/db";
import { Charts } from "./charts";

async function getData() {
  const byCategory = await query<{ category: string; count: number }>(
    `SELECT category, COUNT(*)::int AS count FROM renewals
     WHERE status = 'active' GROUP BY category ORDER BY count DESC`
  );

  const byMonth = await query<{ month: string; total: string }>(
    `SELECT TO_CHAR(p.paid_date, 'YYYY-MM') AS month,
            SUM(p.amount)::text AS total
     FROM payments p
     WHERE p.paid_date >= CURRENT_DATE - INTERVAL '12 months'
     GROUP BY month ORDER BY month ASC`
  );

  const expiring = await query<{
    name: string;
    category: string;
    renewal_date: string;
    amount: string | null;
  }>(
    `SELECT name, category, renewal_date, amount::text
     FROM renewals WHERE status = 'active'
     AND renewal_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
     ORDER BY renewal_date ASC LIMIT 20`
  );

  return {
    byCategory: byCategory.map((r) => ({
      name: r.category,
      value: r.count,
    })),
    byMonth: byMonth.map((r) => ({
      month: r.month,
      total: parseFloat(r.total),
    })),
    expiring,
  };
}

export const dynamic = "force-dynamic";

export default async function AnalyticsPage() {
  const data = await getData();

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Analytics</h2>
      <Charts byCategory={data.byCategory} byMonth={data.byMonth} />

      <div className="mt-8">
        <h3 className="text-lg font-semibold mb-4">
          Expiring in 30 Days ({data.expiring.length})
        </h3>
        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-[#38383A] text-gray-500 text-left">
                <th className="px-5 py-3">Name</th>
                <th className="px-5 py-3">Category</th>
                <th className="px-5 py-3">Amount</th>
                <th className="px-5 py-3">Renewal Date</th>
              </tr>
            </thead>
            <tbody>
              {data.expiring.map((r, i) => (
                <tr
                  key={i}
                  className="border-b border-[#38383A] hover:bg-[#2C2C2E]"
                >
                  <td className="px-5 py-3 font-medium">{r.name}</td>
                  <td className="px-5 py-3 text-gray-400">{r.category}</td>
                  <td className="px-5 py-3">
                    {r.amount ? `₹${parseFloat(r.amount).toLocaleString()}` : "—"}
                  </td>
                  <td className="px-5 py-3 text-gray-400">
                    {new Date(r.renewal_date).toLocaleDateString()}
                  </td>
                </tr>
              ))}
              {data.expiring.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-5 py-8 text-center text-gray-500">
                    No renewals expiring in the next 30 days
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
