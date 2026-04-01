"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";

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

interface Filters {
  job: string;
  status: string;
}

interface Props {
  runs: JobRun[];
  total: number;
  page: number;
  totalPages: number;
  filters: Filters;
}

function buildUrl(filters: Partial<Filters> & { page?: number }): string {
  const params = new URLSearchParams();
  if (filters.job) params.set("job", filters.job);
  if (filters.status) params.set("status", filters.status);
  if (filters.page && filters.page > 1) params.set("page", String(filters.page));
  const qs = params.toString();
  return qs ? `/job-runs?${qs}` : "/job-runs";
}

function formatDuration(ms: number | null): string {
  if (ms === null) return "—";
  if (ms < 1000) return `${ms}ms`;
  return `${(ms / 1000).toFixed(1)}s`;
}

export function JobRunsTable({ runs, total, page, totalPages, filters }: Props) {
  const router = useRouter();
  const [job, setJob] = useState(filters.job);
  const [status, setStatus] = useState(filters.status);

  function applyFilters() {
    router.push(buildUrl({ job, status, page: 1 }));
  }

  function clearFilters() {
    setJob("");
    setStatus("");
    router.push("/job-runs");
  }

  function goToPage(p: number) {
    router.push(buildUrl({ job, status, page: p }));
  }

  const hasFilters = job || status;

  return (
    <div>
      <h3 className="text-lg font-semibold mb-4">Run History</h3>

      <div className="flex items-end gap-3 mb-4">
        <div>
          <label className="block text-xs text-gray-500 mb-1">Job</label>
          <select
            value={job}
            onChange={(e) => setJob(e.target.value)}
            className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
          >
            <option value="">All Jobs</option>
            <option value="daily-reminder-check">daily-reminder-check</option>
            <option value="daily-digest">daily-digest</option>
          </select>
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">Status</label>
          <select
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
          >
            <option value="">All</option>
            <option value="completed">Completed</option>
            <option value="failed">Failed</option>
            <option value="running">Running</option>
          </select>
        </div>
        <button
          onClick={applyFilters}
          className="bg-blue-600 hover:bg-blue-700 text-white text-sm px-4 py-2 rounded-lg transition-colors"
        >
          Filter
        </button>
        {hasFilters && (
          <button
            onClick={clearFilters}
            className="text-gray-400 hover:text-white text-sm px-3 py-2 transition-colors"
          >
            Clear
          </button>
        )}
      </div>

      <div className="text-sm text-gray-500 mb-3">
        {total} run{total !== 1 ? "s" : ""}
        {hasFilters ? " matching filters" : ""}
      </div>

      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#38383A] text-gray-500 text-left">
              <th className="px-5 py-3">Job</th>
              <th className="px-5 py-3">Status</th>
              <th className="px-5 py-3">Started</th>
              <th className="px-5 py-3">Duration</th>
              <th className="px-5 py-3">Processed</th>
              <th className="px-5 py-3">Failed</th>
              <th className="px-5 py-3">Error</th>
            </tr>
          </thead>
          <tbody>
            {runs.map((r) => (
              <tr
                key={r.id}
                className="border-b border-[#38383A] hover:bg-[#2C2C2E]"
              >
                <td className="px-5 py-3 font-medium">{r.job_name}</td>
                <td className="px-5 py-3">
                  <span
                    className={`px-2 py-0.5 rounded-full text-xs ${
                      r.status === "completed"
                        ? "bg-green-500/20 text-green-400"
                        : r.status === "failed"
                          ? "bg-red-500/20 text-red-400"
                          : "bg-yellow-500/20 text-yellow-400"
                    }`}
                  >
                    {r.status}
                  </span>
                </td>
                <td className="px-5 py-3 text-gray-500 whitespace-nowrap" suppressHydrationWarning>
                  {new Date(r.started_at).toLocaleString()}
                </td>
                <td className="px-5 py-3 text-gray-400">
                  {formatDuration(r.duration_ms)}
                </td>
                <td className="px-5 py-3">
                  <span className="bg-blue-500/20 text-blue-400 px-2 py-0.5 rounded-full text-xs">
                    {r.processed}
                  </span>
                </td>
                <td className="px-5 py-3">
                  {r.failed > 0 ? (
                    <span className="bg-red-500/20 text-red-400 px-2 py-0.5 rounded-full text-xs">
                      {r.failed}
                    </span>
                  ) : (
                    <span className="text-gray-500">0</span>
                  )}
                </td>
                <td className="px-5 py-3 text-red-400 max-w-[250px] truncate">
                  {r.error || "—"}
                </td>
              </tr>
            ))}
            {runs.length === 0 && (
              <tr>
                <td colSpan={7} className="px-5 py-8 text-center text-gray-500">
                  No job runs found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className="flex items-center justify-between mt-4">
          <div className="text-sm text-gray-500">
            Page {page} of {totalPages}
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => goToPage(page - 1)}
              disabled={page <= 1}
              className="px-3 py-1.5 text-sm rounded-lg border border-[#38383A] text-gray-400 hover:text-white hover:bg-[#2C2C2E] disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
            >
              Previous
            </button>
            {generatePageNumbers(page, totalPages).map((p, i) =>
              p === -1 ? (
                <span key={`dots-${i}`} className="px-2 py-1.5 text-gray-500">
                  ...
                </span>
              ) : (
                <button
                  key={p}
                  onClick={() => goToPage(p)}
                  className={`px-3 py-1.5 text-sm rounded-lg border transition-colors ${
                    p === page
                      ? "border-blue-500 bg-blue-600 text-white"
                      : "border-[#38383A] text-gray-400 hover:text-white hover:bg-[#2C2C2E]"
                  }`}
                >
                  {p}
                </button>
              )
            )}
            <button
              onClick={() => goToPage(page + 1)}
              disabled={page >= totalPages}
              className="px-3 py-1.5 text-sm rounded-lg border border-[#38383A] text-gray-400 hover:text-white hover:bg-[#2C2C2E] disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function generatePageNumbers(current: number, total: number): number[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);

  const pages: number[] = [1];
  if (current > 3) pages.push(-1);

  const start = Math.max(2, current - 1);
  const end = Math.min(total - 1, current + 1);
  for (let i = start; i <= end; i++) pages.push(i);

  if (current < total - 2) pages.push(-1);
  pages.push(total);
  return pages;
}
