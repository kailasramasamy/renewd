# Renewd v2 Roadmap

## Auto-Detection Features

### 1. SMS Auto-Detection (Android)
**Priority:** High | **Platform:** Android only | **Effort:** 2 weeks

- Request SMS read permission (one-time)
- Background service parses incoming transaction SMS
- Detect recurring patterns: same merchant + similar amount + regular interval
- Auto-create renewal suggestions (user approves before adding)
- Covers UPI, bank debits, credit card charges
- Example: "₹199 debited to Netflix via UPI" → suggests Netflix ₹199/monthly

**Key SMS patterns to parse:**
- Bank debit alerts (HDFC, SBI, ICICI, Axis, Kotak, etc.)
- UPI transaction confirmations
- Credit card transaction alerts
- Auto-debit mandate notifications

### 2. Email Receipt Scanning (iOS + Android)
**Priority:** High | **Platform:** Both | **Effort:** 3 weeks

- Gmail OAuth one-tap connect
- Scan last 12 months for subscription receipts
- Search: `subject:(receipt OR invoice OR subscription OR payment confirmation)`
- AI extracts: provider, amount, frequency, next billing date
- Show found subscriptions → user confirms which to track
- Periodic re-scan for new receipts (weekly)

**High-value senders to prioritize:**
- Google (noreply@google.com)
- Apple (no-reply@email.apple.com)
- Netflix, Spotify, Amazon, Adobe
- Indian banks and insurance companies
- Utility providers

---

## Future Considerations (v3+)

### Account Aggregator (India)
- RBI-regulated open banking via Setu/OneMoney/Finvu
- User consents → get transaction history from all banks
- Requires FIU registration
- Most comprehensive but highest regulatory effort

### Notification Listener (Android)
- Read payment notifications from Google Pay, PhonePe, Paytm
- Richer data than SMS — merchant name, amount, UPI ID
- Passive background detection

### StoreKit Integration (iOS)
- Detect App Store subscriptions via StoreKit API
- Limited to subscriptions purchased through Apple
- Low effort but limited coverage in India

### Bank Statement Upload Enhancement
- Already supported via PDF scan
- Add specific bank statement parsers for structured extraction
- Support CSV/Excel bank exports
