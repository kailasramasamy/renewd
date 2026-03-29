# Renewd Security & Architecture Audit Tracker
**Audit Date:** 2026-03-29

## Critical Issues

| # | Status | Area | Issue | Location | Fix |
|---|--------|------|-------|----------|-----|
| C1 | [x] | Auth | Dev bypass in non-prod allows unauthenticated access | `backend/src/middleware/auth.ts:20-28` | Require explicit test token |
| C2 | [x] | Admin | API routes have no auth check (middleware only protects pages) | All 10 admin API routes | Add auth helper to every route |
| C3 | [x] | Race | Renewal limit check not atomic (TOCTOU bypass) | `backend/src/routes/renewals/index.ts:46-54` | Atomic INSERT with subquery |
| C4 | [x] | Race | Premium status check + auto-expire not atomic | `backend/src/middleware/premium.ts:15-38` | Single UPDATE...RETURNING |
| C5 | [x] | Frontend | Auth tokens stored unencrypted (GetStorage) | `frontend/lib/core/services/storage_service.dart:15` | Use flutter_secure_storage |
| C6 | [x] | Frontend | No token refresh — expired Firebase token = dead app | API client layer | Add 401 interceptor + refresh |

## High Severity

| # | Status | Area | Issue | Location | Fix |
|---|--------|------|-------|----------|-----|
| H1 | [x] | Auth | Missing return after 401 reply — request continues | `backend/src/middleware/auth.ts:49` | Add return statements |
| H2 | [x] | Admin | Dynamic SQL field names from client (column injection) | `admin/src/app/api/banners/[id]/route.ts:11-31` | Whitelist allowed fields |
| H3 | [ ] | Admin | No CSRF protection on state-changing endpoints | All admin POST/PUT/DELETE | Add CSRF tokens |
| H4 | [x] | Admin | File upload: no type/size validation, trusts client MIME | `admin/src/app/api/banners/upload/route.ts` | Whitelist + magic bytes |
| H5 | [x] | DB | Missing indexes on firebase_uid, user_id, renewal_id | Multiple tables | New migration |
| H6 | [x] | DB | Unbounded queries (no LIMIT) on documents and renewals | `documents/index.ts:99`, `renewals/index.ts:13` | Add LIMIT + pagination |
| H7 | [x] | DB | Sequential deletes not in transaction — orphans on error | `renewals/index.ts:104-110`, `users/index.ts:75-84` | Wrap in BEGIN/COMMIT |
| H8 | [x] | Webhook | RevenueCat secret skipped if empty; timing attack risk | `webhooks/revenuecat.ts:16-22` | Require secret + timingSafeEqual |
| H9 | [x] | Frontend | NotificationService stream subscriptions never cancelled | `notification_service.dart:92-109` | Store + cancel in onClose |
| H10 | [x] | Frontend | No retry logic — any network blip = instant failure | `api_client.dart` | Add exponential backoff |
| H11 | [x] | Resilience | Redis down = 500 on rate limit (no fallback) | `middleware/rate-limit.ts` | Graceful degradation |

## Medium Severity

| # | Status | Area | Issue |
|---|--------|------|-------|
| M1 | [x] | Security | No file type validation on document upload |
| M2 | [x] | Security | No input validation on most text fields |
| M3 | [x] | Security | CORS is origin:true in non-prod |
| M4 | [x] | Security | Admin session is plain "authenticated" cookie — no JWT |
| M5 | [x] | Security | No rate limiting on admin login |
| M6 | [x] | Perf | app_config queried on every request — needs Redis cache |
| M7 | [x] | Perf | Separate DB pool for BullMQ jobs |
| M8 | [x] | Perf | filteredRenewals getter recalculates on every rebuild |
| M9 | [~] | Arch | No data access layer — routes query DB directly (partial: shared getUserId helper added) |
| M10 | [x] | Arch | Duplicate getUserId logic across routes |
| M11 | [x] | Arch | BullMQ singletons break horizontal scaling |
| M12 | [x] | Frontend | 20+ catch (_) {} silently swallowing errors |
| M13 | [x] | Frontend | TextEditingController leaks in build() |
| M14 | [x] | Frontend | Deep links from push not validated |
