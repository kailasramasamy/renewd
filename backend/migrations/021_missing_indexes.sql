-- Add missing indexes for frequently queried columns

CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_renewals_user_id ON renewals(user_id);
CREATE INDEX IF NOT EXISTS idx_renewals_user_status ON renewals(user_id, status);
CREATE INDEX IF NOT EXISTS idx_documents_user_id ON documents(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_renewal_id ON payments(renewal_id, paid_date DESC);
CREATE INDEX IF NOT EXISTS idx_notification_log_user ON notification_log(user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reminders_renewal ON reminders(renewal_id, is_sent);
CREATE INDEX IF NOT EXISTS idx_notification_prefs_user ON notification_preferences(user_id);
