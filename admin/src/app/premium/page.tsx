import { query } from "@/lib/db";
import { PremiumForm } from "./premium-form";

async function getPremiumConfig() {
  const rows = await query<{ key: string; value: string; updated_at: string }>(
    "SELECT key, value, updated_at::text FROM app_config WHERE key LIKE 'free_%' OR key LIKE 'premium_%' OR key LIKE 'feature_%' OR key LIKE 'iap_%' OR key LIKE 'chat_%' OR key LIKE 'new_user_%' ORDER BY key"
  );
  const config: Record<string, { value: string; updated_at: string }> = {};
  for (const row of rows) {
    config[row.key] = { value: row.value, updated_at: row.updated_at };
  }
  return config;
}

export const dynamic = "force-dynamic";

export default async function PremiumPage() {
  const config = await getPremiumConfig();

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Premium Config</h2>
      <PremiumForm config={config} />
    </div>
  );
}
