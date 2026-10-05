-- Escalating reminders: every active renewal gets 3/2/1/0-day reminders, and
-- non-auto-renew renewals get daily overdue nags for 7 days after the due date.
-- Backfill existing renewals; new cycles get these from createRemindersForDays.
INSERT INTO reminders (user_id, renewal_id, days_before, reminder_date)
SELECT ren.user_id, ren.id, d, ren.renewal_date - d
FROM renewals ren
CROSS JOIN unnest(ARRAY[3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7]) AS d
WHERE ren.status = 'active'
  AND ren.renewal_date - d >= CURRENT_DATE
  AND (d >= 0 OR NOT COALESCE(ren.auto_renew, FALSE))
  AND NOT EXISTS (
    SELECT 1 FROM reminders r
    WHERE r.renewal_id = ren.id AND r.days_before = d AND r.reminder_date = ren.renewal_date - d
  );

-- Short-range reminders are now automatic, so free users' one custom reminder is 7 days
UPDATE app_config SET value = '[7]' WHERE key = 'free_reminder_days' AND value = '[1]';
