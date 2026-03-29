-- Add default currency to users (auto-detected from locale)
ALTER TABLE users ADD COLUMN IF NOT EXISTS default_currency VARCHAR(3) DEFAULT 'INR';
