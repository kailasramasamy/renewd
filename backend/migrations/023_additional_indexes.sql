-- Additional composite and single-column indexes for query optimization

-- HIGH: Duplicate detection on every document upload
CREATE INDEX IF NOT EXISTS idx_documents_file_hash ON documents(file_hash);

-- HIGH: Document-to-renewal linking queries
CREATE INDEX IF NOT EXISTS idx_documents_user_renewal ON documents(user_id, renewal_id);

-- HIGH: Reminder retrieval by renewal + user (common WHERE pattern)
CREATE INDEX IF NOT EXISTS idx_reminders_renewal_user ON reminders(renewal_id, user_id);

-- HIGH: Job processors scan all active renewals (daily-reminder-check, daily-digest)
CREATE INDEX IF NOT EXISTS idx_renewals_status ON renewals(status);

-- MEDIUM: Main renewal list ordered by date per user
CREATE INDEX IF NOT EXISTS idx_renewals_user_renewal_date ON renewals(user_id, renewal_date ASC);

-- MEDIUM: Support ticket listing by user with status filtering
CREATE INDEX IF NOT EXISTS idx_support_tickets_user_status ON support_tickets(user_id, status);

-- MEDIUM: Ticket reply thread ordering
CREATE INDEX IF NOT EXISTS idx_ticket_replies_ticket_created ON ticket_replies(ticket_id, created_at ASC);
