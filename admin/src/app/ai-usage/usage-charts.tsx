"use client";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
  Line,
  ComposedChart,
} from "recharts";

interface DailyUsage {
  date: string;
  messages: number;
  tokens: number;
}

export function UsageCharts({ daily }: { daily: DailyUsage[] }) {
  return (
    <div className="grid grid-cols-2 gap-6">
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
        <h3 className="text-sm font-semibold text-gray-400 mb-4">
          Daily Messages
        </h3>
        <ResponsiveContainer width="100%" height={250}>
          <BarChart data={daily}>
            <CartesianGrid strokeDasharray="3 3" stroke="#38383A" />
            <XAxis
              dataKey="date"
              tick={{ fill: "#6B7280", fontSize: 11 }}
              axisLine={false}
              tickLine={false}
              tickFormatter={(v) => v.slice(5)}
            />
            <YAxis
              tick={{ fill: "#6B7280", fontSize: 12 }}
              axisLine={false}
              tickLine={false}
            />
            <Tooltip
              contentStyle={{
                background: "#2C2C2E",
                border: "1px solid #38383A",
                borderRadius: 8,
                color: "#fff",
              }}
              formatter={(value) => [
                Number(value).toLocaleString(),
                "Messages",
              ]}
              labelFormatter={(label) => label}
            />
            <Bar dataKey="messages" fill="#3B82F6" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
        <h3 className="text-sm font-semibold text-gray-400 mb-4">
          Daily Token Usage
        </h3>
        <ResponsiveContainer width="100%" height={250}>
          <ComposedChart data={daily}>
            <CartesianGrid strokeDasharray="3 3" stroke="#38383A" />
            <XAxis
              dataKey="date"
              tick={{ fill: "#6B7280", fontSize: 11 }}
              axisLine={false}
              tickLine={false}
              tickFormatter={(v) => v.slice(5)}
            />
            <YAxis
              tick={{ fill: "#6B7280", fontSize: 12 }}
              axisLine={false}
              tickLine={false}
              tickFormatter={(v) =>
                v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v
              }
            />
            <Tooltip
              contentStyle={{
                background: "#2C2C2E",
                border: "1px solid #38383A",
                borderRadius: 8,
                color: "#fff",
              }}
              formatter={(value) => [
                Number(value).toLocaleString(),
                "Tokens",
              ]}
              labelFormatter={(label) => label}
            />
            <Bar dataKey="tokens" fill="#8B5CF6" radius={[4, 4, 0, 0]} opacity={0.6} />
            <Line
              dataKey="tokens"
              stroke="#8B5CF6"
              strokeWidth={2}
              dot={false}
            />
          </ComposedChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
