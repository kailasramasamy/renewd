-- Store actual device country code (e.g. US, IN, GB) detected from locale
ALTER TABLE users ADD COLUMN IF NOT EXISTS country VARCHAR(5);
