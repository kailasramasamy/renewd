# Handoff: Renewd Mobile App Redesign (Flutter)

## Overview

A full redesign of the **Renewd** mobile app — a tool for managing renewals (subscriptions, insurance, licenses, domains) with an AI layer that reads policy documents, extracts fields, and answers questions.

This handoff covers **10 screens** across two phases:

- **Entry flow (new):** Splash → Onboarding → Login → OTP Verify → Complete Profile
- **Main app (redesign):** Home, Renewals list (Categories), Vault, AI Chat, Renewal Detail

Target platform: **Flutter** (the existing Renewd codebase uses Material 3 with a custom dark theme in `app_theme.dart`).

---

## About the Design Files

The files in this bundle (`Renewd.html` + the `screen_*.jsx` partials + `styles.css`) are **design references created as an HTML prototype** — they show intended look, spacing, motion, and interaction. They are **not production code to paste into the app**.

Your job is to **recreate these designs in the existing Flutter codebase** using the project's established Dart widgets, theme, and patterns. Most of the tokens are already defined in the project — this handoff aligns the mocks to those tokens, so you do not need to invent new ones.

To explore the prototype:
```bash
# From the handoff folder, open Renewd.html in a browser.
# The floating Tweaks panel (bottom-right) lets you jump between any of the 10 screens
# and toggle theme (dark/light), AI accent color, and auth variant.
```

Each screen has `data-screen-label="..."` on its root element so you can identify them in devtools.

---

## Fidelity

**High-fidelity (hifi).** Pixel-perfect mockups — final colors, typography (**Public Sans**), spacing, radii, and micro-interactions. Match the visual spec closely. States (empty, loading, error, disabled) are covered below per screen.

---

## Existing code to reuse

The Flutter project already has most of the design system in place. **Use these files directly — do not duplicate.**

### Theme / tokens (keep as source of truth)
- `lib/theme/app_colors.dart` — `RenewdColors.oceanBlue`, `lavender`, `emerald`, `tangerine`, `coralRed`, `amber`, `charcoal`, `darkSlate`, `steel`, `warmWhite`, etc.
- `lib/theme/app_text_styles.dart` — `RenewdTextStyles.h1 / h2 / h3 / body / bodySmall / subtitle / caption / sectionLabel` (Public Sans, Material 3 text-theme)
- `lib/theme/app_radius.dart` — `RenewdRadius.sm(8) / md(12) / lg(14) / xl(16) / pill(20)`
- `lib/theme/app_spacing.dart` — `RenewdSpacing.xs(4) / sm(8) / md(12) / lg(16) / xl(24) / xxl(32) / xxxl(48)`
- `lib/theme/app_opacity.dart` — opacity constants
- `lib/theme/app_theme.dart` — Material 3 `ThemeData` for light & dark

### Widgets (reuse, do not reimplement)
- `lib/widgets/minder_card.dart` — base card (radius 14, border, no elevation)
- `lib/widgets/minder_button.dart` — primary/ghost/AI button variants
- `lib/widgets/renewd_badge.dart` — small labeled pill
- `lib/widgets/status_badge.dart` — due-state pills (Today / Soon / Warn / OK)
- `lib/widgets/brand_logo.dart` — per-renewal colored glyph tile (sm/md/lg)
- `lib/widgets/renewd_empty_state.dart` — shared empty-state layout
- `lib/widgets/renewd_form_label.dart` — uppercase form label
- `lib/widgets/skeleton_loader.dart` + `loading_shimmer.dart` — shimmer placeholders
- `lib/widgets/irrelevant_doc_sheet.dart` — bottom sheet used in Vault

If a new screen needs something these don't cover, add a widget — don't inline styles.

---

## Design Tokens (maps to existing Dart tokens)

### Colors

