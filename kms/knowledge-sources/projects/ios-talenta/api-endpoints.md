# API Endpoints — ios-talenta

Platform: iOS (Swift/UIKit) — Moya + RxSwift networking stack
Base URL: `TalentaEnvironment.baseURL` (env-switched; prod = `hr.talenta.co`)
Auth: Bearer token via Kong API gateway; OAuth2 PKCE (SSO)
Scanned: 2026-06-04

## Networking Architecture

- **Moya** `TargetType` / `CoreNetwork` enums define endpoints
- **NetworkMiddleware<N>** wraps concrete network classes (`AttendanceDataRequest`, `TimeOffDataRequest`, `OvertimeNetworkRequest`, etc.)
- **`TalentaBaseResponse<T>`** standard response wrapper; error model is `TalentaBaseErrorModel`
- Headers provided via `CommonHeader.core.header` or `AuthService.getHTTPHeaders()`

---

## Auth

| Method | Path | Description |
|--------|------|-------------|
| POST | `login` | Username/password login |
| POST | `logout` | Session logout |
| POST | `verify-password` | Verify current password |

## User / My Info

| Method | Path | Description |
|--------|------|-------------|
| GET | `my-info/employment-info` | Employment details |
| GET | `my-info/family-info` | Family info |
| GET | `my-info/education-info` | Education info |
| GET | `my-info/payroll-info` | Payroll info |
| GET | `my-info/my-file` | My file list (params: category, pagination) |
| GET | `payslip` | Payslip data (params: `month`, `year`) |
| POST | `personal-data-request` | Submit personal data change request |

## Files

| Method | Path | Description |
|--------|------|-------------|
| GET | `file` | Get file types |
| POST | `file` | Upload file (multipart) |
| DELETE | `files/delete` | Delete file by ID |
| PUT | `files/update/{fileId}` | Update file metadata (multipart) |

## Dashboard

| Method | Path | Description |
|--------|------|-------------|
| GET | `dashboard` | Dashboard data (params: various) |
| GET | `inbox-notification` | Notification badge count |

## Inbox / Approval

| Method | Path | Description |
|--------|------|-------------|
| GET | `inbox/{notificationType}` | Inbox list by type (page, query, status) |
| GET | `inbox-detail/{inboxId}` | Inbox item detail |
| POST | `approval-request/{detailType}` | Approve/reject by detail type |
| POST | `approval-request/live-attendance` | Approve/reject live attendance request |
| POST | `approval-request/timeoff-bulk` | Bulk time-off approval |

## Attendance (Live Attendance / CICO)

| Method | Path | Description |
|--------|------|-------------|
| GET | Live attendance data | Get CICO data (single shift) with optional GPS coords |
| GET | Live attendance multi-shift | Get CICO data (multi-shift) |
| GET | Live attendance log by ID | Log entries by attendance ID and date |
| GET | Token lite | Lightweight CICO token |
| POST | Submit CICO | Clock-in / clock-out submission |
| GET | Async live attendance | Async attendance status |
| POST | Request live attendance approval | Manager-side CICO approval |

_Note: CICO paths are defined in `AttendanceDataRequest` (not a plain TargetType enum); exact paths not in scanned files but the service methods above map to the attendance domain._

## Attendance Request

| Method | Path | Description |
|--------|------|-------------|
| GET | Attendance request history | List with status/date range filters (page, status, startMonth, startYear, endMonth, endYear) |
| POST | Request attendance | Submit attendance correction |

## Time Off

| Method | Path | Description |
|--------|------|-------------|
| GET | Time off data | Fetch leave policy and balance |
| POST | Submit time off request | Single leave request |
| GET | Hourly leave data | Multi-shift hourly leave check |
| GET | Time off delegations | Delegation list (page, query) |
| GET | Check multiple shift | Check shifts on given date |

## Overtime

| Method | Path | Description |
|--------|------|-------------|
| GET | Overtime history | Paginated list (status, date range) |
| POST | Request overtime | Submit overtime request |
| GET | Planning overtime | Overtime planning tab data |
| GET | Overtime notification detail | Detail for approval notification |

## Change Shift

| Method | Path | Description |
|--------|------|-------------|
| GET | New shift options | Available shifts for change |
| POST | Submit shift change request | Shift change request |
| GET | Shift change notification detail | Detail for approval notification |

## Announcements

| Method | Path | Description |
|--------|------|-------------|
| GET | `announcement` | Announcement list (page, query, category) |
| GET | Announcement categories | Category list |
| GET | Announcement detail by ID | Full announcement content |
| GET | Auth token for custom form | Token for embedded custom form in announcement |

## Tasks / Timesheet

| Method | Path | Description |
|--------|------|-------------|
| GET | `task/{taskId}` | Task detail |
| GET | `task` | Task list (page) |
| POST | `time-sheet/create-task` | Create new task (multipart) |
| PUT | `time-sheet/edit-task/{taskId}` | Edit task (multipart) |
| GET | Timesheet index | Timesheet list |
| GET | Timesheet detail | Single timesheet entry |

## Commerce / Other

| Method | Path | Description |
|--------|------|-------------|
| POST | `mekari-credit/register` | Register for Mekari Credit |
| POST | FCM token | Register device push token |
| DELETE | FCM token | Delete device push token |
| GET | Org chart | Organization chart data |
| GET | Insight WebView URL | URL for insight dashboard embed |
| GET | Officeless WebView URL | URL for officeless mode |
