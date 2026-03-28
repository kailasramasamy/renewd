import Anthropic from "@anthropic-ai/sdk";
import type { Pool } from "pg";
import { env } from "../config/env.js";

const client = new Anthropic({ apiKey: env.CLAUDE_API_KEY });

// Common brand → domain mappings for fast lookup (no AI call needed)
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
  tata: "tataplay.com",
  "zee tv": "zee5.com",
  zee5: "zee5.com",
  z5: "zee5.com",
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
  bescom: "bescom.co.in",
  bwssb: "bwssb.gov.in",
};

function findDomainFromMap(name: string, provider: string | null): string | null {
  const search = (provider || name).toLowerCase().trim();

  if (BRAND_DOMAINS[search]) return BRAND_DOMAINS[search];

  for (const [brand, domain] of Object.entries(BRAND_DOMAINS)) {
    if (search.includes(brand) || brand.includes(search)) return domain;
  }

  return null;
}

async function findDomainWithAI(name: string, provider: string | null): Promise<string | null> {
  const query = provider ? `${name} by ${provider}` : name;

  try {
    const response = await client.messages.create({
      model: env.CLAUDE_MODEL,
      max_tokens: 50,
      messages: [
        {
          role: "user",
          content: `What is the main website domain for "${query}"? Reply with ONLY the domain (e.g. "netflix.com"), nothing else. If you don't know or it's not a real company/service, reply "unknown".`,
        },
      ],
    });

    const block = response.content[0];
    if (block.type !== "text") return null;

    const domain = block.text.trim().toLowerCase();
    if (domain === "unknown" || domain.includes(" ") || !domain.includes(".")) {
      return null;
    }
    return domain;
  } catch {
    return null;
  }
}

function buildLogoUrl(domain: string): string {
  return `https://t2.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://${domain}&size=128`;
}

export function getLogoUrl(name: string, provider: string | null): string | null {
  const domain = findDomainFromMap(name, provider);
  if (!domain) return null;
  return buildLogoUrl(domain);
}

export async function updateRenewalLogo(
  db: Pool,
  renewalId: string,
  name: string,
  provider: string | null
): Promise<void> {
  // Try static map first (free, instant)
  let domain = findDomainFromMap(name, provider);

  // Fall back to AI lookup (costs tokens, but accurate)
  if (!domain) {
    domain = await findDomainWithAI(name, provider);
  }

  if (domain) {
    const logoUrl = buildLogoUrl(domain);
    await db.query("UPDATE renewals SET logo_url = $1 WHERE id = $2", [
      logoUrl,
      renewalId,
    ]);
  }
}
