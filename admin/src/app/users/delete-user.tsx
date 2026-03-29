"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";

interface Props {
  userId: string;
  userName: string | null;
}

export function DeleteUser({ userId, userName }: Props) {
  const [confirming, setConfirming] = useState(false);
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  async function handleDelete() {
    setLoading(true);
    try {
      const res = await fetch(`/api/users/${userId}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Failed");
      setConfirming(false);
      router.refresh();
    } catch {
      alert("Failed to delete user");
    }
    setLoading(false);
  }

  if (confirming) {
    return (
      <div className="flex items-center gap-2">
        <span className="text-xs text-red-400">Delete {userName || "user"}?</span>
        <button
          onClick={handleDelete}
          disabled={loading}
          className="text-xs bg-red-600 hover:bg-red-700 text-white px-2 py-1 rounded disabled:opacity-50"
        >
          {loading ? "..." : "Yes"}
        </button>
        <button
          onClick={() => setConfirming(false)}
          className="text-xs text-gray-500 hover:text-white"
        >
          No
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={() => setConfirming(true)}
      className="text-xs text-gray-500 hover:text-red-400 transition-colors"
    >
      Delete
    </button>
  );
}
