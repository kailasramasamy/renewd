import type { Pool } from "pg";

// Common brand → domain mappings for Indian market
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

function findDomain(name: string, provider: string | null): string | null {
  const search = (provider || name).toLowerCase().trim();

  // Direct match
  if (BRAND_DOMAINS[search]) return BRAND_DOMAINS[search];

  // Partial match
  for (const [brand, domain] of Object.entries(BRAND_DOMAINS)) {
    if (search.includes(brand) || brand.includes(search)) return domain;
  }

  // Try provider as domain directly (e.g., "Netflix Inc." → "netflix.com")
  const cleaned = search
    .replace(/\s*(inc|ltd|llp|pvt|private|limited|corp|co)\s*\.?\s*/gi, "")
    .trim();
  if (cleaned.length > 2) {
    return `${cleaned.replace(/\s+/g, "")}.com`;
  }

  return null;
}

export function getLogoUrl(name: string, provider: string | null): string | null {
  const domain = findDomain(name, provider);
  if (!domain) return null;
  return `https://logo.clearbit.com/${domain}`;
}

export async function updateRenewalLogo(
  db: Pool,
  renewalId: string,
  name: string,
  provider: string | null
): Promise<void> {
  const logoUrl = getLogoUrl(name, provider);
  if (logoUrl) {
    await db.query("UPDATE renewals SET logo_url = $1 WHERE id = $2", [
      logoUrl,
      renewalId,
    ]);
  }
}
