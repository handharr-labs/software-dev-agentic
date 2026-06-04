# API Endpoints — flutter-mobile-talenta

**Base URL strategy:** Kong gateway (configurable via `Config().isUseKongEnv()`); v1 via `networkClient.get/post/put`, v2 via `networkClient.getV2/postV2`.

## Host App (`lib/src/configs/constant/endpoint.dart`)

| Method | Path | Purpose |
|---|---|---|
| POST | `/sso_authentication/authenticate` | SSO login |
| POST | `/authentication/authenticate` | Direct login |
| GET | `/dashboard/user` | Current user info |

## Shared Core (`talenta/lib/src/shared/core/configs/constants/endpoint.dart`)

| Method | Path | Purpose |
|---|---|---|
| GET | `/dashboard/user` | Dashboard user data |
| POST | `/document-template/add-footer-timestamp` | Document template footer |

## talenta_account

| Method | Path | Purpose |
|---|---|---|
| GET | `/my-info/payroll-info` | Payroll info |
| GET | `/my-info/employment-info` | Employment/personal info |
| GET | `/personal-data-request` | Current personal data |
| POST | `/personal-data-request` | Request change data (multipart) |
| GET | `/history-request/change-data` | Change data history (paginated) |
| GET | `/history-request/change-data/{id}` | Change data detail |
| POST | `/cancel-request` | Cancel change data |
| POST | `/bank-account/check` | Verify bank account |
| GET | `/asset-management/assets/assigned/{userId}` | Asset list |
| GET | `/asset-management/asset-assignees/{id}` | Asset detail |
| GET | `/my-info/list-family` | Family info list |
| GET | `/my-info/family-info` | Family info |
| GET | `/employees/personal/emergency-contact` | Emergency contacts |
| POST | `/employees/personal/emergency-contact` | Create emergency contact |
| PUT | `/employees/personal/emergency-contact` | Edit emergency contact |
| DELETE | `/employees/personal/emergency-contact` | Delete emergency contact |
| GET | `/custom-field` (v2) | Custom fields |
| PUT | `/custom-field` | Edit custom fields |
| POST | `/otp/request` | OTP request |
| GET | `/setting/company/updatable-fields` (v2) | Updatable field config |
| GET | `/announcement` (v2) | Announcement list |
| GET | `/announcement/{id}` (v2) | Announcement detail |
| GET | `/announcement/categories` (v2) | Announcement categories |
| GET | `/sso-change-password` | SSO change password URL |

## talenta_inbox

| Method | Path | Purpose |
|---|---|---|
| GET | `/inbox` | Inbox index |
| GET | `/inbox-detail/{id}` | Inbox detail |
| POST | `/approval-request/overtime` | Approve overtime |
| POST | `/approval-request/overtime-planning` | Approve overtime planning |
| POST | `/approval-request/company-task` | Approve task |
| POST | `/approval-request/timeoff` | Approve time-off |
| POST | `/approval-request/live-attendance` | Approve live attendance |
| POST | `/approval-request/attendance` | Approve attendance |
| POST | `/approval-request/change-shift` | Approve shift change |
| POST | `/approval-request/change-personal-data` | Approve data change |
| POST | `/approval-request/employee-transfer` | Approve transfer |
| POST | `/approval-request/add-employee` | Approve add employee |
| POST | `/approval-request/custom-form` | Approve custom form |
| POST | `/approval-request/reimbursement` | Approve reimbursement |
| POST | `/approval-request/goal` | Approve goal |
| GET | `/attendance/companies/{orgId}/attendance_clocks/{clockId}` | Attendance clock |
| GET | `/attendance/companies/{orgId}/locations/search` | Location search |
| GET | `/custom-form-submissions/{submissionId}/questions/{questionId}/employees` | Custom form employees |
| GET | `/custom-form-submissions/{submissionId}/edit-histories` | Submission edit history |
| POST | `/inbox/file-download` (v2) | Inbox file download |

## talenta_tnt

| Method | Path | Purpose |
|---|---|---|
| POST | `/time-sheet/create-task` | Create task (multipart) |
| PUT | `/time-sheet/edit-task/{id}` | Edit task (multipart) |
| GET | `/time-sheet/assignee-list` | Assignee list |
| GET | `/project` | Project list (paginated) |
| GET | `/project/detail` | Project detail |
| POST/PUT | `/project/{id}/set-archive` | Archive project |
| GET | `/time-sheet/check-approval-setting` | Timesheet approval setting |

## talenta_performance

| Method | Path | Purpose |
|---|---|---|
| GET | `/dashboard/reviews` | Performance WebView URLs + badge |
| GET | `/dashboard/latest-tasks-performance-management` | Latest performance tasks |
| GET | `/dashboard/latest-goals-performance-management` | Latest performance goals |

## talenta_tm (Time Management)

| Method | Path | Purpose |
|---|---|---|
| GET/POST | `/calendar`, `/calendar/timeoff`, `/calendar/birthday` | Calendar data |
| GET/POST | `/attendance_clocks`, `/attendance_clocks/status` | Attendance clocks |
| GET | `/attendance/organisations` | Attendance organisations |
| GET | `/summary_attendance_clocks`, `/metrics`, `/metrics_agg` | Attendance summaries |
| GET | `/subordinates` | Subordinate list |
| POST | `/attendance-request` | Attendance request |
| POST | `/shift-request` | Shift request |
| GET | `/shift-list` | Shift list |
| POST | `/overtime-request` | Overtime request |
| GET | `/history-request/overtime` | Overtime history |
| GET | `/history-request/overtime-pending` | Pending overtime |
| POST | `/time-off-request` | Time-off request |
| GET | `/history-request/timeoff` | Time-off history |
| GET | `/companies/{company_id}/users/{user_id}/live-tracking-waypoints` | Live tracking waypoints |
| POST | `/companies/{company_id}/users/{user_id}/live-tracking-waypoints` | Post waypoints |
| GET | `/companies/{company_id}/users/{user_id}/live-tracking/segments` | Tracking segments |
| GET | `/companies/{company_id}/users/{user_id}/live-tracking/summary` | Tracking summary |
| POST | `/companies/{company_id}/vernemq/generate-auth` | MQTT auth |
| GET | `/companies/{company_id}/users/{user_id}/balances` | Time-off balances |
| GET | `/companies/{company_id}/policies/{policy_id}` | Time-off policy detail |
| GET | `/time-off-info` | Time-off info |
| GET | `/timezones` | Timezone list |
| GET | `/time-off-request/delegation-list` | Delegation list |
| POST | `/cancel-request` | Cancel request |
| GET | `/attendance_schedules/active` | Active schedule |
| GET | `/multiple-shift/check-status` | Multiple shift check |
