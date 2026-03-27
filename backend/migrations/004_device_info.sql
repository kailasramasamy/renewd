-- Device and app version tracking on users
ALTER TABLE users ADD COLUMN device_os VARCHAR(20);
ALTER TABLE users ADD COLUMN device_os_version VARCHAR(20);
ALTER TABLE users ADD COLUMN device_model VARCHAR(100);
ALTER TABLE users ADD COLUMN app_version VARCHAR(20);
