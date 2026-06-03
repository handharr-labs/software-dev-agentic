---
platform: web
project: web
discipline: engineering
topic: app
pattern: placeholder
---

## Theory

The **App Layer** wires the app at startup: dependency registration, route registration, analytics constants, feature flag registration, push notification registration, and deeplink registration.

**Invariants:**
- All bindings and registrations live at the app shell — never inside a CLEAN layer
- Each feature owns its own registration unit — one file per feature
- Registration order follows the dependency graph: data sources → repositories → use cases
- Routes and deeplinks share the same identifier system — no parallel routing system

---

## App Layer

The web app layer conventions are not yet established. Sections below are stubs pending adoption.

## Dependency Registration

> No convention established yet. Document the Web dependency injection pattern (React Context, providers, or DI library) here when adopted.

## Route Registration

> No convention established yet. Document the Web route registration pattern (Next.js App Router pages/layouts) here when adopted.

## Module Registration

> No convention established yet. Document the Web module registration pattern here when adopted. Next.js uses file-based routing — this step may not apply.

## Analytics Constants

> No convention established yet. Document the Web analytics constants pattern (event names, screen identifiers) here when adopted.

## Feature Flag Registration

> No convention established yet. Document the Web feature flag pattern (MekariFlag SDK or equivalent) here when adopted.

## Push Notification Registration

> No convention established yet. Document the Web push notification pattern (FCM + Service Worker registration) here when adopted.

## Deeplink Registration

> No convention established yet. Document the Web deeplink/universal link handling pattern here when adopted.

## Planner Search Patterns

> No convention established yet. Add glob patterns per scope key once DI, route, module, analytics, and feature flag conventions are adopted.

| Scope key | Glob / Path | Grep hint |
|---|---|---|
| `di` | > No convention established yet | — |
| `route` | > No convention established yet | — |
| `module` | > No convention established yet | — |
| `analytics` | > No convention established yet | — |
| `feature_flag` | > No convention established yet | — |
