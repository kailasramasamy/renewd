import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { requireAdminAuth } from "@/lib/auth";
import Anthropic from "@anthropic-ai/sdk";

const BRAND_DOMAINS: Record<string, string> = {
  netflix: "netflix.com",
  amazon: "amazon.in",
  "amazon prime": "amazon.in",
  spotify: "spotify.com",
  hotstar: "hotstar.com",
  disney: "disneyplus.com",
  jio: "jio.com",
  airtel: "airtel.in",
  vodafone: "vodafone.in",
  vi: "myvi.in",
  "tata aig": "tataaig.com",
  "tata aia": "tataaia.com",
  "tata play": "tataplay.com",
  zee5: "zee5.com",
  youtube: "youtube.com",
  google: "google.com",
  apple: "apple.com",
  microsoft: "microsoft.com",
  adobe: "adobe.com",
  figma: "figma.com",
  notion: "notion.so",
  slack: "slack.com",
  zoom: "zoom.us",
  github: "github.com",
  hdfc: "hdfcergo.com",
  "hdfc ergo": "hdfcergo.com",
  "hdfc bank": "hdfcbank.com",
  icici: "icicilombard.com",
  "icici lombard": "icicilombard.com",
  lic: "licindia.in",
  "star health": "starhealth.in",
  bajaj: "bajajallianz.com",
  "bajaj allianz": "bajajallianz.com",
  sbi: "sbi.co.in",
  "new india": "newindia.co.in",
  acko: "acko.com",
  digit: "godigit.com",
  swiggy: "swiggy.com",
  zomato: "zomato.com",
  cred: "cred.club",
  paytm: "paytm.com",
  phonepe: "phonepe.com",
  gpay: "pay.google.com",
  zoho: "zoho.com",
  freshworks: "freshworks.com",
  salesforce: "salesforce.com",
  hubspot: "hubspot.com",
  stripe: "stripe.com",
  razorpay: "razorpay.com",
};

function findDomain(name: string, provider: string | null): string | null {
  const search = (provider || name).toLowerCase().trim();
  if (BRAND_DOMAINS[search]) return BRAND_DOMAINS[search];
  for (const [brand, domain] of Object.entries(BRAND_DOMAINS)) {
    if (search.includes(brand) || brand.includes(search)) return domain;
  }
  return null;
}

async function findDomainWithAI(
  client: Anthropic,
  name: string,
  provider: string | null
): Promise<string | null> {
  const q = provider ? `${name} by ${provider}` : name;
  try {
    const res = await client.messages.create({
      model: process.env.CLAUDE_MODEL || "claude-haiku-4-5-20251001",
      max_tokens: 50,
      messages: [
        {
          role: "user",
          content: `What is the main website domain for "${q}"? Reply with ONLY the domain (e.g. "netflix.com"), nothing else. If you don't know, reply "unknown".`,
        },
      ],
    });
    const block = res.content[0];
    if (block.type !== "text") return null;
    const domain = block.text.trim().toLowerCase();
    if (domain === "unknown" || domain.includes(" ") || !domain.includes("."))
      return null;
    return domain;
  } catch {
    return null;
  }
}

export async function POST() {
  const authError = await requireAdminAuth();
  if (authError) return authError;

  const client = process.env.CLAUDE_API_KEY
    ? new Anthropic({ apiKey: process.env.CLAUDE_API_KEY })
    : null;

  const rows = await query<{
    id: string;
    name: string;
    provider: string | null;
  }>("SELECT id, name, provider FROM renewals WHERE logo_url IS NULL");

  let updated = 0;
  for (const row of rows) {
    let domain = findDomain(row.name, row.provider);
    if (!domain && client) {
      domain = await findDomainWithAI(client, row.name, row.provider);
    }
    if (domain) {
      const logoUrl = `https://www.google.com/s2/favicons?domain=${domain}&sz=128`;
      await query("UPDATE renewals SET logo_url = $1 WHERE id = $2", [
        logoUrl,
        row.id,
      ]);
      updated++;
    }
  }

  return NextResponse.json({ updated, total: rows.length });
}
