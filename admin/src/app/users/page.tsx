import { query } from "@/lib/db";
import { UserTable } from "./user-table";

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
  default_currency: string | null;
  country: string | null;
  created_at: string;
  renewal_count: number;
}

async function getUsers(): Promise<User[]> {
  return query<User>(`
    SELECT u.id, u.name, u.email, u.phone, u.device_os, u.device_model,
           u.app_version, u.is_premium, u.premium_expires_at::text,
           u.default_currency, u.country, u.created_at,
           (SELECT COUNT(*)::int FROM renewals r WHERE r.user_id = u.id) AS renewal_count
    FROM users u ORDER BY u.created_at DESC
  `);
}

export const dynamic = "force-dynamic";

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Users</h2>
      <UserTable users={users} />
    </div>
  );
}
