"use client";
import { usePathname } from "next/navigation";
import { Sidebar } from "./sidebar";

export function LayoutShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";

  if (isLogin) {
    return <>{children}</>;
  }

  return (
    <div className="flex">
      <Sidebar />
      <main className="flex-1 p-8 ml-56">{children}</main>
    </div>
  );
}
