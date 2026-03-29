"use client";
import { useState } from "react";

interface Props {
  config: Record<string, { value: string; updated_at: string }>;
}

const labels: Record<string, string> = {
  free_renewal_limit: "Free Plan — Renewal Limit",
  free_reminder_days: "Free Plan — Reminder Days (JSON array)",
  premium_reminder_days: "Premium — Default Reminder Days (JSON array)",
  premium_monthly_price: "Monthly Price",
  premium_yearly_price: "Yearly Price",
  premium_currency: "Currency Code",
  feature_ai_scan: "AI Document Scanning",
  feature_document_vault: "Document Vault",
  feature_ai_chat: "AI Chat Assistant",
  feature_payment_tracking: "Payment Tracking",
  feature_csv_export: "CSV Export",
  feature_spending_analytics: "Spending Analytics",
  feature_custom_reminders: "Custom Reminders",
  iap_enabled: "IAP Enabled",
  iap_product_monthly: "Monthly Product ID",
  iap_product_yearly: "Yearly Product ID",
  iap_product_lifetime: "Lifetime Product ID",
  chat_daily_limit: "Daily Message Limit (per user)",
  chat_max_message_length: "Max Message Length (chars)",
};

const sections: { title: string; keys: string[] }[] = [
  {
    title: "Plan Limits",
    keys: ["free_renewal_limit", "free_reminder_days", "premium_reminder_days"],
  },
  {
    title: "Pricing",
    keys: ["premium_monthly_price", "premium_yearly_price", "premium_currency"],
  },
  {
    title: "Feature Access",
    keys: [
      "feature_ai_scan",
      "feature_document_vault",
      "feature_ai_chat",
      "feature_payment_tracking",
      "feature_csv_export",
      "feature_spending_analytics",
      "feature_custom_reminders",
    ],
  },
  {
    title: "In-App Purchases",
    keys: [
      "iap_enabled",
      "iap_product_monthly",
      "iap_product_yearly",
      "iap_product_lifetime",
    ],
  },
  {
    title: "AI Chat Limits",
    keys: ["chat_daily_limit", "chat_max_message_length"],
  },
];

const inputClass =
  "w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm";

export function PremiumForm({ config }: Props) {
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

  function renderInput(key: string) {
    if (key === "iap_enabled") {
      return (
        <select
          value={values[key]}
          onChange={(e) => setValues({ ...values, [key]: e.target.value })}
          className={inputClass}
        >
          <option value="true">Enabled</option>
          <option value="false">Disabled</option>
        </select>
      );
    }
    if (key.startsWith("feature_")) {
      return (
        <select
          value={values[key]}
          onChange={(e) => setValues({ ...values, [key]: e.target.value })}
          className={inputClass}
        >
          <option value="all">Everyone</option>
          <option value="premium">Premium Only</option>
          <option value="none">Disabled</option>
        </select>
      );
    }
    return (
      <input
        type="text"
        value={values[key] ?? ""}
        onChange={(e) => setValues({ ...values, [key]: e.target.value })}
        className={inputClass}
      />
    );
  }

  return (
    <div className="space-y-6">
      {sections.map((section) => (
        <div
          key={section.title}
          className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-6"
        >
          <h3 className="text-lg font-semibold mb-4">{section.title}</h3>
          <div className="space-y-5">
            {section.keys.map((key) => {
              const meta = config[key];
              if (!meta) return null;
              return (
                <div key={key}>
                  <label className="block text-sm text-gray-400 mb-1">
                    {labels[key] || key}
                  </label>
                  {renderInput(key)}
                  <p className="text-xs text-gray-600 mt-1" suppressHydrationWarning>
                    Last updated: {new Date(meta.updated_at).toLocaleString()}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      ))}

      <div className="flex items-center gap-4">
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
