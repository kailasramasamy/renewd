-- Change default reminder days from {30,7,1} to {7,1}
ALTER TABLE notification_preferences ALTER COLUMN default_days_before SET DEFAULT '{7,1}';

-- Update existing rows that still have the old default
UPDATE notification_preferences SET default_days_before = '{7,1}' WHERE default_days_before = '{30,7,1}';
