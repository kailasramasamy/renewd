"use client";
import { useState } from "react";
import { DeleteUser } from "./delete-user";
import { PremiumToggle } from "./premium-toggle";

interface User {
  id: string;
  name: string | null;
  email: string | null;
  phone: string | null;
  device_os: string | null;
  device_model: string | null;
  app_version: string | null;
  is_premium: boolean;
  premium_expires_at: string | null;
  default_currency: string | null;
  country: string | null;
  created_at: string;
  renewal_count: number;
}

const COUNTRY_CODES: Record<string, string> = {
  IN: "India",
  US: "United States",
  GB: "United Kingdom",
  AE: "UAE",
  AU: "Australia",
  CA: "Canada",
  SG: "Singapore",
  JP: "Japan",
  DE: "Germany",
  FR: "France",
  IT: "Italy",
  ES: "Spain",
  NL: "Netherlands",
  BR: "Brazil",
  MX: "Mexico",
  ZA: "South Africa",
  KR: "South Korea",
  CN: "China",
  RU: "Russia",
  SA: "Saudi Arabia",
  NZ: "New Zealand",
  PH: "Philippines",
  MY: "Malaysia",
  TH: "Thailand",
  ID: "Indonesia",
  NG: "Nigeria",
  KE: "Kenya",
  EG: "Egypt",
  PK: "Pakistan",
  BD: "Bangladesh",
};

const CURRENCY_FALLBACK: Record<string, string> = {
  INR: "India",
  USD: "United States",
  EUR: "Europe",
  GBP: "United Kingdom",
  AED: "UAE",
  AUD: "Australia",
  CAD: "Canada",
  SGD: "Singapore",
  JPY: "Japan",
};

function getCountryName(u: User): string {
  if (u.country) return COUNTRY_CODES[u.country] ?? u.country;
  if (u.default_currency) return CURRENCY_FALLBACK[u.default_currency] ?? u.default_currency;
  return "—";
}

export function UserTable({ users }: { users: User[] }) {
  const [search, setSearch] = useState("");

  const filtered = search.trim()
    ? users.filter((u) => {
        const q = search.toLowerCase();
        const country = getCountryName(u).toLowerCase();
        return (
          (u.name?.toLowerCase().includes(q) ?? false) ||
          (u.email?.toLowerCase().includes(q) ?? false) ||
          (u.phone?.includes(q) ?? false) ||
          country.includes(q)
        );
      })
    : users;

  return (
    <div>
      <div className="mb-4">
        <input
          type="text"
          placeholder="Search by name, email, phone, or country..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-blue-500"
        />
      </div>
      <div className="text-sm text-gray-500 mb-3">
        {filtered.length === users.length
          ? `${users.length} users`
          : `${filtered.length} of ${users.length} users`}
      </div>
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-visible">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#38383A] text-gray-500 text-left">
              <th className="px-5 py-3">Name</th>
              <th className="px-5 py-3">Email</th>
              <th className="px-5 py-3">Phone</th>
              <th className="px-5 py-3">Country</th>
              <th className="px-5 py-3">Device</th>
              <th className="px-5 py-3">Version</th>
              <th className="px-5 py-3">Renewals</th>
              <th className="px-5 py-3">Premium</th>
              <th className="px-5 py-3">Joined</th>
              <th className="px-5 py-3"></th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((u) => (
              <tr
                key={u.id}
                className="border-b border-[#38383A] hover:bg-[#2C2C2E] cursor-pointer"
                onClick={() => window.location.href = `/users/${u.id}`}
              >
                <td className="px-5 py-3 font-medium text-blue-400 hover:text-blue-300">{u.name || "—"}</td>
                <td className="px-5 py-3 text-gray-400">{u.email || "—"}</td>
                <td className="px-5 py-3 text-gray-400">{u.phone || "—"}</td>
                <td className="px-5 py-3 text-gray-400">
                  {getCountryName(u)}
                </td>
                <td className="px-5 py-3 text-gray-400">
                  {u.device_os || "—"}
                </td>
                <td className="px-5 py-3">
                  {u.app_version ? (
                    <span className="bg-green-500/20 text-green-400 px-2 py-0.5 rounded-full text-xs">
                      v{u.app_version}
                    </span>
                  ) : "—"}
                </td>
                <td className="px-5 py-3">
                  <span className="bg-blue-500/20 text-blue-400 px-2 py-0.5 rounded-full text-xs">
                    {u.renewal_count}
                  </span>
                </td>
                <td className="px-5 py-3">
                  <PremiumToggle
                    userId={u.id}
                    isPremium={u.is_premium}
                    expiresAt={u.premium_expires_at}
                  />
                </td>
                <td className="px-5 py-3 text-gray-500" suppressHydrationWarning>
                  {new Date(u.created_at).toLocaleDateString()}
                </td>
                <td className="px-5 py-3">
                  <DeleteUser userId={u.id} userName={u.name} />
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td
                  colSpan={10}
                  className="px-5 py-8 text-center text-gray-500"
                >
                  No users found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
