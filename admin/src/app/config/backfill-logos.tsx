"use client";
import { useState } from "react";

export function BackfillLogos() {
  const [running, setRunning] = useState(false);
  const [result, setResult] = useState<string | null>(null);

  async function handleBackfill() {
    setRunning(true);
    setResult(null);
    try {
      const res = await fetch("/api/backfill-logos", { method: "POST" });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Failed");
      setResult(`Updated ${data.updated} of ${data.total} renewals`);
    } catch (err) {
      setResult(err instanceof Error ? err.message : "Failed");
    }
    setRunning(false);
  }

  return (
    <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-6">
      <h3 className="text-lg font-semibold mb-2">Backfill Logos</h3>
      <p className="text-sm text-gray-400 mb-4">
        Find and assign logos for renewals that are missing one.
      </p>
      <div className="flex items-center gap-4">
        <button
          onClick={handleBackfill}
          disabled={running}
          className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2.5 rounded-lg text-sm font-medium disabled:opacity-50"
        >
          {running ? "Running..." : "Run Backfill"}
        </button>
        {result && (
          <span className="text-sm text-gray-300">{result}</span>
        )}
      </div>
    </div>
  );
}
