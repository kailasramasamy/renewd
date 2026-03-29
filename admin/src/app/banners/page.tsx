import { query } from "@/lib/db";
import { BannerList } from "./banner-list";

interface Banner {
  id: string;
  title: string;
  subtitle: string | null;
  type: string;
  bg_color: string | null;
  bg_gradient_start: string | null;
  bg_gradient_end: string | null;
  icon: string | null;
  deeplink: string | null;
  external_url: string | null;
  is_active: boolean;
  priority: number;
  starts_at: string | null;
  ends_at: string | null;
  created_at: string;
}

async function getBanners(): Promise<Banner[]> {
  return query<Banner>(
    "SELECT id, title, subtitle, type, bg_color, bg_gradient_start, bg_gradient_end, icon, deeplink, external_url, is_active, priority, starts_at::text, ends_at::text, created_at::text FROM banners ORDER BY priority DESC, created_at DESC"
  );
}

export const dynamic = "force-dynamic";

export default async function BannersPage() {
  const banners = await getBanners();

  return (
    <div>
      <h2 className="text-2xl font-bold mb-6">Banners</h2>
      <BannerList banners={banners} />
    </div>
  );
}
