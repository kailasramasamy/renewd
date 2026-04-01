"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";

export function CreateProgram({ onCreated }: { onCreated?: () => void } = {}) {
  const router = useRouter();
  const [saving, setSaving] = useState(false);
  const [values, setValues] = useState({
    app_name: "",
    description: "",
    reward: "₹100 Amazon Gift Card",
    tester_cap: 20,
    platforms: ["android"] as string[],
    android_test_link: "",
    ios_test_link: "",
  });

  function togglePlatform(p: string) {
    setValues((v) => ({
      ...v,
      platforms: v.platforms.includes(p)
        ? v.platforms.filter((x) => x !== p)
        : [...v.platforms, p],
    }));
  }

  async function create() {
    if (!values.app_name.trim()) {
      alert("App name is required");
      return;
    }
    if (values.platforms.length === 0) {
      alert("Select at least one platform");
      return;
    }
    setSaving(true);
    try {
      const res = await fetch("/api/testers", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(values),
      });
      if (!res.ok) {
        const data = await res.json();
        alert(data.error || "Failed to create");
      } else {
        if (onCreated) onCreated();
        else router.refresh();
      }
    } catch {
      alert("Failed to create");
    }
    setSaving(false);
  }

  return (
    <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-6 max-w-xl mx-auto">
      <h3 className="text-lg font-semibold mb-6">Create Tester Program</h3>

      <div className="space-y-5">
        <div>
          <label className="block text-sm text-gray-400 mb-1">App Name</label>
          <input
            value={values.app_name}
            onChange={(e) => setValues((v) => ({ ...v, app_name: e.target.value }))}
            placeholder="e.g. Renewd"
            className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-blue-500"
          />
        </div>

        <div>
          <label className="block text-sm text-gray-400 mb-1">Description</label>
          <textarea
            value={values.description}
            onChange={(e) => setValues((v) => ({ ...v, description: e.target.value }))}
            rows={2}
            placeholder="What will testers be testing?"
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
          onClick={create}
          disabled={saving}
          className="w-full bg-blue-600 hover:bg-blue-700 text-white text-sm px-6 py-3 rounded-lg transition-colors disabled:opacity-50 font-medium"
        >
          {saving ? "Creating..." : "Create Program"}
        </button>
      </div>
    </div>
  );
}
