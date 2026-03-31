-- Allow support tickets without a user (e.g. public account deletion requests)
ALTER TABLE support_tickets ALTER COLUMN user_id DROP NOT NULL;
