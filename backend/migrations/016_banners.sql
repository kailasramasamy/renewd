-- Banner system for home screen promotions and announcements
CREATE TABLE IF NOT EXISTS banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(100) NOT NULL,
  subtitle VARCHAR(200),
  type VARCHAR(20) DEFAULT 'info',  -- info, promo, feature, announcement
  bg_color VARCHAR(7),              -- hex color e.g. #3B82F6
  bg_gradient_start VARCHAR(7),     -- gradient start color
  bg_gradient_end VARCHAR(7),       -- gradient end color
  icon VARCHAR(30),                 -- lucide icon name
  image_url TEXT,                   -- optional image
  deeplink VARCHAR(100),            -- in-app route e.g. /premium, /features, /chat
  external_url TEXT,                -- optional external link
  is_active BOOLEAN DEFAULT TRUE,
  priority INT DEFAULT 0,           -- higher = shown first
  starts_at TIMESTAMPTZ,            -- optional schedule start
  ends_at TIMESTAMPTZ,              -- optional schedule end
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
