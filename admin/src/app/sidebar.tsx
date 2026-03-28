"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

const nav = [
  { href: "/", label: "Dashboard", icon: "📊" },
  { href: "/users", label: "Users", icon: "👥" },
  { href: "/analytics", label: "Analytics", icon: "📈" },
  { href: "/notifications", label: "Notifications", icon: "🔔" },
  { href: "/config", label: "App Config", icon: "⚙️" },
];

export function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="w-56 bg-[#1C1C1E] border-r border-[#38383A] fixed h-full">
      <div className="p-6">
        <h1 className="text-lg font-bold text-white">Renewd Admin</h1>
        <p className="text-xs text-gray-500 mt-1">Management Console</p>
      </div>
      <nav className="mt-2">
        {nav.map((item) => {
          const active = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-6 py-3 text-sm transition-colors ${
                active
                  ? "bg-[#2C2C2E] text-white border-r-2 border-blue-500"
                  : "text-gray-400 hover:text-white hover:bg-[#2C2C2E]"
              }`}
            >
              <span>{item.icon}</span>
              {item.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
