-- App configuration (version control, feature flags, etc.)
CREATE TABLE app_config (
  key VARCHAR(50) PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO app_config (key, value) VALUES
  ('min_version', '1.0.0'),
  ('latest_version', '1.0.0'),
  ('force_update', 'false'),
  ('update_message', 'A new version of Renewd is available. Please update for the best experience.');
