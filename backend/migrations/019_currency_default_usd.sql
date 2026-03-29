-- Change default currency from INR to USD for international support
ALTER TABLE users ALTER COLUMN default_currency SET DEFAULT 'USD';
