# Renewd — Build Plan

## Sprint 1 (Week 1): Auth + Dashboard Shell ✅ COMPLETED 2026-03-25
**Goal:** User can sign up, log in, and see an empty dashboard

| # | Task | Frontend/Backend | Status |
|---|------|-----------------|--------|
| 1 | Set up PostgreSQL DB, run migrations | Backend | ✅ |
| 2 | npm install, configure .env, verify server starts | Backend | ✅ |
| 3 | Firebase Auth setup (project created) | Both | ✅ |
| 4 | Dev auth bypass (OTP flow deferred to Sprint 7) | Both | ✅ |
| 5 | Dashboard screen with empty state | Frontend | ✅ |
| 6 | Summary cards (Due This Month, Active, Monthly Spend) — live from API | Frontend | ✅ |
| 7 | Bottom nav fully working (all 4 tabs) | Frontend | ✅ |
| 8 | Dark mode enabled + theme-aware components | Frontend | ✅ |
| 9 | Pull to refresh on dashboard | Frontend | ✅ |

**Delivered:** Splash → Dashboard (dev bypass), backend on port 6000, dark mode, all tabs working

---

## Sprint 2 (Week 2): Renewal CRUD ← CURRENT
**Goal:** User can add, view, edit, delete renewals. Dashboard shows live data.

| # | Task | F/B | Effort | Status |
|---|------|-----|--------|--------|
| 1 | Renewals API: create, list, get, update, delete (stubs exist, need real DB queries) | Backend | 3hr | |
| 2 | Add Renewal form screen (name, category, provider, amount, date, frequency, auto-renew) | Frontend | 4hr | |
| 3 | Smart category chips with auto-suggestions | Frontend | 2hr | |
| 4 | Renewal list on dashboard — sorted by days remaining, color-coded cards | Frontend | 4hr | |
| 5 | Renewal detail screen with countdown ring widget | Frontend | 3hr | |
| 6 | Edit renewal (reuse add form in edit mode) | Both | 2hr | |
| 7 | Delete renewal with confirmation | Both | 1hr | |
| 8 | Mark Renewed — advances date by one cycle | Both | 2hr | |
| 9 | Summary cards already wired to live data | Frontend | ✅ Done in Sprint 1 | |
| 10 | Urgency banner already built | Frontend | ✅ Done in Sprint 1 | |

**Deliverable:** Full renewal tracking working end-to-end. Dashboard feels real.

---

## Sprint 3 (Week 3): Document Vault
**Goal:** User can upload, scan, view, and manage documents linked to renewals

| # | Task | F/B | Effort |
|---|------|-----|--------|
| 1 | Document upload API (S3 + metadata in DB) | Backend | 3hr |
| 2 | Document list/get/delete API | Backend | 2hr |
| 3 | Camera scan + file picker upload UI | Frontend | 3hr |
| 4 | Link document to renewal item | Both | 2hr |
| 5 | Vault tab: all documents view with search | Frontend | 3hr |
| 6 | Vault tabs: By Item / All / Unlinked | Frontend | 2hr |
| 7 | Document viewer (PDF/image preview) | Frontend | 2hr |
| 8 | Duplicate detection (file hash) | Backend | 1hr |
| 9 | Renewal detail screen: documents section | Frontend | 2hr |

**Deliverable:** Full vault working. Documents linked to renewals. Search works.

---

## Sprint 4 (Week 4): Reminders + Notifications
**Goal:** User gets push notifications before renewals expire

| # | Task | F/B | Effort |
|---|------|-----|--------|
| 1 | FCM setup in Flutter (foreground + background handlers) | Frontend | 3hr |
| 2 | FCM token registration API | Backend | 1hr |
| 3 | Reminder creation: default rules (30/7/1 day) on renewal create | Backend | 2hr |
| 4 | BullMQ cron job: check renewals, send FCM push | Backend | 4hr |
| 5 | Notification settings screen (global defaults) | Frontend | 2hr |
| 6 | Per-item custom reminder schedule | Both | 2hr |
| 7 | Snooze from notification (deep link handling) | Both | 2hr |
| 8 | Daily digest notification | Backend | 2hr |
| 9 | Auto-cancel reminders on Mark Renewed | Backend | 1hr |

