-- Premium/freemium configuration
-- All values are admin-configurable via the admin panel

INSERT INTO app_config (key, value) VALUES
  ('free_renewal_limit', '5'),
  ('free_reminder_days', '[1]'),
  ('premium_reminder_days', '[7,1]'),
  ('premium_monthly_price', '99'),
  ('premium_yearly_price', '799'),
  ('premium_currency', 'INR'),
  ('feature_ai_scan', 'premium'),
  ('feature_document_vault', 'premium'),
  ('feature_ai_chat', 'premium'),
  ('feature_payment_tracking', 'premium'),
  ('feature_csv_export', 'premium'),
  ('feature_spending_analytics', 'premium'),
  ('feature_custom_reminders', 'premium')
ON CONFLICT (key) DO NOTHING;
