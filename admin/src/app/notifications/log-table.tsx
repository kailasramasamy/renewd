"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";

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

interface Filters {
  type: string;
  q: string;
  from: string;
  to: string;
}

interface Props {
  logs: LogEntry[];
  total: number;
  page: number;
  totalPages: number;
  filters: Filters;
}

function buildUrl(filters: Partial<Filters> & { page?: number }): string {
  const params = new URLSearchParams();
  if (filters.type) params.set("type", filters.type);
  if (filters.q) params.set("q", filters.q);
  if (filters.from) params.set("from", filters.from);
  if (filters.to) params.set("to", filters.to);
  if (filters.page && filters.page > 1) params.set("page", String(filters.page));
  const qs = params.toString();
  return qs ? `/notifications?${qs}` : "/notifications";
}

export function LogTable({ logs, total, page, totalPages, filters }: Props) {
  const router = useRouter();
  const [type, setType] = useState(filters.type);
  const [q, setQ] = useState(filters.q);
  const [from, setFrom] = useState(filters.from);
  const [to, setTo] = useState(filters.to);

  function applyFilters() {
    router.push(buildUrl({ type, q, from, to, page: 1 }));
  }

  function clearFilters() {
    setType("");
    setQ("");
    setFrom("");
    setTo("");
    router.push("/notifications");
  }

  function goToPage(p: number) {
    router.push(buildUrl({ type, q, from, to, page: p }));
  }

  const hasFilters = type || q || from || to;

  return (
    <div>
      <h3 className="text-lg font-semibold mb-4">Notification Log</h3>

      <div className="flex items-end gap-3 mb-4 flex-wrap">
        <div className="flex-1 min-w-[200px]">
          <label className="block text-xs text-gray-500 mb-1">Search</label>
          <input
            type="text"
            placeholder="User, title, or body..."
            value={q}
            onChange={(e) => setQ(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && applyFilters()}
            className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-blue-500"
          />
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">Type</label>
          <select
            value={type}
            onChange={(e) => setType(e.target.value)}
            className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
          >
            <option value="">All</option>
            <option value="reminder">Reminder</option>
            <option value="digest">Digest</option>
            <option value="support_reply">Support Reply</option>
          </select>
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">From</label>
          <input
            type="date"
            value={from}
            onChange={(e) => setFrom(e.target.value)}
            className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
          />
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">To</label>
          <input
            type="date"
            value={to}
            onChange={(e) => setTo(e.target.value)}
            className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
          />
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
        {total} notification{total !== 1 ? "s" : ""}
        {hasFilters ? " matching filters" : ""}
      </div>

      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#38383A] text-gray-500 text-left">
              <th className="px-5 py-3">User</th>
              <th className="px-5 py-3">Title</th>
              <th className="px-5 py-3">Body</th>
              <th className="px-5 py-3">Renewal</th>
              <th className="px-5 py-3">Type</th>
              <th className="px-5 py-3">Status</th>
              <th className="px-5 py-3">Sent</th>
            </tr>
          </thead>
          <tbody>
            {logs.map((n) => (
              <tr
                key={n.id}
                className="border-b border-[#38383A] hover:bg-[#2C2C2E]"
              >
                <td className="px-5 py-3">
                  <div className="font-medium">{n.user_name || "—"}</div>
                  {n.user_email && (
                    <div className="text-xs text-gray-500">{n.user_email}</div>
                  )}
                </td>
                <td className="px-5 py-3 font-medium">{n.title}</td>
                <td className="px-5 py-3 text-gray-400 max-w-[250px] truncate">
                  {n.body}
                </td>
                <td className="px-5 py-3 text-gray-400">{n.renewal_name || "—"}</td>
                <td className="px-5 py-3">
                  <span
                    className={`px-2 py-0.5 rounded-full text-xs ${
                      n.type === "reminder"
                        ? "bg-orange-500/20 text-orange-400"
                        : n.type === "digest"
                          ? "bg-blue-500/20 text-blue-400"
                          : "bg-purple-500/20 text-purple-400"
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
                <td className="px-5 py-3 text-gray-500 whitespace-nowrap" suppressHydrationWarning>
                  {new Date(n.created_at).toLocaleString()}
                </td>
              </tr>
            ))}
            {logs.length === 0 && (
              <tr>
                <td colSpan={7} className="px-5 py-8 text-center text-gray-500">
                  No notifications found
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