| Token (Dart) | Hex | Use |
|---|---|---|
| `RenewdColors.charcoal` | `#111111` | Dark bg |
| `RenewdColors.darkSlate` | `#1C1C1E` | Dark surface (cards) |
| `RenewdColors.steel` | `#2C2C2E` | Dark surface-2 (nested) |
| `RenewdColors.darkBorder` | `#38383A` | 1px border, dark |
| `RenewdColors.warmWhite` | `#F2F2F7` | Dark primary text |
| `RenewdColors.silver` | `#C7C7CC` | Dark secondary text |
| `RenewdColors.warmGray` | `#8E8E93` | Dark tertiary text |
| `RenewdColors.softWhite` | `#F2F4F7` | Light bg |
| `RenewdColors.cloudGray` | `#E8ECF0` | Light surface-2 |
| `RenewdColors.mist` | `#E5E5EA` | Light border |
| `RenewdColors.deepNavy` | `#111111` | Light primary text |
| `RenewdColors.slate` | `#8E8E93` | Light tertiary text |
| `RenewdColors.oceanBlue` | `#3B82F6` | **Primary** (CTAs, links, active tab, progress, brand) |
| `RenewdColors.lavender` | `#BF5AF2` | **AI accent only** (Sparkle, Ask button, AI insight cards, send button in chat) |
| `RenewdColors.emerald` | `#34C759` | Success / encrypted / on-toggle |
| `RenewdColors.amber` | `#FFCC00` | Warning (due within 30d) |
| `RenewdColors.tangerine` | `#FF9F0A` | Due within 7d |
| `RenewdColors.coralRed` | `#FF453A` | Due today / error |

**Critical rule:** The redesign uses **flat color** — no gradients on CTAs or tiles. `Lavender` is **only** for AI moments (Sparkle icon, AI chat send button, AI insight card borders/accents, "Renewd AI" labels). `OceanBlue` is the primary action color everywhere else.

### Typography — Public Sans

Use `RenewdTextStyles.*`. Map HTML classes to Dart styles:

| HTML class | Dart style | px | weight | letter-spacing |
|---|---|---|---|---|
| `.t-h1` | `RenewdTextStyles.h1` | 32 | 700 | -0.5 |
| `.t-h2` | `RenewdTextStyles.h2` | 26 | 700 | -0.3 |
| `.t-h3` | `RenewdTextStyles.h3` | 20 | 700 | -0.2 |
| `.t-body` | `RenewdTextStyles.body` | 16 | 500 | 0 |
| `.t-body-sm` | `RenewdTextStyles.bodySmall` | 14 | 500 | 0.1 |
| `.t-subtitle` | `RenewdTextStyles.subtitle` | 14 | 600 | 0.1 |
| `.t-caption` | `RenewdTextStyles.caption` | 12 | 500 | 0.3 |
| `.t-section` / `.sec-label` / `.form-label` | `RenewdTextStyles.sectionLabel` | 11 | 600 | 1.2 (UPPERCASE) |

Numerals use `fontFeatures: [FontFeature.tabularFigures()]` wherever they appear in prices or dates.

### Radius (use `RenewdRadius.*`)
`sm = 8`, `md = 12`, `lg = 14` (card default), `xl = 16`, `pill = 20`.

### Spacing (use `RenewdSpacing.*`)
`xs = 4`, `sm = 8`, `md = 12`, `lg = 16`, `xl = 24`, `xxl = 32`, `xxxl = 48`.

---

## Screens

The 10 screens below correspond to `data-screen-label` values in the prototype.

### 1. Splash — `screen_entry.jsx` → `SplashScreen`

**Purpose:** First paint while auth session loads.
**Layout:** Centered `BrandMark` (84×84, OceanBlue, refresh-icon glyph, gentle float animation) → wordmark "Renewd" (h1, 34pt) → tagline "Never miss a renewal." (body, text-3). Bottom: 120px progress bar (3px tall, OceanBlue fill on steel) + uppercase caption "SYNCING YOUR VAULT".
**Behavior:** Auto-advances to the next screen once session bootstrapped (~1.2s min).

