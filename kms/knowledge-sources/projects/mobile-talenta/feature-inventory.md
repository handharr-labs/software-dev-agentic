# Feature Inventory — flutter-mobile-talenta

**Platform:** Flutter (Dart/BLoC, Clean Architecture)
**Module version:** talenta_module 1.34.0

## Features

| # | Feature Module | Domain | Description |
|---|---|---|---|
| 1 | `talenta_account` | My Info / Profile | Personal info, employment info, payroll info, family info, emergency contacts, asset management, additional info (custom fields) |
| 2 | `talenta_account` — Announcements | Comms | Browse announcements by category; offline cache via local datasource |
| 3 | `talenta_account` — Change Data | HR Self-Service | Request personal data changes, view history/details, cancel request, OTP challenge, bank account verification |
| 4 | `talenta_account` — Change Password | Auth | SSO-based change password via WebView |
| 5 | `talenta_inbox` | Approvals / Inbox | Inbox index + detail for: overtime, overtime planning, time-off, attendance, live attendance, change shift, change data, add employee, employee transfer, custom form, reimbursement, goals/edit goals/update goal progress |
| 6 | `talenta_inbox` — Post Approval | Approvals | Type-switched approval posting across all inbox types |
| 7 | `talenta_tnt` | Task & Project (TNT) | Create/edit tasks with file attachments; project list/detail/archive; assignee selection; timesheet approval setting check |
| 8 | `talenta_performance` | Performance Management | Performance home (tasks + goals dashboard); WebView redirect for reviews; badge visibility toggle |
| 9 | `talenta_tm` | Time Management | Calendar, time-off requests, overtime requests, attendance clocks, shift requests/changes, live tracking (waypoints, segments, summary), MQTT-based real-time connectivity, delegation |
| 10 | `talenta_tm` — Live Tracking | Attendance | Background geolocation with live tracking waypoints; MQTT auth per company/user |
| 11 | Login / Auth (host app) | Auth | SSO + direct login, token storage, logout, user info fetch |
| 12 | Brick WebView Host | UI Rendering | Brick-based page/dialog/bottom-sheet rendering driven from host app |

## Module Paths

| Module | Path |
|---|---|
| `talenta_account` | `talenta/lib/src/features/account/` |
| `talenta_inbox` | `talenta/lib/src/features/inbox/` |
| `talenta_tnt` | `talenta/lib/src/features/tnt/` |
| `talenta_performance` | `talenta/lib/src/features/performance/` |
| `talenta_tm` | `talenta/lib/src/features/tm/` |
| Shared core | `talenta/lib/src/shared/core/` |
| Host app | `lib/src/` |
