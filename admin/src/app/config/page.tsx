import { query } from "@/lib/db";
import { ConfigForm } from "./config-form";

async function getConfig() {
  const rows = await query<{ key: string; value: string; updated_at: string }>(
    "SELECT key, value, updated_at::text FROM app_config WHERE key NOT LIKE 'free_%' AND key NOT LIKE 'premium_%' AND key NOT LIKE 'feature_%' AND key NOT LIKE 'iap_%' ORDER BY key"
  );
  const config: Record<string, { value: string; updated_at: string }> = {};
  for (const row of rows) {
    config[row.key] = { value: row.value, updated_at: row.updated_at };
  }
  return config;
}

export const dynamic = "force-dynamic";

export default async function ConfigPage() {
  const config = await getConfig();

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">App Config</h2>
      <ConfigForm config={config} />
    </div>
  );
}
