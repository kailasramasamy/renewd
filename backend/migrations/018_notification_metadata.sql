-- Add metadata column for flexible notification data (ticket_id, etc.)
ALTER TABLE notification_log ADD COLUMN IF NOT EXISTS metadata JSONB;
