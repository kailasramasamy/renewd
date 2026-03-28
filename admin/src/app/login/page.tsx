"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Lock, LogIn } from "lucide-react";

export default function LoginPage() {
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ password }),
      });

      if (!res.ok) {
        setError("Invalid password");
        setLoading(false);
        return;
      }

      router.push("/");
      router.refresh();
    } catch {
      setError("Something went wrong");
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-[#111] flex items-center justify-center">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <Lock size={28} className="text-white" />
          </div>
          <h1 className="text-2xl font-bold text-white">Renewd Admin</h1>
          <p className="text-gray-500 text-sm mt-1">
            Enter admin password to continue
          </p>
        </div>

        <form onSubmit={handleSubmit}>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Admin password"
            autoFocus
            className="w-full bg-[#1C1C1E] border border-[#38383A] rounded-xl px-4 py-3 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-blue-500 transition-colors"
          />
          {error && (
            <p className="text-red-400 text-sm mt-2 text-center">{error}</p>
          )}
          <button
            type="submit"
            disabled={loading || !password}
            className="w-full mt-4 bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white py-3 rounded-xl text-sm font-medium flex items-center justify-center gap-2 transition-colors"
          >
            {loading ? (
              "Signing in..."
            ) : (
              <>
                <LogIn size={16} />
                Sign In
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