### 2. Onboarding — `OnboardingScreen`

**Purpose:** 3-slide value pitch for first-time users.
**Layout:** Top-right `Skip` link → illustration area (280px tall) → progress dots (active slide is 3× wider in OceanBlue) → title (h2) + body (15.5px text-3) → bottom full-width `Continue` / `Get started` CTA with chevron.
**Slides:**
1. **"Every renewal, in one place."** — stacked renewal cards art (3 cards: Claude Max, Netflix, iCloud+, each with logo tile, due pill, price).
2. **"We read the fine print."** — document card + AI chip art (rotated PDF mockup with animated scan line + floating AI insight bubble in lavender).
3. **"Reminders that actually land."** — pulsing bell glyph (OceanBlue) + notification card preview.
**Behavior:** `Skip` jumps straight to Login. `Continue` advances; on final slide, CTA becomes "Get started" → Login.

### 3. Login — `LoginScreen` (variants: `phone` default, `email`)

**Purpose:** Auth entry.
**Layout:** BrandMark (52px) → h2 "Welcome back." → body subtitle → phone field (country picker 🇮🇳 `+91` · divider · number input, 50px tall, `RenewdColors.steel` bg, focus ring OceanBlue) OR email field → primary Continue CTA (50px) → `OR CONTINUE WITH` divider → ghost buttons: **Continue with Google** (full-color G glyph) / **Continue with Apple** (monochrome Apple glyph, follows theme) → footer legal copy with underlined Terms / Privacy links.
**Behavior:** Continue disabled until 10+ digits / valid email. Social buttons are stubbed (wire to real OAuth).

### 4. OTP Verify — `OtpScreen`

**Purpose:** 6-digit code confirmation.
**Layout:** Top-left back `icon-btn` → h2 "Enter the 6-digit code" → subtitle with masked phone + "Change number" link (OceanBlue) → row of 6 input boxes (48×56, radius md, OceanBlue border when filled/focused, coralRed border + tinted bg when error) → timer `Resend code in 42s` (tabular numerals) → when timer = 0, tappable "Resend code" with refresh icon, OceanBlue → large Verify CTA → help footer.
**Behavior:**
- Auto-advance focus on digit entry
- Backspace on empty box moves focus back
- Paste fills all boxes
- On 6th digit, auto-verifies after 250ms
- Error state for code `121212` / `000000` (demo trigger) — shows coralRed banner "That code didn't match. Try again."
- Timer ticks every 1s, resets to 42 on Resend

### 5. Complete Profile — `CompleteProfileScreen`

**Purpose:** Collect name, country/currency, notification consent.
**Layout:** 3-segment step indicator (2/3 filled OceanBlue) → h2 "Let's set up your vault." → subtitle → centered 96px avatar circle (dashed border, shows initial in OceanBlue once name typed, badge with OceanBlue upload icon overlay bottom-right) → Name field → Country & currency picker (flag + name + currency, tap to expand inline list with check marks) → Reminders toggle card (bell icon in primary-soft tile, iOS-style toggle — emerald when on) → emerald privacy reassurance banner ("End-to-end encrypted.") → sticky bottom CTA "Enter Renewd" with chevron.
**Behavior:** Country picker expands/collapses in place. Enter Renewd disabled until name ≥ 2 chars. On tap → Home.

### 6. Home — `screen_home.jsx` → `HomeScreen`

**Purpose:** Daily dashboard.
**Layout:**
- Header: "Good morning" greeting (h3), name subtitle (text-3) — bell icon-btn with coralRed dot for unread — profile avatar tile (R monogram, OceanBlue).
- **AI Brief card** (top, subtle lavender radial-wash background): Sparkle glyph + "YOUR BRIEF" uppercase label (lavender) + brief copy + Ask follow-up AI button (lavender, small).
- **This month total**: h1 "₹17,124" (tabular) + tangerine trend pill "+22% vs avg".
- **Category bar chart**: horizontal bars for AI/Software, Insurance, Membership, Entertainment — each colored per category (lavender, OceanBlue, emerald, amber), with amount label.
- **Due next** section (label `UP NEXT · count`): 3 renewal rows.
- Tab bar: Home / Renewals / Vault / Chat. Active tab OceanBlue.

