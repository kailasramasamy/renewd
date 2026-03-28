"use client";
import { useState } from "react";

interface Props {
  config: Record<string, { value: string; updated_at: string }>;
}

const labels: Record<string, string> = {
  min_version: "Minimum App Version",
  latest_version: "Latest App Version",
  force_update: "Force Update",
  update_message: "Update Message",
};

export function ConfigForm({ config }: Props) {
  const [values, setValues] = useState<Record<string, string>>(
    Object.fromEntries(Object.entries(config).map(([k, v]) => [k, v.value]))
  );
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  async function handleSave() {
    setSaving(true);
    setSaved(false);
    try {
      await fetch("/api/config", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(values),
      });
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    } catch {
      alert("Failed to save");
    }
    setSaving(false);
  }

  return (
    <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-6">
      <div className="space-y-5">
        {Object.entries(config).map(([key, { updated_at }]) => (
          <div key={key}>
            <label className="block text-sm text-gray-400 mb-1">
              {labels[key] || key}
            </label>
            {key === "force_update" ? (
              <select
                value={values[key]}
                onChange={(e) =>
                  setValues({ ...values, [key]: e.target.value })
                }
                className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm"
              >
                <option value="false">No</option>
                <option value="true">Yes</option>
              </select>
            ) : key === "update_message" ? (
              <textarea
                value={values[key]}
                onChange={(e) =>
                  setValues({ ...values, [key]: e.target.value })
                }
                rows={3}
                className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm resize-none"
              />
            ) : (
              <input
                type="text"
                value={values[key]}
                onChange={(e) =>
                  setValues({ ...values, [key]: e.target.value })
                }
                className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm"
              />
            )}
            <p className="text-xs text-gray-600 mt-1">
              Last updated: {new Date(updated_at).toLocaleString()}
            </p>
          </div>
        ))}
      </div>
      <div className="mt-6 flex items-center gap-4">
        <button
          onClick={handleSave}
          disabled={saving}
          className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2.5 rounded-lg text-sm font-medium disabled:opacity-50"
        >
          {saving ? "Saving..." : "Save Changes"}
        </button>
        {saved && (
          <span className="text-green-400 text-sm">Saved successfully</span>
        )}
      </div>
    </div>
  );
}
