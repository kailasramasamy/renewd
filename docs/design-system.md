# Minder — Design System

## Brand Identity

Minder is a premium consumer app. The design should feel trustworthy, calm, and effortless — like having a personal secretary who has everything under control.

**Design principles:**
- Clean over clever
- Information density without clutter
- Gentle urgency (guide, don't alarm)
- Premium feel with every micro-interaction

---

## Typography

### Primary Font: Inter

- Modern, highly legible, designed for screens
- Excellent readability at all sizes
- Professional without being corporate
- Free, open source, widely supported

### Font Scale

| Use | Weight | Size | Letter Spacing |
|-----|--------|------|----------------|
| H1 — Screen titles | Bold (700) | 28px | -0.5px |
| H2 — Section headers | SemiBold (600) | 22px | -0.3px |
| H3 — Card titles | SemiBold (600) | 18px | -0.2px |
| Body — Primary text | Regular (400) | 16px | 0px |
| Body Small — Secondary | Regular (400) | 14px | 0.1px |
| Caption — Labels, tags | Medium (500) | 12px | 0.3px |
| Overline — Category labels | SemiBold (600) | 11px | 0.8px (uppercase) |
| Numbers — Countdown, amounts | Bold (700) | 32-48px | -1px |

### Secondary Font: DM Sans (for accent/branding)

- Used only in: logo, onboarding headlines, marketing screens
- Geometric, friendly, premium feel
- Pairs beautifully with Inter

---

## Color Palette

### Core Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Deep Navy** | `#1B2838` | Primary text, headers, app bar |
| **Ocean Blue** | `#2563EB` | Primary action buttons, links, active states |
| **Soft White** | `#F8FAFC` | Background (light mode) |
| **Cloud Gray** | `#F1F5F9` | Card backgrounds, input fields |
| **Slate** | `#64748B` | Secondary text, placeholders |
| **Mist** | `#E2E8F0` | Borders, dividers |

### Status Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Emerald** | `#10B981` | Safe (>30 days), completed, success |
| **Amber** | `#F59E0B` | Warning (7-30 days), in progress |
| **Tangerine** | `#F97316` | Urgent (3-7 days), attention needed |
| **Coral Red** | `#EF4444` | Critical (<3 days), overdue, errors |

### Accent Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Lavender** | `#8B5CF6` | AI features, chat, smart suggestions |
| **Teal** | `#14B8A6` | Savings, deals, positive deltas |
| **Rose** | `#F43F5E` | Premium badge, upgrade prompts |

### Dark Mode

| Name | Hex | Usage |
|------|-----|-------|
| **Charcoal** | `#0F172A` | Background |
| **Dark Slate** | `#1E293B` | Card backgrounds |
| **Steel** | `#334155` | Borders, dividers |
| **Silver** | `#CBD5E1` | Primary text |
| **Dim White** | `#F1F5F9` | Headers, emphasis |

---

## Category Colors & Icons

| Category | Color | Icon |
|----------|-------|------|
| Insurance | `#2563EB` (Ocean Blue) | Shield |
| Subscription | `#8B5CF6` (Lavender) | Refresh/Loop |
| Government | `#F59E0B` (Amber) | Building/ID |
| Utility | `#14B8A6` (Teal) | Zap/Lightning |
| Membership | `#F97316` (Tangerine) | Users/Card |
| Other | `#64748B` (Slate) | Folder |

---

## Component Specs

### Cards

- Border radius: 16px
- Padding: 16px
- Shadow (light mode): `0 1px 3px rgba(0,0,0,0.05), 0 1px 2px rgba(0,0,0,0.03)`
- Shadow (dark mode): none, use `Dark Slate` background with 1px `Steel` border
- Spacing between cards: 12px

### Buttons

**Primary:**
- Background: Ocean Blue (`#2563EB`)
- Text: White, SemiBold 16px
- Border radius: 12px
- Height: 52px
- Pressed state: darken 10%
- Disabled: 40% opacity

**Secondary:**
- Background: Cloud Gray (`#F1F5F9`)
- Text: Deep Navy, Medium 16px
- Border radius: 12px
- Height: 48px

**Danger:**
- Background: Coral Red (`#EF4444`)
- Text: White

### Status Badges

- Border radius: 20px (pill shape)
- Padding: 4px 12px
- Font: Caption (12px, Medium)
- Background: status color at 15% opacity
- Text: status color at full opacity

### Countdown Widget (Item Detail)

- Circular progress ring: 120px diameter
- Ring thickness: 8px
- Ring color: status color (green → yellow → orange → red)
- Center: days remaining in Bold 48px
- Below ring: "days remaining" in Caption

### Bottom Navigation

- Height: 64px + safe area
- Background: White (light) / Charcoal (dark)
- Active icon: Ocean Blue
- Inactive icon: Slate
- Active label: Ocean Blue, Caption size
- No border, subtle top shadow

### FAB (Floating Action Button)

- Size: 56px
- Background: Ocean Blue
- Icon: Plus, White
- Shadow: `0 4px 12px rgba(37,99,235,0.3)`
- Position: bottom-right, 16px from edges
- Expands to speed dial with 3 options

### Input Fields

- Border radius: 12px
- Background: Cloud Gray
- Border: 1px Mist (default), Ocean Blue (focused)
- Height: 52px
- Label: Caption size, Slate color, above field
- Placeholder: Slate at 60% opacity

---

## Spacing System

Base unit: 4px

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing, icon gaps |
| sm | 8px | Between related elements |
| md | 12px | Between cards, list items |
| lg | 16px | Section padding, card padding |
| xl | 24px | Between sections |
| 2xl | 32px | Screen padding top/bottom |
| 3xl | 48px | Major section gaps |

---

## Iconography

- **Icon set:** Lucide Icons (clean, consistent, open source)
- **Style:** Outlined, 1.5px stroke weight
- **Sizes:** 20px (inline), 24px (navigation/actions), 32px (feature icons)
- **Color:** Inherits from context (Slate for default, Ocean Blue for active)

---

## Animations & Micro-interactions

- **Page transitions:** Shared axis (horizontal for peer navigation, vertical for drill-down)
- **Card press:** Scale down to 0.98, 100ms ease-out
- **Button press:** Scale down to 0.96, 80ms
- **Status color changes:** Animate over 300ms (smooth countdown color transitions)
- **FAB expand:** Staggered reveal, 150ms per option
- **Pull to refresh:** Custom animation with Minder logo
- **Skeleton loading:** Shimmer effect on Cloud Gray
- **Toast/Snackbar:** Slide up from bottom, auto-dismiss 3s

---

## Illustration Style

- **Onboarding:** Minimal flat illustrations with brand colors (Ocean Blue + Lavender)
- **Empty states:** Simple line illustrations with one accent color
- **No stock photos** — illustrations only for consistency
- **Character style:** Abstract/geometric people (not cartoon, not realistic)

---

## Flutter Implementation Notes

```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.0.0  # For Inter and DM Sans
  lucide_icons: ^0.0.1  # Or use hugeicons/iconsax for more options

# Theme setup
fonts:
  - family: Inter
  - family: DMSans
```

### Color Constants (Dart)

```dart
class MinderColors {
  // Core
  static const deepNavy = Color(0xFF1B2838);
  static const oceanBlue = Color(0xFF2563EB);
  static const softWhite = Color(0xFFF8FAFC);
  static const cloudGray = Color(0xFFF1F5F9);
  static const slate = Color(0xFF64748B);
  static const mist = Color(0xFFE2E8F0);

  // Status
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const tangerine = Color(0xFFF97316);
  static const coralRed = Color(0xFFEF4444);

  // Accent
  static const lavender = Color(0xFF8B5CF6);
  static const teal = Color(0xFF14B8A6);
  static const rose = Color(0xFFF43F5E);

  // Dark mode
  static const charcoal = Color(0xFF0F172A);
  static const darkSlate = Color(0xFF1E293B);
  static const steel = Color(0xFF334155);
  static const silver = Color(0xFFCBD5E1);
}
```
