-- Sprint 4: Reminders + Notifications schema

-- FCM token on users
ALTER TABLE users ADD COLUMN fcm_token TEXT;
ALTER TABLE users ADD COLUMN fcm_token_updated_at TIMESTAMPTZ;

-- Notification preferences (one row per user)
CREATE TABLE notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  enabled BOOLEAN DEFAULT TRUE,
  default_days_before INT[] DEFAULT '{30,7,1}',
  daily_digest_enabled BOOLEAN DEFAULT FALSE,
  daily_digest_hour INT DEFAULT 9,
  quiet_hours_start INT,
  quiet_hours_end INT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Upgrade reminders table
ALTER TABLE reminders ADD COLUMN user_id UUID REFERENCES users(id);
ALTER TABLE reminders ADD COLUMN snoozed_until DATE;
ALTER TABLE reminders ADD COLUMN reminder_date DATE;

-- Backfill user_id from renewals
UPDATE reminders
SET user_id = (SELECT user_id FROM renewals WHERE renewals.id = reminders.renewal_id);

-- Make user_id NOT NULL after backfill
ALTER TABLE reminders ALTER COLUMN user_id SET NOT NULL;

-- Indexes
CREATE INDEX idx_reminders_user_id ON reminders(user_id);
CREATE INDEX idx_reminders_reminder_date ON reminders(reminder_date);
CREATE INDEX idx_reminders_is_sent ON reminders(is_sent);
CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);
