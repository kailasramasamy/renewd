-- Widen device columns to handle longer iOS version strings
ALTER TABLE users ALTER COLUMN device_os_version TYPE VARCHAR(100);
ALTER TABLE users ALTER COLUMN device_model TYPE VARCHAR(255);
