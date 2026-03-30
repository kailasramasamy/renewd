"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";

interface Ticket {
  id: string;
  user_name: string | null;
  user_email: string | null;
  type: string;
  subject: string;
  description: string;
  status: string;
  device_info: string | null;
  reply_count: number;
  needs_response: boolean;
  created_at: string;
  updated_at: string;
}

const statusColors: Record<string, string> = {
  open: "bg-red-500/20 text-red-400",
  in_progress: "bg-amber-500/20 text-amber-400",
  resolved: "bg-green-500/20 text-green-400",
  closed: "bg-gray-500/20 text-gray-400",
};

const typeColors: Record<string, string> = {
  bug: "bg-red-500/20 text-red-400",
  feedback: "bg-blue-500/20 text-blue-400",
  feature: "bg-purple-500/20 text-purple-400",
  question: "bg-amber-500/20 text-amber-400",
};

export function TicketList({ tickets }: { tickets: Ticket[] }) {
  const [expanded, setExpanded] = useState<string | null>(null);
  const [replies, setReplies] = useState<Record<string, Array<{ id: string; sender: string; message: string; created_at: string }>>>({});
  const [replyText, setReplyText] = useState("");
  const [sending, setSending] = useState(false);
  const [filter, setFilter] = useState("all");
  const router = useRouter();

  async function fetchReplies(ticketId: string) {
    const res = await fetch(`/api/support/${ticketId}/replies`);
    const data = await res.json();
    setReplies((prev) => ({ ...prev, [ticketId]: data.replies }));
  }

  const filtered = filter === "all"
    ? tickets
    : tickets.filter((t) => t.status === filter);

  function notifySidebar() {
    window.dispatchEvent(new Event("support-updated"));
  }

  async function sendReply(ticketId: string) {
    if (!replyText.trim()) return;
    setSending(true);
    await fetch(`/api/support/${ticketId}/reply`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: replyText }),
    });
    setReplyText("");
    setSending(false);
    await fetchReplies(ticketId);
    notifySidebar();
    router.refresh();
  }

  async function updateStatus(ticketId: string, status: string) {
    await fetch(`/api/support/${ticketId}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status }),
    });
    notifySidebar();
    router.refresh();
  }

  return (
    <div className="space-y-4">
      {/* Filter */}
      <div className="flex gap-2">
        {["all", "open", "in_progress", "resolved", "closed"].map((s) => (
          <button
            key={s}
            onClick={() => setFilter(s)}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium ${
              filter === s
                ? "bg-blue-600 text-white"
                : "bg-[#2C2C2E] text-gray-400 hover:text-white"
            }`}
          >
            {s === "all" ? "All" : s.replace("_", " ").replace(/\b\w/g, (c) => c.toUpperCase())}
          </button>
        ))}
      </div>

      {/* Tickets */}
      {filtered.map((t) => (
        <div
          key={t.id}
          className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-hidden"
        >
          {/* Header */}
          <div
            className="p-5 cursor-pointer hover:bg-[#2C2C2E] transition-colors"
            onClick={() => {
              const newId = expanded === t.id ? null : t.id;
              setExpanded(newId);
              if (newId) fetchReplies(newId);
            }}
          >
            <div className="flex items-start justify-between gap-4">
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <span className={`px-2 py-0.5 rounded-full text-xs ${typeColors[t.type] || typeColors.feedback}`}>
                    {t.type}
                  </span>
                  <span className={`px-2 py-0.5 rounded-full text-xs ${statusColors[t.status]}`}>
                    {t.status.replace("_", " ")}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <h3 className="font-semibold text-sm truncate">{t.subject}</h3>
                  {t.needs_response && (
                    <span className="shrink-0 w-2 h-2 rounded-full bg-blue-500" title="Needs response" />
                  )}
                </div>
                <p className="text-xs text-gray-500 mt-1" suppressHydrationWarning>
                  {t.user_name || t.user_email || "Unknown"} · {new Date(t.created_at).toLocaleDateString()} · {t.reply_count} replies
                  {t.needs_response && <span className="text-blue-400 ml-1">· Awaiting reply</span>}
                </p>
              </div>
              <svg
                className={`w-4 h-4 text-gray-500 transition-transform ${expanded === t.id ? "rotate-180" : ""}`}
                fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}
              >
                <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
              </svg>
            </div>
          </div>

          {/* Expanded */}
          {expanded === t.id && (
            <div className="border-t border-[#38383A] p-5 space-y-4">
              {/* Description */}
              <div>
                <p className="text-xs text-gray-500 mb-1">Description</p>
                <p className="text-sm text-gray-300 whitespace-pre-wrap">{t.description}</p>
              </div>

              {t.device_info && (
                <div>
                  <p className="text-xs text-gray-500 mb-1">Device</p>
                  <p className="text-xs text-gray-400">{t.device_info}</p>
                </div>
              )}

              {/* Status change */}
              <div className="flex gap-2">
                <p className="text-xs text-gray-500 self-center mr-2">Set status:</p>
                {["open", "in_progress", "resolved", "closed"].map((s) => (
                  <button
                    key={s}
                    onClick={() => updateStatus(t.id, s)}
                    className={`px-2 py-1 rounded text-xs ${
                      t.status === s
                        ? "bg-blue-600 text-white"
                        : "bg-[#2C2C2E] text-gray-400 hover:text-white"
                    }`}
                  >
                    {s.replace("_", " ")}
                  </button>
                ))}
              </div>

              {/* Conversation */}
              {replies[t.id] && replies[t.id].length > 0 && (
                <div>
                  <p className="text-xs text-gray-500 mb-2">Conversation</p>
                  <div className="space-y-2">
                    {replies[t.id].map((r) => (
                      <div
                        key={r.id}
                        className={`p-3 rounded-lg text-sm ${
                          r.sender === "admin"
                            ? "bg-blue-500/10 border border-blue-500/20"
                            : "bg-[#2C2C2E]"
                        }`}
                      >
                        <div className="flex justify-between items-center mb-1">
                          <span className={`text-xs font-semibold ${
                            r.sender === "admin" ? "text-blue-400" : "text-gray-400"
                          }`}>
                            {r.sender === "admin" ? "You (Admin)" : "User"}
                          </span>
                          <span className="text-xs text-gray-600" suppressHydrationWarning>
                            {new Date(r.created_at).toLocaleString()}
                          </span>
                        </div>
                        <p className="text-gray-300">{r.message}</p>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Reply */}
              <div className="flex gap-2">
                <input
                  value={replyText}
                  onChange={(e) => setReplyText(e.target.value)}
                  placeholder="Type your reply..."
                  className="flex-1 bg-[#2C2C2E] border border-[#38383A] rounded-lg px-4 py-2.5 text-white text-sm"
                  onKeyDown={(e) => e.key === "Enter" && sendReply(t.id)}
                />
                <button
                  onClick={() => sendReply(t.id)}
                  disabled={sending || !replyText.trim()}
                  className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2.5 rounded-lg text-sm font-medium disabled:opacity-50"
                >
                  {sending ? "..." : "Reply"}
                </button>
              </div>
            </div>
          )}
        </div>
      ))}

      {filtered.length === 0 && (
        <div className="text-center py-12 text-gray-500">
          No {filter === "all" ? "" : filter.replace("_", " ")} tickets
        </div>
      )}
    </div>
  );
}
