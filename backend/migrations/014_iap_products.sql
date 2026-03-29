-- In-app purchase product configuration
INSERT INTO app_config (key, value) VALUES
  ('iap_enabled', 'true'),
  ('iap_product_monthly', 'renewd_monthly'),
  ('iap_product_yearly', 'renewd_yearly'),
  ('iap_product_lifetime', 'renewd_lifetime');