**Deliverable:** P0 complete. App is fully usable for basic renewal tracking.

---

## Sprint 5 (Week 5): Document OCR + AI Extraction
**Goal:** Scan a document → AI fills renewal fields automatically

| # | Task | F/B | Effort |
|---|------|-----|--------|
| 1 | Google Vision OCR integration (image → text) | Backend | 3hr |
| 2 | Claude API extraction (OCR text → structured JSON) | Backend | 4hr |
| 3 | POST /documents/:id/parse endpoint | Backend | 2hr |
| 4 | Upload flow: scan → show extracted fields with confidence indicators | Frontend | 4hr |
| 5 | Confirm/correct → auto-create renewal item | Frontend | 2hr |
| 6 | Auto-link suggestion | Both | 2hr |
| 7 | Sensitive data masking (Aadhaar last 4 digits) | Backend | 1hr |
| 8 | Full-text search on OCR content in vault | Backend | 1hr |

**Deliverable:** Scan any document → AI creates the renewal. Magical first-use experience.

---

## Sprint 6 (Week 6): Payment Tracking + AI Chat
**Goal:** Track payment history. Chat with Renewd about your renewals.

| # | Task | F/B | Effort |
|---|------|-----|--------|
| 1 | Payment log API (CRUD) | Backend | 2hr |
| 2 | Mark Renewed flow → payment logging prompt | Frontend | 3hr |
| 3 | Payment history timeline on renewal detail | Frontend | 2hr |
| 4 | Spending analytics API (by category, by month) | Backend | 2hr |
| 5 | Price change detection | Backend | 1hr |
| 6 | AI chat API: Claude with function calling | Backend | 4hr |
| 7 | Chat screen UI: message bubbles, structured response cards, input bar | Frontend | 4hr |
| 8 | Chat queries working end-to-end | Both | 2hr |

**Deliverable:** P1 complete. Payment tracking + basic AI chat working.

---

## Sprint 7-8 (Week 7-8): Offer Comparison + Polish
**Goal:** AI finds better deals. App is polished for launch.

| # | Task | F/B | Effort |
|---|------|-----|--------|
| 1 | Offer finder API: web scraping + LLM comparison | Backend | 6hr |
| 2 | Find Better Deals button → comparison cards | Frontend | 4hr |
| 3 | Proactive offer notifications (30 days before renewal) | Backend | 3hr |
| 4 | Profile screen: settings, notification prefs, data export | Frontend | 3hr |
| 5 | Onboarding flow (4 screens) | Frontend | 4hr |
| 6 | Pull-to-refresh, skeleton loading, empty states | Frontend | 3hr |
| 7 | FAB speed dial (Add Manually / Scan / Import) | Frontend | 2hr |
| 8 | Dark mode testing and fixes | Frontend | 2hr |
| 9 | App icon + splash screen branding | Frontend | 1hr |
| 10 | Web build testing + responsive layout fixes | Frontend | 2hr |

**Deliverable:** MVP complete. Ready for personal use + first demos.

---

## Summary

| Sprint | What | Outcome |
|--------|------|---------|
| 1 | Auth + Dashboard shell | ✅ App launches, login works |
| 2 | Renewal CRUD | Core tracking works end-to-end |
| 3 | Document Vault | Upload, scan, search documents |
| 4 | Reminders | Push notifications before expiry |
| 5 | OCR + AI Extraction | Scan → auto-create renewal |
| 6 | Payments + AI Chat | Track spending, chat with Renewd |
| 7-8 | Offers + Polish | Find better deals, launch-ready |
