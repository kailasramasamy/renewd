import { query } from "@/lib/db";
import { JobRunsTable } from "./job-runs-table";

interface JobRun {
  id: string;
  job_name: string;
  status: string;
  started_at: string;
  finished_at: string | null;
  duration_ms: number | null;
  processed: number;
  failed: number;
  error: string | null;
}

interface JobStat {
  job_name: string;
  total_runs: number;
  last_run: string | null;
  last_status: string | null;
  avg_duration_ms: number | null;
  total_processed: number;
  total_failed: number;
}

interface Props {
  searchParams: Promise<{
    page?: string;
    job?: string;
    status?: string;
  }>;
}

const PAGE_SIZE = 50;

export const dynamic = "force-dynamic";

export default async function JobRunsPage({ searchParams }: Props) {
  const params = await searchParams;
  const page = Math.max(1, parseInt(params.page ?? "1", 10));
  const job = params.job ?? "";
  const status = params.status ?? "";

  const conditions: string[] = [];
  const values: unknown[] = [];
  let idx = 1;

  if (job) {
    conditions.push(`job_name = $${idx++}`);
    values.push(job);
  }
  if (status) {
    conditions.push(`status = $${idx++}`);
    values.push(status);
  }

  const where = conditions.length > 0 ? `WHERE ${conditions.join(" AND ")}` : "";

  const [{ total }] = await query<{ total: number }>(
    `SELECT COUNT(*)::int AS total FROM job_runs ${where}`,
    values
  );

  const offset = (page - 1) * PAGE_SIZE;
  const runs = await query<JobRun>(
    `SELECT id, job_name, status, started_at, finished_at,
            duration_ms, processed, failed, error
     FROM job_runs ${where}
     ORDER BY started_at DESC
     LIMIT ${PAGE_SIZE} OFFSET ${offset}`,
    values
  );

  const stats = await query<JobStat>(
    `SELECT job_name,
            COUNT(*)::int AS total_runs,
            MAX(started_at)::text AS last_run,
            (ARRAY_AGG(status ORDER BY started_at DESC))[1] AS last_status,
            ROUND(AVG(duration_ms))::int AS avg_duration_ms,
            COALESCE(SUM(processed), 0)::int AS total_processed,
            COALESCE(SUM(failed), 0)::int AS total_failed
     FROM job_runs
     GROUP BY job_name`
  );

  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Job Runs</h2>

      <div className="grid grid-cols-2 gap-4 mb-8">
        {stats.length > 0 ? (
          stats.map((s) => (
            <div
              key={s.job_name}
              className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]"
            >
              <p className="text-gray-500 text-xs uppercase tracking-wider mb-2">
                {s.job_name}
              </p>
              <div className="flex items-baseline gap-4">
                <p className="text-2xl font-bold">{s.total_runs} runs</p>
                <span
                  className={`px-2 py-0.5 rounded-full text-xs ${
                    s.last_status === "completed"
                      ? "bg-green-500/20 text-green-400"
                      : s.last_status === "failed"
                        ? "bg-red-500/20 text-red-400"
                        : "bg-yellow-500/20 text-yellow-400"
                  }`}
                >
                  last: {s.last_status}
                </span>
              </div>
              <div className="flex gap-6 mt-3 text-sm text-gray-400">
                <span>Avg: {s.avg_duration_ms ?? 0}ms</span>
                <span>Processed: {s.total_processed}</span>
                <span className={s.total_failed > 0 ? "text-red-400" : ""}>
                  Failed: {s.total_failed}
                </span>
              </div>
              {s.last_run && (
                <p className="text-xs text-gray-500 mt-2" suppressHydrationWarning>
                  Last run: {new Date(s.last_run).toLocaleString()}
                </p>
              )}
            </div>
          ))
        ) : (
          <div className="col-span-2 bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A] text-gray-500 text-center">
            No job runs recorded yet
          </div>
        )}
      </div>

      <JobRunsTable
        runs={runs}
        total={total}
        page={page}
        totalPages={totalPages}
        filters={{ job, status }}
      />
    </div>
  );
}
