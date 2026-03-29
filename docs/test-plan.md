# Renewd — Test Plan

## 1. Auth Flows

| # | Test | Steps | Pass |
|---|------|-------|------|
| 1.1 | Phone OTP login | Enter phone → get OTP → verify → lands on complete profile or home | |
| 1.2 | Google login | Tap Google → auth → complete profile or home | |
| 1.3 | Apple login | Tap Apple → auth → complete profile or home | |
| 1.4 | Complete profile | Fill name → save → lands on home | |
| 1.5 | Token persistence | Login → kill app → reopen → should stay logged in | |
| 1.6 | Sign out | Profile → Sign Out → lands on login | |
| 1.7 | Delete account | Profile → Delete Account → confirm → lands on login → user gone from admin | |

## 2. Renewals CRUD

| # | Test | Steps | Pass |
|---|------|-------|------|
| 2.1 | Add manually | + → Add Manually → fill fields → save → appears on dashboard | |
| 2.2 | Add via scan | + → Scan Document → take photo → AI extracts → review → save | |
| 2.3 | Add via file pick | Browse Files → pick PDF → AI extracts → save | |
| 2.4 | View detail | Tap renewal → see details, reminders, payments, documents | |
| 2.5 | Edit renewal | Detail → Edit → change fields → save → reflected | |
| 2.6 | Delete renewal | Detail → Delete → confirm → gone from dashboard | |
| 2.7 | Mark renewed | Detail → Mark Renewed → date advances to next cycle | |
| 2.8 | Categories | Categories tab → renewals grouped correctly | |

## 3. Documents & Vault

| # | Test | Steps | Pass |
|---|------|-------|------|
| 3.1 | Upload from camera | Scan → camera → capture → uploaded | |
| 3.2 | Upload from gallery | Photo Library → pick image → uploaded | |
| 3.3 | Upload from files | Browse Files → pick PDF → uploaded | |
| 3.4 | View document | Vault → tap document → PDF/image viewer opens | |
| 3.5 | Link to renewal | Unlinked doc → link → appears under renewal | |
| 3.6 | Rename document | Document → rename → name updated | |
| 3.7 | Delete document | Document → delete → gone from vault | |
| 3.8 | Search documents | Vault → search by name → results shown | |

## 4. AI Chat

| # | Test | Steps | Pass |
|---|------|-------|------|
| 4.1 | Ask about renewals | "What's expiring this month?" → AI responds with data | |
| 4.2 | Ask about spending | "How much did I spend on insurance?" → AI uses tools | |
| 4.3 | Empty state | New user with no renewals → AI responds gracefully | |

## 5. Notifications

| # | Test | Steps | Pass |
|---|------|-------|------|
| 5.1 | Notification preferences | Profile → Notifications → toggle settings → saved | |
| 5.2 | Push notification | Create renewal expiring tomorrow → wait for push (or trigger via backend) | |
| 5.3 | Notification inbox | Bell icon → shows notifications → mark read | |
| 5.4 | Snooze | Tap notification → snooze → snoozed until tomorrow | |

## 6. Premium & Gating

| # | Test | Steps | Pass |
|---|------|-------|------|
| 6.1 | Premium screen | Profile → Premium → shows plan, features, pricing | |
| 6.2 | Feature gate (when enabled) | Set feature to "Premium Only" in admin → free user sees lock overlay | |
| 6.3 | Renewal limit (when enabled) | Set limit to 2 in admin → create 3rd → blocked with 403 | |
| 6.4 | Admin toggle | Admin → Users → assign premium → user sees PRO badge | |
| 6.5 | Admin config | Admin → Premium Config → change values → app reflects on next launch | |

## 7. Edge Cases

| # | Test | Steps | Pass |
|---|------|-------|------|
| 7.1 | No internet | Turn off WiFi → app shows errors gracefully, no crashes | |
| 7.2 | Empty states | New user → dashboard shows welcome, vault empty, categories empty | |
| 7.3 | Large PDF | Upload 10+ page PDF → handles without timeout | |
| 7.4 | Duplicate document | Upload same file twice → shows "Duplicate file" error | |
| 7.5 | Session expiry | Wait 1+ hour → make API call → token refreshes or redirects to login | |
| 7.6 | App version check | Set `force_update = true` in admin → app shows update dialog | |

## 8. Data Export

| # | Test | Steps | Pass |
|---|------|-------|------|
| 8.1 | CSV export | Profile → Data Export → share sheet with CSV → open in Numbers/Excel → data correct | |

---

## Bug Tracking

| # | Screen | Bug Description | Expected Behavior | Severity | Status |
|---|--------|----------------|-------------------|----------|--------|
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |

**Severity:** Blocker / Major / Minor / Cosmetic
**Status:** Open / In Progress / Fixed / Won't Fix

## Notes

- Start fresh — delete account, create new one
- Go through each section top to bottom
- Record bugs in the tracking table above
- Fix all blockers before production setup
