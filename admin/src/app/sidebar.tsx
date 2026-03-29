"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import {
  LayoutDashboard,
  Users,
  BarChart3,
  Bell,
  Settings,
  Crown,
  Image,
  LifeBuoy,
  LogOut,
} from "lucide-react";

const nav = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/users", label: "Users", icon: Users },
  { href: "/analytics", label: "Analytics", icon: BarChart3 },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/config", label: "App Config", icon: Settings },
  { href: "/premium", label: "Premium Config", icon: Crown },
  { href: "/banners", label: "Banners", icon: Image },
  { href: "/support", label: "Support", icon: LifeBuoy, badge: true },
];

export function Sidebar() {
  const pathname = usePathname();
  const [supportCount, setSupportCount] = useState(0);

  useEffect(() => {
    fetchSupportCount();
    const interval = setInterval(fetchSupportCount, 30000);
    const onUpdate = () => fetchSupportCount();
    window.addEventListener("support-updated", onUpdate);
    return () => {
      clearInterval(interval);
      window.removeEventListener("support-updated", onUpdate);
    };
  }, []);

  async function fetchSupportCount() {
    try {
      const res = await fetch("/api/support/unread");
      const data = await res.json();
      setSupportCount(data.count ?? 0);
    } catch {
      // ignore
    }
  }

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
          const count = item.badge ? supportCount : 0;
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
              {count > 0 && (
                <span className="ml-auto bg-red-500 text-white text-xs font-bold w-5 h-5 rounded-full flex items-center justify-center">
                  {count}
                </span>
              )}
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
