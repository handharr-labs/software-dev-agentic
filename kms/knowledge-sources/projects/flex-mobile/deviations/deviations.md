---
scope: project/flex-mobile
platform: flutter
discipline: engineering
artifact: deviations
---
# Deviations

Platform: Flutter (Melos monorepo)
Last scanned: 2026-06-04

This document records architectural patterns, deliberate choices, and structural quirks that differ from the canonical Clean Architecture + BLoC + get_it/injectable baseline described in `CLAUDE.md`.

---

## Manual get_it DI (no injectable)

**Expected:** `injectable` + `@injectable`/`@lazySingleton` annotations and generated `configureDependencies()`.

**Actual:** All registrations are hand-written across `service_locator.dart`, `data_locator.dart`, `domain_locator.dart`, `database_locator.dart`, and `bloc_factory.dart`. No code generation for DI.

**Impact:** Adding a new repository or use case requires manually editing 2–3 locator files. Forgotten registrations cause runtime `StateError` (not compile-time errors).

---

## Four Separate Network Clients (Multi-Base-URL)

**Expected:** A single `FlexNetworkClient` with a configurable base URL.

**Actual:** Four distinct client classes, each hardwired to a different base URL:
1. `FlexNetworkClient` → `BASE_URL` (credit API)
2. `BenefitNetworkClient` → `BENEFIT_CMS_URL` (CMS / campaigns)
3. `LendingNetworkClient` → `LENDING_URL` (installment/lending)
4. `SavingsNetworkClient` → `SAVING_URL` (Mekari Saving)

**Impact:** Data sources must declare dependency on the right client type. Passing the wrong client silently routes to the wrong base URL.

---

## Cashout Module Uses Brick-Way (Micro-Frontend)

**Expected:** Feature module follows the same `lib/features/<name>/data|domain|presentation` structure as all other features.

**Actual:** `modules/cashout` is a Brick-Way (`brick_way` git package) micro-frontend. It registers itself via `BrickModule`, `BrickRouter`, and `BrickApp`. Has its own DI locator, its own environment, its own localisation files.

**Impact:** Cashout routing and DI bootstrap differ from all other features. Cashout cannot be accessed directly via the standard router; it must be launched via `BrickApp`.

---

## Dual Payment Path (Credit vs Flex Balance)

**Expected:** A single payment data source with a balance-source parameter.

**Actual:** Two separate `PaymentDataSource` subclasses exist side by side:
- `CreditPaymentDataSource` — all paths prefixed `credit/transactions/`
- `FlexPaymentDataSource` — all paths prefixed `flex/transactions/`

Both implement the same `PaymentRemoteDataSource` interface. The correct one is chosen at the use-case/repository level based on the user's selected payment method.

**Impact:** Any new PPOB payment type must be added to both classes. Path constants are duplicated.

---

## Installment Paths Have Leading Slash

**Expected:** Path strings relative to base URL, no leading slash (consistent with every other data source).

**Actual:** `UpgradeFacilityRemoteDataSourceImpl` uses `static const upgradeLimitPath = '/lending/users/update_limit_upgrade_status'` with a leading `/`. All other data sources omit the leading slash.

**Impact:** Depending on Dio configuration, the leading slash may or may not strip the base URL path. This is an inconsistency that could cause routing issues if the base URL has a path component.

---

## Inbox Uses MoEngage SDK (No REST Endpoint)

**Expected:** In-app inbox backed by a REST API like other features.

**Actual:** `InboxRepositoryImpl` depends solely on `InboxLocalDataSource` (a wrapper around `MoEngageInbox`). No remote data source. Messages are delivered and stored by the MoEngage SDK.

**Impact:** Inbox data is not accessible without an active MoEngage session. No offline-first strategy.

---

## Feedback Written Directly to Firebase Realtime Database

**Expected:** Feedback posted to the app's REST API.

**Actual:** `FeedbackRemoteSourceImpl` takes `FirebaseDatabase` directly and writes to `user_feedback/csat|nps/{companyId}/{userId}` nodes. No REST intermediary.

**Impact:** Feedback data lives in Firebase RTDB, not the main application database. Requires Firebase RTDB rules to be permissive for authenticated writes.

---

## KTP Upload via Presigned S3 URL (Three-Step Flow)

**Expected:** Direct multipart POST to app API.

**Actual:** Three-step process:
1. POST `ckyc/ktps` → receive `presigned_url`
2. PUT file directly to presigned URL (fresh `FlexNetworkClient` instance with `baseUrl: ''`)
3. PATCH `ckyc/ktps` → finalise

For payslips, a single multipart POST to `ckyc/kyc/upload_payslip` is used instead.

**Impact:** KTP and payslip upload paths are inconsistent. The presigned-URL client bypasses all auth interceptors.

---

## ObjectBox as Optional Hive Replacement (Feature-Flagged)

**Expected:** A single local database strategy.

**Actual:** Both `hive` and `objectbox` are bundled in the app. ObjectBox is activated at runtime via `flag_use_objectbox` Firebase Remote Config flag. When disabled, Hive is used. ObjectBox store is lazy-initialised via `ObjectBoxDatabaseProvider`.

**Impact:** Two parallel local storage paths exist. New entities must be registered in both systems or rely on the flag for routing.

---

## Saving Module Has Its Own Auth Token Lifecycle

**Expected:** A single SSO-derived auth token shared across all features.

**Actual:** The `saving` module maintains a separate `SavingsTokenResponse` lifecycle. It calls `auth/access-token` on the Savings API, stores its own token, and refreshes it independently via `auth/refresh-token`. Linkage between Mekari Flex and Mekari Saving is established via `auth/check-linkage-status`.

**Impact:** Savings authentication is entirely decoupled. Session expiry in the savings module does not correlate with the main app session.

---

## Presentation-Only Features Without Data/Domain Layers

Several features have only a `presentation/` directory with no `data/` or `domain/` sublayers:
- `lib/features/account/` — presentation only
- `lib/features/balance/` — presentation only  
- `lib/features/home/` — presentation only
- `lib/features/b2c/` — presentation only
- `lib/features/insurance/` — presentation only (WebView shell)

**Impact:** These features borrow data from other features' blocs/repositories directly rather than owning their own domain layer. This creates implicit coupling.

---

## QA / Dev Tools in Production Bundle

**Expected:** Dev tooling excluded from production builds via build flavors or tree-shaking.

**Actual:** `MoengageApi`, `AccountCredentialsHelper`, `QATestingTools`, `QANotificationBloc`, and `QACredentialsBloc` are conditionally registered/shown based on `ENABLE_DEV_TOOLS` (an `envied`-sourced constant). The code is compiled into the production binary but guarded at runtime.

**Impact:** Dev tool code and the MoEngage API client (including campaign trigger capability) are present in production builds.

---

## PPOB Recent Transactions Cached Locally (No API)

**Expected:** Recent transaction history fetched from API.

**Actual:** `RecentTransactionRepository` and `RecentPDAMTransactionRepository` are backed exclusively by `HiveProductHelper` — no remote data source. Recent transactions are written to Hive after a successful payment and read back on the next visit.

**Impact:** History is device-local and lost on reinstall or app clear.
