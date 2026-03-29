import { query } from "@/lib/db";
import { DeleteUser } from "./delete-user";
import { PremiumToggle } from "./premium-toggle";

interface User {
  id: string;
  name: string | null;
  email: string | null;
  phone: string | null;
  device_os: string | null;
  device_model: string | null;
  app_version: string | null;
  is_premium: boolean;
  premium_expires_at: string | null;
  created_at: string;
  renewal_count: number;
}

async function getUsers(): Promise<User[]> {
  return query<User>(`
    SELECT u.id, u.name, u.email, u.phone, u.device_os, u.device_model,
           u.app_version, u.is_premium, u.premium_expires_at::text,
           u.created_at,
           (SELECT COUNT(*)::int FROM renewals r WHERE r.user_id = u.id) AS renewal_count
    FROM users u ORDER BY u.created_at DESC
  `);
}

export const dynamic = "force-dynamic";

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Users ({users.length})</h2>
      <div className="bg-[#1C1C1E] rounded-2xl border border-[#38383A] overflow-visible">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-[#38383A] text-gray-500 text-left">
              <th className="px-5 py-3">Name</th>
              <th className="px-5 py-3">Email</th>
              <th className="px-5 py-3">Phone</th>
              <th className="px-5 py-3">Device</th>
              <th className="px-5 py-3">App Version</th>
              <th className="px-5 py-3">Renewals</th>
              <th className="px-5 py-3">Premium</th>
              <th className="px-5 py-3">Joined</th>
              <th className="px-5 py-3"></th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => (
              <tr
                key={u.id}
                className="border-b border-[#38383A] hover:bg-[#2C2C2E]"
              >
                <td className="px-5 py-3 font-medium">
                  {u.name || "—"}
                </td>
                <td className="px-5 py-3 text-gray-400">
                  {u.email || "—"}
                </td>
                <td className="px-5 py-3 text-gray-400">
                  {u.phone || "—"}
                </td>
                <td className="px-5 py-3 text-gray-400">
                  {u.device_os || "—"}
                </td>
                <td className="px-5 py-3">
                  {u.app_version ? (
                    <span className="bg-green-500/20 text-green-400 px-2 py-0.5 rounded-full text-xs">
                      v{u.app_version}
                    </span>
                  ) : "—"}
                </td>
                <td className="px-5 py-3">
                  <span className="bg-blue-500/20 text-blue-400 px-2 py-0.5 rounded-full text-xs">
                    {u.renewal_count}
                  </span>
                </td>
                <td className="px-5 py-3">
                  <PremiumToggle
                    userId={u.id}
                    isPremium={u.is_premium}
                    expiresAt={u.premium_expires_at}
                  />
                </td>
                <td className="px-5 py-3 text-gray-500">
                  {new Date(u.created_at).toLocaleDateString()}
                </td>
                <td className="px-5 py-3">
                  <DeleteUser userId={u.id} userName={u.name} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