### 7. Renewals — `screen_categories.jsx` → `CategoriesScreen`

**Purpose:** Full filterable list.
**Layout:**
- Header: h2 "Renewals" + search `icon-btn`.
- Search field (44px, steel bg, focus ring OceanBlue).
- Horizontal `chip-row`: All / Due this week / Due this month / … — active chip OceanBlue bg white text, count badge opacity 0.75.
- Section labels with counts.
- Renewal rows: 3px left urgency strip (coralRed today / tangerine ≤7d / amber ≤30d / category color otherwise) → logo tile → name + sub → right-aligned amount (tabular) + due pill.

### 8. Vault — `screen_vault.jsx` → `VaultScreen`

**Purpose:** Document storage with AI extraction.
**Layout:**
- Header: h2 "Vault".
- Encryption banner (emerald-soft bg, lock icon + "AES-256 · end-to-end encrypted").
- Search field with AI sparkle glyph (lavender) suffix.
- Chip row: filters + "AI-analyzed" chip with lavender sparkle.
- Document rows (`.doc-row`): icon tile tinted to linked renewal's category color → filename + meta (type · size · date) → chevron.
- Floating lavender FAB bottom-right (52×52, radius 17) with `+` — opens upload sheet.

### 9. AI Chat — `screen_chat.jsx` → `ChatScreen`

**Purpose:** Conversational Q&A grounded in the user's vault.
**Empty state:**
- 84×84 lavender-soft tile with Sparkle glyph + lavender glow shadow.
- "Ask about anything in your vault." (h3, balanced text-wrap).
- Snapshot card (lavender-soft wash): "THIS WEEK" label + stat chips (e.g., "12 renewals", "₹17,124", "3 due").
- Suggested prompts (`.sugg` cards): 3-4 rows, each with question + hint.
**Conversation:**
- User bubbles: right-aligned, OceanBlue bg, white text, bottom-right corner 6px.
- AI bubbles: left-aligned, surface bg, border, bottom-left corner 6px.
- Floating composer at bottom (above tab bar): blurred surface, input + lavender send button (40×40, radius md, AI glow shadow; disabled state grayed).

### 10. Renewal Detail — `screen_detail.jsx` → `DetailScreen`

**Purpose:** Full info for one renewal.
**Layout:**
- Radial background wash tinted to renewal's category color.
- Back icon-btn top-left, more icon top-right.
- Large logo tile (76×76, radius 20, tinted bg+border).
- Name (h2), vendor (text-3).
- Countdown: large tabular number "in **6** days" with date + OceanBlue progress bar (filled proportional to cycle).
- **AI Insight card** (lavender-soft wash, Sparkle): "RENEWD AI" label + insight copy (e.g., "Premium rose 8% YoY…").
- Key-value rows (`.kv-row`): Policy #, Premium, Valid till, IDV, Auto-renew (toggle).
- Documents section: linked doc rows.
- Sticky bottom bar: ghost "Remind me" + primary "Renew now" (OceanBlue, full-width-split).

---

## Interactions & Behavior

- **Theme:** Support light and dark via `data-theme` attribute on root (prototype) → Material 3 `ThemeMode` in Flutter. Default dark.
- **Auto-verify OTP:** fires 250ms after 6th digit.
- **Focus/error transitions:** 150ms ease on border-color/background for all inputs.
- **Progress dots in onboarding:** flex-grow animation, 300ms ease.
- **Skeleton shimmer:** 1.4s linear loop, horizontal gradient sweep — use `skeleton_loader.dart`.
- **Button press:** `transform: scale(0.98)` ≈ `AnimatedScale(0.98)` in Flutter, 100ms.
- **Tab change:** no transition on body; tab indicator color swap only.
- **FAB in Vault:** opens a modal bottom sheet for upload (camera / gallery / files / PDF scan).
- **Chat composer send:** disabled until non-empty, lavender with glow shadow when enabled.

