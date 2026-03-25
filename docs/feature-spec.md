# Minder — Feature Specification v1.0

## Product Summary

AI-powered personal assistant that tracks renewals, subscriptions, and auto-payments, stores documents in a secure vault, and finds better deals. Mobile (Flutter) + Web.

---

## 1. Core Features

### 1.1 Renewal Tracker

- Add items manually (name, category, amount, renewal date, frequency, auto-renew toggle, provider) OR scan/upload a document and AI auto-fills everything
- Dashboard shows all items sorted by days remaining with color coding (green > 30 days, yellow 7-30, orange 3-7, red < 3)
- Tap item for full detail: countdown, amount, provider, linked documents, payment history
- "Mark Renewed" advances the date by one cycle, moves current doc to history
- Categories: Insurance, Subscription, Government, Utility, Membership, Other

**Edge cases:**
- Overdue items flagged red with persistent alert
- Irregular frequencies supported (passport = 10 years, custom day count)
- Same provider with multiple items — each separate, grouped under provider in list view
- Auto-renew items still tracked (user needs visibility on charges)

### 1.2 Document Vault

- Upload via camera scan or file picker (PDF/image)
- Each document tagged: item name, document type (policy/receipt/certificate/invoice/ID), issue date, expiry date
- One "current" document per item + unlimited history
- Standalone vault section for unlinked documents
- "Quick Scan" button — AI suggests which renewal item to link it to
- Full-text search across document names and OCR-extracted content
- Encrypted at rest (AES-256), stored in DigitalOcean Spaces
- Offline support: queued locally, syncs when online

**Edge cases:**
- Duplicate detection via file hash comparison
- Max file size: 10MB (with clear message)
- Offline uploads queued in local DB, synced on connectivity

### 1.3 Reminders & Notifications

- Global defaults: notify at 30 days, 7 days, 1 day before
- Per-item custom schedule (e.g., vehicle insurance: 60, 30, 15, 7, 1 day reminders)
- Each notification has action buttons: View Details, Mark Renewed, Snooze (1 day / 3 days / 1 week / custom)
- Daily digest option: one morning notification summarizing everything due in next 30 days
- Overdue items get persistent notifications
- Smart: if renewal falls on a Sunday/holiday, warns to renew earlier
- Auto-cancels reminders when item is marked renewed

**Edge cases:**
- 50+ items renewing same month — capped at 5 notifications/day, rest in digest
- Timezone changes handled via device timezone
- Notification permissions denied — in-app banner prompts

### 1.4 Payment Tracking

- When marking "renewed", prompted to log: amount, date, method (UPI/card/cash/net banking/auto-debit), reference number, receipt upload
- Payment history timeline on each item
- Annual spending summary by category with month-over-month trends
- Highlights price changes: "This is 15% more than last year"
- Supports partial payments, EMIs, and refunds

---

## 2. AI Features

### 2.1 Smart Offer Finder

- "Find Better Deals" button on supported items (insurance, subscriptions, utilities)
- Shows comparison card: current plan vs 2-3 alternatives with price, coverage, provider rating, savings badge
- Proactive mode: 30-45 days before renewal, AI automatically searches and notifies if a better deal exists (>10% savings or better coverage)
- Sources: aggregator APIs + web scraping + LLM analysis
- Results cached 7 days, filtered by user's region

### 2.2 Document Parser (OCR + AI Extraction)

- Upload/scan → AI extracts: provider name, policy number, dates, amounts, coverage details
- Shows extracted fields with confidence indicators (green = high, yellow = review)
- Auto-suggests linking: "This looks like a renewal of Vehicle Insurance - HDFC Ergo. Link it?"
- Pipeline: Image/PDF → OCR (Google Vision API) → LLM structured extraction (Claude API) → JSON output
- Handles: multi-page docs, Hindi/regional languages, sensitive data masking (Aadhaar last 4 digits only)

### 2.3 AI Personal Assistant Chat

- Natural language queries: "What's expiring this month?", "How much did I spend on insurance last year?"
- Responds with structured data (cards, tables, action buttons)
- LLM with function calling — queries renewals, searches offers, sets reminders, parses documents
- Handles ambiguity with clarifying questions

### 2.4 Smart Categorization & Auto-Detection

- Type "Netflix" → auto-suggests: Subscription, Monthly, ~Rs.649
- Gap analysis: "Most people also track: Domain renewals, Professional memberships"
- Optional Gmail integration: scans for renewal-related emails, suggests items to add

---

## 3. User Experience

### 3.1 Onboarding (4 screens max)

1. Welcome — Sign up with Google/Apple/Email
2. Quick Add — Tappable category chips, each expands to mini-form
3. Permissions — Notifications + Camera, both skippable with context
4. Dashboard — Land with items or empty state

### 3.2 Dashboard Layout

- Urgency banner (red/orange) if anything overdue or due within 3 days
- Summary cards: Due This Month, Total Active, Monthly Spend
- Renewal list sorted by days remaining
- Bottom nav: Dashboard | Vault | AI Chat | Profile
- FAB: Add Manually / Scan Document / Import from Email

### 3.3 Navigation

| Tab | Purpose |
|-----|---------|
| Dashboard | Renewal list with countdowns |
| Vault | All documents, searchable, filterable |
| AI Chat | Ask questions, get suggestions |
| Profile | Settings, notifications, data export |

---

## 4. Future Expansion

| Feature | Description |
|---------|-------------|
| Bill Payment | Pay renewals directly via Razorpay/UPI |
| Family Profiles | Track renewals for spouse, parents, kids |
| AI Auto-Renewal Agent | AI completes renewal on user's behalf (with approval) |
| WhatsApp Bot | Forward documents, get reminders via WhatsApp |
| Expense Tracker | Track non-renewal spending |
| Warranty Tracker | Track product warranties with receipts |
| Appointment Manager | Book and track appointments |
| Compliance Assistant | GST, ITR, TDS deadline tracking |
| B2B Plan | Multi-user, vendor contracts, AMC tracking |

---

## 5. Monetization

| Feature | Free | Premium (Rs.199/mo or Rs.1,499/yr) |
|---------|------|------|
| Renewal items | 10 | Unlimited |
| Document storage | 100MB | 5GB |
| AI chat | 50/month | Unlimited |
| Offer comparison | 3/month | Unlimited |
| Email import | No | Yes |
| Family profiles | 1 | 5 |
| Data export | No | Yes |

Plus affiliate commissions on insurance/subscription switches.

---

## 6. MVP Scope

| Priority | Features | Timeline |
|----------|----------|----------|
| P0 | Renewal CRUD, Document vault, Reminders, Dashboard | 3-4 weeks |
| P1 | Document OCR + auto-fill, Payment tracking, AI chat | +2 weeks |
| P2 | Offer comparison, Email import, Smart suggestions | +2 weeks |

Total MVP: ~7-8 weeks
