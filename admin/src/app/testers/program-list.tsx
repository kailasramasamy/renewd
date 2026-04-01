"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { CreateProgram } from "./create-program";

interface Program {
  id: string;
  app_name: string;
  description: string | null;
  reward: string;
  platforms: string[];
  tester_cap: number;
  status: string;
  android_test_link: string | null;
  ios_test_link: string | null;
  tester_count: number;
  feedback_count: number;
  created_at: string;
}

export function ProgramList({ programs }: { programs: Program[] }) {
  const router = useRouter();
  const [showCreate, setShowCreate] = useState(false);
  const [editing, setEditing] = useState<string | null>(null);
  const [deleting, setDeleting] = useState<string | null>(null);
  const [copied, setCopied] = useState<string | null>(null);

  async function deleteProgram(id: string) {
    if (!confirm("Delete this program? All testers and feedback will be removed.")) return;
    setDeleting(id);
    try {
      const res = await fetch(`/api/testers/${id}`, { method: "DELETE" });
      if (res.ok) router.refresh();
      else alert("Failed to delete");
    } catch {
      alert("Failed to delete");
    }
    setDeleting(null);
  }

  function copyLink(id: string) {
    navigator.clipboard.writeText(`https://renewd.app/testers.html?id=${id}`);
    setCopied(id);
    setTimeout(() => setCopied(null), 2000);
  }

  const statusColors: Record<string, string> = {
    open: "bg-green-500/20 text-green-400",
    closed: "bg-red-500/20 text-red-400",
    paused: "bg-yellow-500/20 text-yellow-400",
  };

  return (
    <div>
      <div className="flex justify-end mb-6">
        <button
          onClick={() => setShowCreate(!showCreate)}
          className="bg-blue-600 hover:bg-blue-700 text-white text-sm px-4 py-2 rounded-lg transition-colors font-medium"
        >
          {showCreate ? "Cancel" : "+ New Program"}
        </button>
      </div>

      {showCreate && (
        <div className="mb-8">
          <CreateProgram onCreated={() => { setShowCreate(false); router.refresh(); }} />
        </div>
      )}

      {programs.length === 0 && !showCreate ? (
        <div className="bg-[#1C1C1E] rounded-2xl p-8 border border-[#38383A] text-center text-gray-500">
          No programs yet. Create one to get started.
        </div>
      ) : programs.length > 0 && (
        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-[#38383A] text-gray-500 text-left">
                <th className="px-5 py-3">App</th>
                <th className="px-5 py-3">Status</th>
                <th className="px-5 py-3">Testers</th>
                <th className="px-5 py-3">Feedback</th>
                <th className="px-5 py-3">Platforms</th>
                <th className="px-5 py-3">Reward</th>
                <th className="px-5 py-3">Created</th>
                <th className="px-5 py-3"></th>
              </tr>
            </thead>
            <tbody>
              {programs.map((p) => (
                <>
                  <tr key={p.id} className="border-b border-[#38383A] hover:bg-[#2C2C2E]">
                    <td className="px-5 py-3">
                      <div className="font-medium">{p.app_name}</div>
                      {p.description && (
                        <div className="text-xs text-gray-500 mt-0.5 max-w-[200px] truncate">{p.description}</div>
                      )}
                    </td>
                    <td className="px-5 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${statusColors[p.status] ?? statusColors.closed}`}>
                        {p.status}
                      </span>
                    </td>
                    <td className="px-5 py-3">
                      <span className="font-medium">{p.tester_count}</span>
                      <span className="text-gray-500"> / {p.tester_cap}</span>
                    </td>
                    <td className="px-5 py-3">
                      <span className="bg-purple-500/20 text-purple-400 px-2 py-0.5 rounded-full text-xs">
                        {p.feedback_count}
                      </span>
                    </td>
                    <td className="px-5 py-3">
                      {p.platforms.map((pl) => (
                        <span
                          key={pl}
                          className={`px-2 py-0.5 rounded-full text-xs mr-1 ${
                            pl === "android" ? "bg-green-500/20 text-green-400" : "bg-blue-500/20 text-blue-400"
                          }`}
                        >
                          {pl === "android" ? "Android" : "iOS"}
                        </span>
                      ))}
                    </td>
                    <td className="px-5 py-3 text-yellow-400 text-xs">{p.reward}</td>
                    <td className="px-5 py-3 text-gray-500 whitespace-nowrap" suppressHydrationWarning>
                      {new Date(p.created_at).toLocaleDateString()}
                    </td>
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => copyLink(p.id)}
                          className="text-blue-400 hover:text-blue-300 text-xs transition-colors"
                        >
                          {copied === p.id ? "Copied!" : "Copy Link"}
                        </button>
                        <button
                          onClick={() => setEditing(editing === p.id ? null : p.id)}
                          className="text-gray-400 hover:text-white text-xs transition-colors"
                        >
                          {editing === p.id ? "Close" : "Edit"}
                        </button>
                        <button
                          onClick={() => deleteProgram(p.id)}
                          disabled={deleting === p.id}
                          className="text-red-400 hover:text-red-300 text-xs transition-colors disabled:opacity-50"
                        >
                          {deleting === p.id ? "..." : "Delete"}
                        </button>
                      </div>
                    </td>
                  </tr>
                  {editing === p.id && (
                    <tr key={`${p.id}-edit`}>
                      <td colSpan={8} className="p-0">
                        <EditForm program={p} onSaved={() => { setEditing(null); router.refresh(); }} />
                      </td>
                    </tr>
                  )}
                </>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function EditForm({ program, onSaved }: { program: Program; onSaved: () => void }) {
  const [saving, setSaving] = useState(false);
  const [values, setValues] = useState({
    description: program.description ?? "",
    reward: program.reward,
    tester_cap: program.tester_cap,
    status: program.status,
    platforms: program.platforms,
    android_test_link: program.android_test_link ?? "",
    ios_test_link: program.ios_test_link ?? "",
  });

  function togglePlatform(p: string) {
    setValues((v) => ({
      ...v,
      platforms: v.platforms.includes(p)
        ? v.platforms.filter((x) => x !== p)
        : [...v.platforms, p],
    }));
  }

  async function save() {
    setSaving(true);
    try {
      const res = await fetch(`/api/testers/${program.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(values),
      });
      if (res.ok) onSaved();
      else alert("Failed to save");
    } catch {
      alert("Failed to save");
    }
    setSaving(false);
  }

  return (
    <div className="border-t border-[#38383A] p-5 bg-[#161618] space-y-4">
      <div className="flex gap-3">
        {["open", "closed", "paused"].map((s) => (
          <button
            key={s}
            onClick={() => setValues((v) => ({ ...v, status: s }))}
            className={`px-4 py-1.5 rounded-lg text-xs font-medium border transition-colors ${
              values.status === s
                ? s === "open"
                  ? "border-green-500 bg-green-500/20 text-green-400"
                  : s === "closed"
                    ? "border-red-500 bg-red-500/20 text-red-400"
                    : "border-yellow-500 bg-yellow-500/20 text-yellow-400"
                : "border-[#38383A] text-gray-400 hover:text-white"
            }`}
          >
            {s.charAt(0).toUpperCase() + s.slice(1)}
          </button>
        ))}
      </div>

      <textarea
        value={values.description}
        onChange={(e) => setValues((v) => ({ ...v, description: e.target.value }))}
        rows={2}
        placeholder="Description"
        className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
      />

      <div className="grid grid-cols-2 gap-4">
        <input
          value={values.reward}
          onChange={(e) => setValues((v) => ({ ...v, reward: e.target.value }))}
          placeholder="Reward"
          className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
        />
        <input
          type="number"
          value={values.tester_cap}
          onChange={(e) => setValues((v) => ({ ...v, tester_cap: parseInt(e.target.value) || 0 }))}
          placeholder="Cap"
          className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-blue-500"
        />
      </div>

      <div className="flex gap-3">
        {["android", "ios"].map((pl) => (
          <button
            key={pl}
            onClick={() => togglePlatform(pl)}
            className={`px-4 py-1.5 rounded-lg text-xs font-medium border transition-colors ${
              values.platforms.includes(pl)
                ? "border-blue-500 bg-blue-500/20 text-blue-400"
                : "border-[#38383A] text-gray-400 hover:text-white"
            }`}
          >
            {pl === "android" ? "Android" : "iOS"}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-2 gap-4">
        <input
          value={values.android_test_link}
          onChange={(e) => setValues((v) => ({ ...v, android_test_link: e.target.value }))}
          placeholder="Android test link"
          className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm placeholder-gray-600 focus:outline-none focus:border-blue-500"
        />
        <input
          value={values.ios_test_link}
          onChange={(e) => setValues((v) => ({ ...v, ios_test_link: e.target.value }))}
          placeholder="iOS test link"
          className="bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2 text-white text-sm placeholder-gray-600 focus:outline-none focus:border-blue-500"
        />
      </div>

      <button
        onClick={save}
        disabled={saving}
        className="bg-blue-600 hover:bg-blue-700 text-white text-sm px-6 py-2 rounded-lg transition-colors disabled:opacity-50"
      >
        {saving ? "Saving..." : "Save"}
      </button>
    </div>
  );
}