---

## State Management

Use the project's existing state solution (Riverpod / Provider / Bloc — whichever is already in place). Minimum state needed:

**Auth flow:**
- `phoneNumber`, `countryCode`, `email` (login)
- `otpCode` (6 chars), `otpSecondsRemaining`, `otpError`
- `profileName`, `country`, `notificationsEnabled`
- `authStage` enum: splash → onboarding → login → otp → completeProfile → home

**Main app:**
- `List<Renewal>` (see `data.jsx` `RENEWALS` for shape + seed data)
- `List<Document>` with `linkedRenewalId`
- `List<ChatMessage>` with `role: user|ai`
- Active tab index
- Selected renewal (for Detail screen)

**Data shapes** are in `data.jsx`. Use them as seeds for your models.

---

## Assets

- **Fonts:** Public Sans 400/500/600/700/800 — already configured in `pubspec.yaml` / `app_text_styles.dart`. If not, import from Google Fonts.
- **Icons:** The prototype defines its own SVG icon set in `shared.jsx` (`Icon` component: `bell`, `search`, `chevron`, `back`, `plus`, `close`, `refresh`, `globe`, `lock`, `shield`, `check`, `upload`, `trend`, `sparkle`). In Flutter, use `Icons` from `material_symbols_icons` or the existing icon pack — match the outlined style, stroke weight ~2.
- **Google & Apple glyphs:** `GoogleGlyph` and `AppleGlyph` in `screen_entry.jsx`. In Flutter, use `font_awesome_flutter` (`FontAwesomeIcons.google` with Material colors and `FontAwesomeIcons.apple` in current text color), or embed SVGs.
- **Brand logos** for seeded renewals (Claude, Netflix, iCloud, TATA AIG, etc.) are rendered as **colored monogram tiles**, not real logos — use `brand_logo.dart` which does exactly this.

---

## Files in this bundle

| File | Purpose |
|---|---|
| `Renewd.html` | Main prototype — opens a 402×874 device bezel with Tweaks panel. |
| `styles.css` | All tokens + base styles (mirrors the Dart theme). |
| `shared.jsx` | `StatusBar`, `Sparkle`, `Icon` used across screens. |
| `data.jsx` | Seed data for renewals, docs, chat messages. |
| `screen_entry.jsx` | Splash, Onboarding, Login, OTP, Complete Profile. |
| `screen_home.jsx` | Home dashboard. |
| `screen_categories.jsx` | Renewals list. |
| `screen_vault.jsx` | Document vault. |
| `screen_chat.jsx` | AI Chat (empty + conversation states). |
| `screen_detail.jsx` | Renewal detail. |

---

## Suggested implementation order

1. **Confirm tokens** in `app_colors.dart` / `app_text_styles.dart` match this spec (Public Sans, OceanBlue primary, Lavender AI-only). Patch any drift.
2. **Entry flow** (Splash → Onboarding → Login → OTP → Complete Profile) — most are new screens; wire them in sequence with the chosen auth provider.
3. **Retone Home, Renewals, Vault, Chat, Detail** — replace any old gradient/iris accents with OceanBlue primary and Lavender (AI only). Keep layouts but update colors/typography.
4. **Light theme pass** — the prototype works in light; ensure every screen renders correctly under `ThemeMode.light`.
5. **Empty + loading + error states** — each screen has them in the prototype; recreate using `renewd_empty_state.dart` / `skeleton_loader.dart`.

Ping if any mapping is ambiguous — the HTML is authoritative for visuals, the Dart widgets are authoritative for structure.
