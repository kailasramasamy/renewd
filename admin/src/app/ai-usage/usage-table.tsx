"use client";

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

function estimateCost(input: number, output: number): string {
  const cost = (input / 1_000_000) * 0.8 + (output / 1_000_000) * 4;
  return cost < 0.01 ? "<$0.01" : `$${cost.toFixed(2)}`;
}

export function UsageTable({ users }: { users: TopUser[] }) {
  return (
    <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-hidden">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-[#38383A] text-gray-500 text-left">
            <th className="px-5 py-3">#</th>
            <th className="px-5 py-3">User</th>
            <th className="px-5 py-3 text-right">Messages</th>
            <th className="px-5 py-3 text-right">Input Tokens</th>
            <th className="px-5 py-3 text-right">Output Tokens</th>
            <th className="px-5 py-3 text-right">Total Tokens</th>
            <th className="px-5 py-3 text-right">Est. Cost</th>
            <th className="px-5 py-3">Last Used</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u, i) => (
            <tr
              key={u.id}
              className="border-b border-[#38383A] hover:bg-[#2C2C2E]"
            >
              <td className="px-5 py-3 text-gray-500">{i + 1}</td>
              <td className="px-5 py-3">
                <div>
                  <span className="font-medium">{u.name || "—"}</span>
                  {u.email && (
                    <span className="text-gray-500 ml-2 text-xs">
                      {u.email}
                    </span>
                  )}
                </div>
              </td>
              <td className="px-5 py-3 text-right">
                {u.messages.toLocaleString()}
              </td>
              <td className="px-5 py-3 text-right text-gray-400">
                {u.input_tokens.toLocaleString()}
              </td>
              <td className="px-5 py-3 text-right text-gray-400">
                {u.output_tokens.toLocaleString()}
              </td>
              <td className="px-5 py-3 text-right font-medium">
                {u.total_tokens.toLocaleString()}
              </td>
              <td className="px-5 py-3 text-right text-amber-400">
                {estimateCost(u.input_tokens, u.output_tokens)}
              </td>
              <td className="px-5 py-3 text-gray-400" suppressHydrationWarning>
                {new Date(u.last_used).toLocaleDateString()}
              </td>
            </tr>
          ))}
          {users.length === 0 && (
            <tr>
              <td
                colSpan={8}
                className="px-5 py-8 text-center text-gray-500"
              >
                No chat usage recorded yet
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
