-- Configurable premium trial for new users (0 = no trial, -1 = lifetime)
INSERT INTO app_config (key, value) VALUES ('new_user_trial_days', '0')
ON CONFLICT (key) DO NOTHING;
