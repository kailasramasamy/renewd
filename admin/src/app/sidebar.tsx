"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  Users,
  BarChart3,
  Bell,
  Settings,
  LogOut,
} from "lucide-react";

const nav = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/users", label: "Users", icon: Users },
  { href: "/analytics", label: "Analytics", icon: BarChart3 },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/config", label: "App Config", icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="w-56 bg-[#1C1C1E] border-r border-[#38383A] fixed h-full flex flex-col">
      <div className="p-6">
        <h1 className="text-lg font-bold text-white">Renewd Admin</h1>
        <p className="text-xs text-gray-500 mt-1">Management Console</p>
      </div>
      <nav className="mt-2 flex-1">
        {nav.map((item) => {
          const active = pathname === item.href;
          const Icon = item.icon;
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
              <Icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>
      <div className="p-4 border-t border-[#38383A]">
        <a
          href="/api/auth/logout"
          className="flex items-center gap-3 px-2 py-2 text-sm text-gray-400 hover:text-red-400 transition-colors"
        >
          <LogOut size={18} />
          Sign Out
        </a>
      </div>
    </aside>
  );
}
