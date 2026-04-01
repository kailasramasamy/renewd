"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";

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
}

export function ProgramConfig({ program }: { program: Program }) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
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
      if (!res.ok) {
        const data = await res.json();
        alert(data.error || "Failed to save");
      } else {
        setOpen(false);
        router.refresh();
      }
    } catch {
      alert("Failed to save");
    }
    setSaving(false);
  }

  return (
    <div className="mt-6">
      <button
        onClick={() => setOpen(!open)}
        className="text-blue-400 hover:text-blue-300 text-sm font-medium transition-colors"
      >
        {open ? "Hide Settings" : "Edit Program Settings"}
      </button>

      {open && (
        <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-6 mt-4 space-y-5">
          <div>
            <label className="block text-sm text-gray-400 mb-1">Status</label>
            <div className="flex gap-3">
              {["open", "closed", "paused"].map((s) => (
                <button
                  key={s}
                  onClick={() => setValues((v) => ({ ...v, status: s }))}
                  className={`px-4 py-2 rounded-lg text-sm font-medium border transition-colors ${
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
          </div>

          <div>
            <label className="block text-sm text-gray-400 mb-1">Description</label>
            <textarea
              value={values.description}
              onChange={(e) => setValues((v) => ({ ...v, description: e.target.value }))}
              rows={2}
              className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-blue-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1">Reward</label>
              <input
                value={values.reward}
                onChange={(e) => setValues((v) => ({ ...v, reward: e.target.value }))}
                className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">Tester Cap</label>
              <input
                type="number"
                value={values.tester_cap}
                onChange={(e) => setValues((v) => ({ ...v, tester_cap: parseInt(e.target.value) || 0 }))}
                className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-blue-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm text-gray-400 mb-1">Platforms</label>
            <div className="flex gap-3">
              {["android", "ios"].map((p) => (
                <button
                  key={p}
                  onClick={() => togglePlatform(p)}
                  className={`px-4 py-2 rounded-lg text-sm font-medium border transition-colors ${
                    values.platforms.includes(p)
                      ? "border-blue-500 bg-blue-500/20 text-blue-400"
                      : "border-[#38383A] text-gray-400 hover:text-white"
                  }`}
                >
                  {p === "android" ? "Android" : "iOS"}
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1">Android Test Link</label>
              <input
                value={values.android_test_link}
                onChange={(e) => setValues((v) => ({ ...v, android_test_link: e.target.value }))}
                placeholder="https://play.google.com/apps/testing/..."
                className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm placeholder-gray-600 focus:outline-none focus:border-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1">iOS Test Link</label>
              <input
                value={values.ios_test_link}
                onChange={(e) => setValues((v) => ({ ...v, ios_test_link: e.target.value }))}
                placeholder="https://testflight.apple.com/join/..."
                className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm placeholder-gray-600 focus:outline-none focus:border-blue-500"
              />
            </div>
          </div>

          <button
            onClick={save}
            disabled={saving}
            className="bg-blue-600 hover:bg-blue-700 text-white text-sm px-6 py-2.5 rounded-lg transition-colors disabled:opacity-50"
          >
            {saving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      )}
    </div>
  );
}
