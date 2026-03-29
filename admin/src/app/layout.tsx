import type { Metadata } from "next";
import "./globals.css";
import { LayoutShell } from "./layout-shell";

export const metadata: Metadata = {
  title: "Renewd Admin",
  description: "Admin panel for Renewd",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="bg-[#111] text-gray-100 min-h-screen" suppressHydrationWarning>
        <LayoutShell>{children}</LayoutShell>
      </body>
    </html>
  );
}
