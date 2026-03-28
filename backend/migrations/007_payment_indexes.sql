-- Payment query indexes
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_paid_date ON payments(paid_date);

-- Price change tracking: store previous amount on renewals
ALTER TABLE renewals ADD COLUMN IF NOT EXISTS previous_amount DECIMAL(12,2);
