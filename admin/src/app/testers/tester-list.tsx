"use client";
import { useState } from "react";

interface Tester {
  id: string;
  name: string;
  email: string;
  platform: string;
  device_info: string | null;
  status: string;
  created_at: string;
  feedback_count: number;
}

export function TesterList({ testers }: { testers: Tester[] }) {
  const [search, setSearch] = useState("");

  const filtered = search.trim()
    ? testers.filter((t) => {
        const q = search.toLowerCase();
        return (
          t.name.toLowerCase().includes(q) ||
          t.email.toLowerCase().includes(q) ||
          t.platform.toLowerCase().includes(q)
        );
      })
    : testers;

  return (
    <div className="mt-8">
      <h3 className="text-lg font-semibold mb-4">
        Testers ({testers.length})
      </h3>

      <div className="mb-4">
        <input
          type="text"
          placeholder="Search by name, email, or platform..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-blue-500"
        />
      </div>

      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#38383A] text-gray-500 text-left">
              <th className="px-5 py-3">Name</th>
              <th className="px-5 py-3">Email</th>
              <th className="px-5 py-3">Platform</th>
              <th className="px-5 py-3">Device</th>
              <th className="px-5 py-3">Feedback</th>
              <th className="px-5 py-3">Status</th>
              <th className="px-5 py-3">Joined</th>
              <th className="px-5 py-3">Feedback Link</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((t) => (
              <tr key={t.id} className="border-b border-[#38383A] hover:bg-[#2C2C2E]">
                <td className="px-5 py-3 font-medium">{t.name}</td>
                <td className="px-5 py-3 text-gray-400">{t.email}</td>
                <td className="px-5 py-3">
                  <span className={`px-2 py-0.5 rounded-full text-xs ${
                    t.platform === "android"
                      ? "bg-green-500/20 text-green-400"
                      : "bg-blue-500/20 text-blue-400"
                  }`}>
                    {t.platform === "android" ? "Android" : "iOS"}
                  </span>
                </td>
                <td className="px-5 py-3 text-gray-400">{t.device_info || "—"}</td>
                <td className="px-5 py-3">
                  <span className="bg-purple-500/20 text-purple-400 px-2 py-0.5 rounded-full text-xs">
                    {t.feedback_count}
                  </span>
                </td>
                <td className="px-5 py-3">
                  <span className={`px-2 py-0.5 rounded-full text-xs ${
                    t.status === "active"
                      ? "bg-green-500/20 text-green-400"
                      : "bg-red-500/20 text-red-400"
                  }`}>
                    {t.status}
                  </span>
                </td>
                <td className="px-5 py-3 text-gray-500" suppressHydrationWarning>
                  {new Date(t.created_at).toLocaleDateString()}
                </td>
                <td className="px-5 py-3">
                  <button
                    onClick={() => navigator.clipboard.writeText(`https://renewd.app/testers-feedback.html?id=${t.id}`)}
                    className="text-blue-400 hover:text-blue-300 text-xs transition-colors"
                  >
                    Copy Link
                  </button>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={8} className="px-5 py-8 text-center text-gray-500">
                  No testers yet
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
