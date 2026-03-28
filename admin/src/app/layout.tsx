import type { Metadata } from "next";
import "./globals.css";
import { Sidebar } from "./sidebar";

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
      <body className="bg-[#111] text-gray-100 min-h-screen flex">
        <Sidebar />
        <main className="flex-1 p-8 ml-56">{children}</main>
      </body>
    </html>
  );
}
