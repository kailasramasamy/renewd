-- Chat usage tracking and rate limit config

CREATE TABLE IF NOT EXISTS chat_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  input_tokens INT NOT NULL DEFAULT 0,
  output_tokens INT NOT NULL DEFAULT 0,
  model VARCHAR(50) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_usage_user ON chat_usage(user_id);
CREATE INDEX idx_chat_usage_created ON chat_usage(created_at);

-- Admin-configurable rate limits
INSERT INTO app_config (key, value) VALUES
  ('chat_daily_limit', '50'),
  ('chat_max_message_length', '2000')
ON CONFLICT (key) DO NOTHING;
