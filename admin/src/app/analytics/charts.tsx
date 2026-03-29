"use client";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from "recharts";

const COLORS = ["#3B82F6", "#8B5CF6", "#10B981", "#F59E0B", "#EF4444", "#6B7280"];

export function Charts({
  byCategory,
  byMonth,
}: {
  byCategory: { name: string; value: number }[];
  byMonth: { month: string; total: number }[];
}) {
  return (
    <div className="grid grid-cols-2 gap-6">
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
        <h3 className="text-sm font-semibold text-gray-400 mb-4">
          Renewals by Category
        </h3>
        <ResponsiveContainer width="100%" height={250}>
          <PieChart>
            <Pie
              data={byCategory}
              dataKey="value"
              nameKey="name"
              cx="50%"
              cy="50%"
              outerRadius={90}
              label={({ name, value }) => `${name} (${value})`}
              labelLine={false}
            >
              {byCategory.map((_, i) => (
                <Cell key={i} fill={COLORS[i % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip
              contentStyle={{
                background: "#2C2C2E",
                border: "1px solid #38383A",
                borderRadius: 8,
                color: "#fff",
              }}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>

      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
        <h3 className="text-sm font-semibold text-gray-400 mb-4">
          Monthly Spending
        </h3>
        <ResponsiveContainer width="100%" height={250}>
          <BarChart data={byMonth}>
            <XAxis
              dataKey="month"
              tick={{ fill: "#6B7280", fontSize: 12 }}
              axisLine={false}
              tickLine={false}
            />
            <YAxis
              tick={{ fill: "#6B7280", fontSize: 12 }}
              axisLine={false}
              tickLine={false}
              tickFormatter={(v) => `₹${v}`}
            />
            <Tooltip
              contentStyle={{
                background: "#2C2C2E",
                border: "1px solid #38383A",
                borderRadius: 8,
                color: "#fff",
              }}
              formatter={(value) => [`₹${Number(value).toLocaleString()}`, "Spent"]}
            />
            <Bar dataKey="total" fill="#3B82F6" radius={[6, 6, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
