# Renewd Production Readiness Checklist
**Date:** 2026-03-29

## Environment Variables (Railway)

| Var | Status | Action |
|-----|--------|--------|
| `CORS_ORIGIN` | Not set | Set to your Flutter app's domain (or `*` if mobile-only) |
| `ADMIN_SESSION_SECRET` | Not set | Generate a random 32+ char string, set in both API and admin services |
| `AWS_REGION` | `ap-south-1` (explicit in env) | Fine — your S3 bucket is there |
| `REVENUECAT_WEBHOOK_SECRET` | Check it's set | Webhook will reject all requests if empty now |

## Flutter App

| Item | Action |
|------|--------|
| `flutter pub get` | Run to pick up `flutter_secure_storage` |
| Production API URL | Verify `AppConstants.apiBaseUrl` points to your Railway URL when `PRODUCTION=true` |
| iOS keychain entitlement | `flutter_secure_storage` needs keychain access — test on a real device |
| RevenueCat product IDs | Confirm they match App Store Connect / Google Play |

## App Store / Google Play

| Item | Action |
|------|--------|
| Privacy policy URL | Already at `/website/privacy.html` — verify it's accessible |
| Terms of service URL | Already at `/website/terms.html` — verify it's accessible |
| GDPR addendum | Needed if targeting EU users (not blocking, but important) |
| App review notes | Mention the subscription features + test account credentials |

## Final Smoke Tests

- [ ] Sign up with phone, Google, and Apple
- [ ] Create a renewal (free user hits limit at 5)
- [ ] Upload a document and parse it
- [ ] Send a chat message (check rate limit works)
- [ ] Purchase premium via TestFlight/internal testing
- [ ] Check admin panel loads and AI Usage page shows data
- [ ] Verify push notifications arrive

## Not Blocking Launch (Do Soon After)

- H3: CSRF protection on admin — low risk since admin is password-protected
- GDPR compliance addendum for EU users
- i18n / multi-language support
- Offline mode on frontend
