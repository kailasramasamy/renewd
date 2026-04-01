"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";

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

interface Filters {
  category: string;
  q: string;
}

interface Props {
  feedback: FeedbackEntry[];
  total: number;
  page: number;
  totalPages: number;
  filters: Filters;
}

function buildUrl(filters: Partial<Filters> & { page?: number }): string {
  const params = new URLSearchParams();
  if (filters.category) params.set("category", filters.category);
  if (filters.q) params.set("q", filters.q);
  if (filters.page && filters.page > 1) params.set("page", String(filters.page));
  const qs = params.toString();
  return qs ? `/testers/feedback?${qs}` : "/testers/feedback";
}

export function FeedbackTable({ feedback, total, page, totalPages, filters }: Props) {
  const router = useRouter();
  const [category, setCategory] = useState(filters.category);
  const [q, setQ] = useState(filters.q);
  const [expanded, setExpanded] = useState<string | null>(null);

  function applyFilters() {
    router.push(buildUrl({ category, q, page: 1 }));
  }

  function clearFilters() {
    setCategory("");
    setQ("");
    router.push("/testers/feedback");
  }

  function goToPage(p: number) {
    router.push(buildUrl({ category, q, page: p }));
  }

  const hasFilters = category || q;

  const catStyles: Record<string, string> = {
    bug: "bg-red-500/20 text-red-400",
    suggestion: "bg-orange-500/20 text-orange-400",
    general: "bg-blue-500/20 text-blue-400",
  };

  return (
    <div>
      <div className="flex items-end gap-3 mb-4">
        <div className="flex-1 min-w-[200px]">
          <label className="block text-xs text-gray-500 mb-1">Search</label>
          <input
            type="text"
            placeholder="Tester name, title, or description..."
            value={q}
            onChange={(e) => setQ(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && applyFilters()}
            className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-blue-500"
          />
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">Category</label>
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
          >
            <option value="">All</option>
            <option value="bug">Bug</option>
            <option value="suggestion">Suggestion</option>
            <option value="general">General</option>
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
        {total} feedback item{total !== 1 ? "s" : ""}
        {hasFilters ? " matching filters" : ""}
      </div>

      <div className="space-y-3">
        {feedback.map((fb) => (
          <div
            key={fb.id}
            className="bg-[#1C1C1E] rounded-xl border border-[#38383A] p-5 cursor-pointer hover:border-[#48484A] transition-colors"
            onClick={() => setExpanded(expanded === fb.id ? null : fb.id)}
          >
            <div className="flex items-start justify-between gap-4">
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-3 mb-1">
                  <span className={`px-2 py-0.5 rounded-full text-xs ${catStyles[fb.category] ?? catStyles.general}`}>
                    {fb.category}
                  </span>
                  <span className={`px-2 py-0.5 rounded-full text-xs ${
                    fb.platform === "android" ? "bg-green-500/20 text-green-400" : "bg-blue-500/20 text-blue-400"
                  }`}>
                    {fb.platform}
                  </span>
                </div>
                <h4 className="font-semibold text-white">{fb.title}</h4>
                <p className={`text-gray-400 text-sm mt-1 ${expanded === fb.id ? "" : "line-clamp-2"}`}>
                  {fb.description}
                </p>
              </div>
              <div className="text-right shrink-0">
                <div className="text-sm text-gray-400">{fb.tester_name}</div>
                <div className="text-xs text-gray-500">{fb.tester_email}</div>
                <div className="text-xs text-gray-500 mt-1" suppressHydrationWarning>
                  {new Date(fb.created_at).toLocaleString()}
                </div>
              </div>
            </div>
          </div>
        ))}
        {feedback.length === 0 && (
          <div className="text-center text-gray-500 py-8">No feedback yet</div>
        )}
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
