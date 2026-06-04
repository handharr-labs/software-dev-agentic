> Template — seeds stub nodes for QA checklist and test template patterns.
> Each ## section → one ChromaDB node. Universal scope — applies across all platforms.

## Smoke Test
### Scope
_Stub — critical-path flows to verify a build is testable: login, core navigation, primary action per feature._
### Preconditions
_Stub — required test data, accounts, environment state._
### Checklist
_Stub — ordered steps for the smoke run._
### Pass Criteria
_Stub — what constitutes a passing smoke run._

## Regression Checklist
### Scope
_Stub — full regression coverage for a feature or release; runs after every significant change._
### Preconditions
_Stub — required test data and environment._
### Checklist
_Stub — grouped checklist by flow: happy path, edge cases, error states._
### Pass Criteria
_Stub — all items green; known accepted defects documented._

## API Contract Test
### Scope
_Stub — validates that API responses match the contract the client expects; catches backend breaks._
### Preconditions
_Stub — staging/mock server, auth token, sample request payloads._
### Checklist
_Stub — fields, types, nullable checks, status codes, error payloads._
### Pass Criteria
_Stub — all contract assertions pass; no unexpected nulls or type mismatches._

## UI Automation Test
### Scope
_Stub — end-to-end flow automation on real device or simulator; covers happy path + one error path per feature._
### Preconditions
_Stub — test account, seeded data, device/simulator state._
### Checklist
_Stub — automation script coverage per flow._
### Pass Criteria
_Stub — all assertions pass; no flaky steps._

## Exploratory Testing
### Scope
_Stub — unscripted testing to surface unexpected behavior; runs before release or after major changes._
### Preconditions
_Stub — staging environment, tester access, feature context._
### Checklist
_Stub — areas to explore: boundary values, permission edge cases, offline behavior, locale._
### Pass Criteria
_Stub — findings logged; critical/high issues resolved before release._

## Accessibility Test
### Scope
_Stub — screen reader compatibility, tap target sizes, color contrast; mandatory for user-facing flows._
### Preconditions
_Stub — TalkBack / VoiceOver enabled, test device._
### Checklist
_Stub — content descriptions, focus order, contrast ratios, minimum touch targets._
### Pass Criteria
_Stub — no screen reader dead zones; all interactive elements reachable and labeled._

## Performance Test
### Scope
_Stub — frame rate, startup time, memory usage; runs on target minimum-spec device._
### Preconditions
_Stub — profiling tool configured (Xcode Instruments / Android Profiler / Flutter DevTools)._
### Checklist
_Stub — FPS under scroll, cold start time, memory leak check, network request timing._
### Pass Criteria
_Stub — no jank (< 16ms frame budget); cold start within threshold; no leaks detected._
