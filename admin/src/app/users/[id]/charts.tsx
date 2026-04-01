"use client";

import {
  PieChart, Pie, Cell, Tooltip, ResponsiveContainer,
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  LineChart, Line,
} from "recharts";

const COLORS = ["#3B82F6", "#34C759", "#FF9F0A", "#BF5AF2", "#FF453A", "#FFCC00", "#64D2FF", "#FF6B6B"];

interface CategoryRow { category: string; count: number; total_amount: number }
interface PaymentMonthRow { month: string; count: number; total_amount: number }
interface AiMonthRow { month: string; messages: number; input_tokens: number; output_tokens: number }

export function UserAnalyticsCharts({
  renewalsByCategory,
  paymentsByMonth,
  aiUsageByMonth,
}: {
  renewalsByCategory: CategoryRow[];
  paymentsByMonth: PaymentMonthRow[];
  aiUsageByMonth: AiMonthRow[];
}) {
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* Renewals pie chart */}
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
        <h3 className="font-semibold mb-4">Renewals Distribution</h3>
        {renewalsByCategory.length > 0 ? (
          <ResponsiveContainer width="100%" height={220}>
            <PieChart>
              <Pie
                data={renewalsByCategory}
                dataKey="count"
                nameKey="category"
                cx="50%"
                cy="50%"
                outerRadius={80}
                label={({ name, value }) => `${name} (${value})`}
                labelLine={false}
              >
                {renewalsByCategory.map((_, i) => (
                  <Cell key={i} fill={COLORS[i % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip
                contentStyle={{ background: "#2C2C2E", border: "1px solid #38383A", borderRadius: 8 }}
                labelStyle={{ color: "#F2F2F7" }}
              />
            </PieChart>
          </ResponsiveContainer>
        ) : (
          <p className="text-gray-500 text-sm">No data</p>
        )}
      </div>

      {/* Payments bar chart */}
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
        <h3 className="font-semibold mb-4">Monthly Spending</h3>
        {paymentsByMonth.length > 0 ? (
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={paymentsByMonth}>
              <CartesianGrid strokeDasharray="3 3" stroke="#38383A" />
              <XAxis
                dataKey="month"
                tick={{ fill: "#8E8E93", fontSize: 11 }}
                tickFormatter={(v) => v.slice(5)}
              />
              <YAxis tick={{ fill: "#8E8E93", fontSize: 11 }} />
              <Tooltip
                contentStyle={{ background: "#2C2C2E", border: "1px solid #38383A", borderRadius: 8 }}
                formatter={(value) => [`₹${Number(value).toLocaleString()}`, "Amount"]}
              />
              <Bar dataKey="total_amount" fill="#3B82F6" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        ) : (
          <p className="text-gray-500 text-sm">No data</p>
        )}
      </div>

      {/* AI usage line chart */}
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] p-5">
        <h3 className="font-semibold mb-4">AI Usage Trend</h3>
        {aiUsageByMonth.length > 0 ? (
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={aiUsageByMonth}>
              <CartesianGrid strokeDasharray="3 3" stroke="#38383A" />
              <XAxis
                dataKey="month"
                tick={{ fill: "#8E8E93", fontSize: 11 }}
                tickFormatter={(v) => v.slice(5)}
              />
              <YAxis tick={{ fill: "#8E8E93", fontSize: 11 }} />
              <Tooltip
                contentStyle={{ background: "#2C2C2E", border: "1px solid #38383A", borderRadius: 8 }}
              />
              <Line type="monotone" dataKey="messages" stroke="#BF5AF2" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        ) : (
          <p className="text-gray-500 text-sm">No data</p>
        )}
      </div>
    </div>
  );
}
