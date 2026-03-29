import { query } from "@/lib/db";
import { UsageCharts } from "./usage-charts";
import { UsageTable } from "./usage-table";

interface Stats {
  totalMessages: number;
  totalInputTokens: number;
  totalOutputTokens: number;
  uniqueUsers: number;
  estimatedCost: number;
}

interface DailyUsage {
  date: string;
  messages: number;
  tokens: number;
}

interface TopUser {
  id: string;
  name: string;
  email: string;
  messages: number;
  input_tokens: number;
  output_tokens: number;
  total_tokens: number;
  last_used: string;
}

async function getStats(): Promise<Stats> {
  const [row] = await query<{
    total_messages: string;
    total_input: string;
    total_output: string;
    unique_users: string;
  }>(
    `SELECT
       COUNT(*)::text AS total_messages,
       COALESCE(SUM(input_tokens), 0)::text AS total_input,
       COALESCE(SUM(output_tokens), 0)::text AS total_output,
       COUNT(DISTINCT user_id)::text AS unique_users
     FROM chat_usage
     WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'`
  );

  const inputTokens = parseInt(row?.total_input ?? "0", 10);
  const outputTokens = parseInt(row?.total_output ?? "0", 10);

  // Haiku pricing: $0.80/M input, $4/M output
  const cost =
    (inputTokens / 1_000_000) * 0.8 + (outputTokens / 1_000_000) * 4;

  return {
    totalMessages: parseInt(row?.total_messages ?? "0", 10),
    totalInputTokens: inputTokens,
    totalOutputTokens: outputTokens,
    uniqueUsers: parseInt(row?.unique_users ?? "0", 10),
    estimatedCost: Math.round(cost * 100) / 100,
  };
}

async function getDailyUsage(): Promise<DailyUsage[]> {
  const rows = await query<{
    date: string;
    messages: string;
    tokens: string;
  }>(
    `SELECT
       TO_CHAR(created_at, 'YYYY-MM-DD') AS date,
       COUNT(*)::text AS messages,
       COALESCE(SUM(input_tokens + output_tokens), 0)::text AS tokens
     FROM chat_usage
     WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
     GROUP BY date ORDER BY date ASC`
  );
  return rows.map((r) => ({
    date: r.date,
    messages: parseInt(r.messages, 10),
    tokens: parseInt(r.tokens, 10),
  }));
}

async function getTopUsers(): Promise<TopUser[]> {
  return query<TopUser>(
    `SELECT
       u.id, u.name, u.email,
       COUNT(cu.id)::int AS messages,
       COALESCE(SUM(cu.input_tokens), 0)::int AS input_tokens,
       COALESCE(SUM(cu.output_tokens), 0)::int AS output_tokens,
       COALESCE(SUM(cu.input_tokens + cu.output_tokens), 0)::int AS total_tokens,
       MAX(cu.created_at)::text AS last_used
     FROM chat_usage cu
     JOIN users u ON u.id = cu.user_id
     WHERE cu.created_at >= CURRENT_DATE - INTERVAL '30 days'
     GROUP BY u.id, u.name, u.email
     ORDER BY total_tokens DESC
     LIMIT 20`
  );
}

async function getConfig() {
  const rows = await query<{ key: string; value: string }>(
    "SELECT key, value FROM app_config WHERE key IN ('chat_daily_limit', 'chat_max_message_length')"
  );
  const config: Record<string, string> = {};
  for (const row of rows) config[row.key] = row.value;
  return config;
}

export const dynamic = "force-dynamic";

export default async function AIUsagePage() {
  const [stats, daily, topUsers, config] = await Promise.all([
    getStats(),
    getDailyUsage(),
    getTopUsers(),
    getConfig(),
  ]);

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">AI Usage</h2>

      {/* Stat Cards */}
      <div className="grid grid-cols-5 gap-4 mb-8">
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Messages (30d)</p>
          <p className="text-3xl font-bold mt-2">
            {stats.totalMessages.toLocaleString()}
          </p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Input Tokens</p>
          <p className="text-3xl font-bold mt-2">
            {stats.totalInputTokens.toLocaleString()}
          </p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Output Tokens</p>
          <p className="text-3xl font-bold mt-2">
            {stats.totalOutputTokens.toLocaleString()}
          </p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Active Users</p>
          <p className="text-3xl font-bold mt-2">{stats.uniqueUsers}</p>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A]">
          <p className="text-gray-500 text-sm">Est. Cost (30d)</p>
          <p className="text-3xl font-bold mt-2 text-amber-400">
            ${stats.estimatedCost.toFixed(2)}
          </p>
          <p className="text-xs text-gray-600 mt-1">Haiku pricing</p>
        </div>
      </div>

      {/* Charts */}
      <UsageCharts daily={daily} />

      {/* Config summary */}
      <div className="mt-8 grid grid-cols-2 gap-4 mb-8">
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A] flex items-center justify-between">
          <div>
            <p className="text-gray-500 text-sm">Daily Message Limit</p>
            <p className="text-xl font-bold mt-1">
              {config.chat_daily_limit ?? "50"} / user / day
            </p>
          </div>
          <a
            href="/premium"
            className="text-blue-400 hover:text-blue-300 text-sm"
          >
            Edit
          </a>
        </div>
        <div className="bg-[#1C1C1E] rounded-2xl p-5 border border-[#38383A] flex items-center justify-between">
          <div>
            <p className="text-gray-500 text-sm">Max Message Length</p>
            <p className="text-xl font-bold mt-1">
              {config.chat_max_message_length ?? "2000"} chars
            </p>
          </div>
          <a
            href="/premium"
            className="text-blue-400 hover:text-blue-300 text-sm"
          >
            Edit
          </a>
        </div>
      </div>

      {/* Top Users Table */}
      <h3 className="text-lg font-semibold mb-4">
        Top Users by Token Usage (30d)
      </h3>
      <UsageTable users={topUsers} />
    </div>
  );
}
