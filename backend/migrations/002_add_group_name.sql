ALTER TABLE renewals ADD COLUMN group_name VARCHAR(100);

-- Set default group_name from category for existing rows
UPDATE renewals SET group_name = INITCAP(category);
