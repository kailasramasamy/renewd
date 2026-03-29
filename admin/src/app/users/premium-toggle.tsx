"use client";
import { useState } from "react";

interface Props {
  userId: string;
  isPremium: boolean;
  expiresAt: string | null;
}

const plans = [
  { label: "Free", value: "free", days: 0, color: "text-gray-400" },
  { label: "1 Month", value: "1m", days: 30, color: "text-blue-400" },
  { label: "3 Months", value: "3m", days: 90, color: "text-blue-400" },
  { label: "1 Year", value: "1y", days: 365, color: "text-amber-400" },
  { label: "Lifetime", value: "lifetime", days: -1, color: "text-amber-400" },
];

export function PremiumToggle({ userId, isPremium, expiresAt }: Props) {
  const [premium, setPremium] = useState(isPremium);
  const [expires, setExpires] = useState(expiresAt);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);

  async function assignPlan(days: number) {
    setLoading(true);
    try {
      const isPro = days !== 0;
      await fetch(`/api/users/${userId}/premium`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          is_premium: isPro,
          duration_days: days > 0 ? days : undefined,
        }),
      });
      setPremium(isPro);
      if (days > 0) {
        const exp = new Date();
        exp.setDate(exp.getDate() + days);
        setExpires(exp.toISOString());
      } else {
        setExpires(null);
      }
      setOpen(false);
    } catch {
      alert("Failed to update");
    }
    setLoading(false);
  }

  function currentLabel() {
    if (!premium) return "Free";
    if (!expires) return "Lifetime";
    const d = Math.ceil(
      (new Date(expires).getTime() - Date.now()) / 86400000
    );
    if (d <= 0) return "Expired";
    if (d <= 31) return `${d}d left`;
    return `until ${new Date(expires).toLocaleDateString()}`;
  }

  return (
    <div className="relative">
      <button
        onClick={() => setOpen(!open)}
        disabled={loading}
        className="flex items-center gap-1.5 disabled:opacity-50"
      >
        <span
          className={`px-2 py-0.5 rounded-full text-xs font-medium ${
            premium
              ? "bg-amber-500/20 text-amber-400"
              : "bg-gray-500/20 text-gray-400"
          }`}
        >
          {premium ? "PRO" : "FREE"}
        </span>
        <span className="text-xs text-gray-500">{currentLabel()}</span>
        <svg
          className="w-3 h-3 text-gray-500"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M19 9l-7 7-7-7"
          />
        </svg>
      </button>

      {open && (
        <div className="absolute z-50 mt-1 right-0 w-44 bg-[#2C2C2E] border border-[#38383A] rounded-lg shadow-xl overflow-hidden">
          <div className="px-3 py-2 border-b border-[#38383A]">
            <span className="text-xs text-gray-500 font-medium">
              Assign Plan
            </span>
          </div>
          {plans.map((plan) => (
            <button
              key={plan.value}
              onClick={() => assignPlan(plan.days)}
              disabled={loading}
              className={`w-full text-left px-3 py-2 text-sm hover:bg-[#38383A] transition-colors disabled:opacity-50 flex items-center justify-between ${plan.color}`}
            >
              {plan.label}
              {plan.value === "free" && !premium && (
                <span className="text-xs text-gray-600">current</span>
              )}
              {plan.value === "lifetime" && premium && !expires && (
                <span className="text-xs text-gray-600">current</span>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
