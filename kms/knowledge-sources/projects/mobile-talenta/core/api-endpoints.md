---
scope: project/mobile-talenta
platform: flutter
discipline: engineering
artifact: api-endpoints
---
# API Endpoints

Platform: Flutter | Network layer: `mekari_network` (Dio-based `NetworkClient`)

## Base URLs

| Mode | Kong gateway | Non-Kong (direct) |
|---|---|---|
| Production | `https://api.mekari.com/internal/talenta-mobile/v1` | `https://api-mobile.talenta.co/api/v1` |
| Staging (PPE) | `https://api.mekari.io/internal/talenta-mobile-ppe/v1` | `https://talenta-ppe-api-mobile.talentadev.com/api/v1` |

### Service-specific base URLs (Kong only)

| Service | Production | Staging |
|---|---|---|
| Geolocation | `https://api.mekari.com/internal/talenta-geolocation/v1` | `https://api.mekari.io/internal/talenta-geolocation-ppe/v1` |
| Time Off | `https://api.mekari.com/internal/talenta-time-off/v1` | `https://api.mekari.io/internal/talenta-time-off-ppe/v1` |

---

## Authentication

| Method | Endpoint | Description |
|---|---|---|
| POST | `/authentication/authenticate` | Legacy username/password login |
| POST | `/sso_authentication/authenticate` | SSO login |
| GET | `/dashboard/user` | Fetch current user info |

---

## Calendar

| Method | Endpoint | Description |
|---|---|---|
| GET | `/calendar/index` | Calendar index with events |
| GET | `/calendar/activity` | Calendar activity list |
| GET | `/calendar/activity-detail/{id}` | Activity detail |
| GET | `/calendar/holiday` | Company holidays |
| GET | `/calendar/birthday` | Employee birthdays |
| GET | `/calendar/greeting` | Birthday greeting message |
| GET | `/calendar/timeoff` | Time-off calendar view |
| GET | `/calendar/timeoff-detail` | Time-off detail for calendar |

---

## Attendance Clocks

| Method | Endpoint | Description |
|---|---|---|
| GET | `/attendance/organisations/{organisationId}/attendance_clocks` | List attendance clocks |
| GET | `/attendance/organisations/{organisationId}/attendance_clocks/status` | Attendance clock status (custom headers: `IS_NEW_FORMAT`, `IS_RETURN_MESSAGE`) |
| GET | `/attendance/companies/{organisationId}/attendance_clocks/{attendanceClockId}` | Clock detail |
| GET | `/attendance/companies/{organisationId}/locations/search` | Address/location lookup |

---

## Attendance Summary

| Method | Endpoint | Description |
|---|---|---|
| GET | `/attendance/organisations/{organisationId}/summary_attendance_clocks` | Attendance summary list |
| GET | `/attendance/organisations/{organisationId}/summary_attendance_clocks/metrics_agg` | Aggregated metrics |
| GET | `/attendance/organisations/{organisationId}/summary_attendance_clocks/metrics` | Per-employee metrics |
| GET | `/subordinates` | Subordinate employee list |

---

## Attendance Request

| Method | Endpoint | Description |
|---|---|---|
| GET | `/attendance-request` | Attendance request history |
| POST | `/attendance-request` | Submit attendance correction |

---

## Overtime

| Method | Endpoint | Description |
|---|---|---|
| GET | `/overtime-request` | Overtime request details |
| POST | `/overtime-request` | Submit overtime request |
| GET | `/history-request/overtime` | Overtime history list |
| GET | `/history-request/overtime/{id}` | Overtime history detail |
| GET | `/history-request/overtime-pending` | Pending overtime requests |
| GET | `/companies/{company_id}/teams/overtime-requests` | Team overtime requests |
| GET | `/request/employee-list` | Subordinate list for request |

---

## Shift Request

| Method | Endpoint | Description |
|---|---|---|
| GET | `/shift-request` | Shift request history |
| POST | `/shift-request` | Submit shift change request |
| GET | `/shift-list` | Available shifts |
| GET | `/history-request/change-shift/{id}` | Shift change detail |
| GET | `/history-request/change-shift` | Shift change history list |

---

## Time Off

All time-off service calls use `TalentaService.timeOff` — routes to the dedicated time-off micro-service base URL when Kong mode is active.

| Method | Endpoint | Description |
|---|---|---|
| GET | `/time-off-info` | Time-off info for a date |
| GET | `/history-request/timeoff` | Time-off request history list |
| GET | `/history-request/timeoff/{id}` | Time-off request detail |
| GET | `/time-off-request` | Time-off requests with delegation info |
| POST | `/time-off-request` | Submit time-off request (multipart, supports files) |
| GET | `/time-off-request/delegation-list` | Delegation list |
| GET | `/multiple-shift/check-status` | Check multiple-shift conflict |
| GET | `/request/employee-list` | Employee list for time-off |
| GET | `/companies/{company_id}/policies` | All time-off policies |
| GET | `/companies/{company_id}/policies/{policy_id}` | Policy detail |
| GET | `/companies/{company_id}/users/{user_id}/balances` | User time-off balances |
| GET | `/companies/{company_id}/users/{user_id}/balances/{policy_id}/overviews` | Balance overview for a policy |
| GET | `/companies/{company_id}/teams/time-off-requests` | Team time-off requests |
| GET | `/companies/{company_id}/users/{user_id}/<subordinate list>` | Time-off subordinate employee list |

---

## Location Tracking

| Method | Endpoint | Description |
|---|---|---|
| GET | `/location-details` | Location details for a position |
| GET | `/companies/{company_id}/users/{user_id}/live-tracking-waypoints` | Live tracking waypoints |
| PATCH | `/companies/{company_id}/users/{user_id}/live-tracking-waypoints/{waypoint_id}` | Update waypoint notes |
| POST | `/companies/{company_id}/vernemq/generate-auth` | Generate MQTT auth credentials |
| GET | `/companies/{company_id}/users/{user_id}/live-tracking/segments` | Segmented tracking segments |
| GET | `/companies/{company_id}/users/{user_id}/live-tracking/summary` | Segmented tracking summary |
| GET | `/companies/{company_id}/users/{user_id}/live-tracking-metric` | Live tracking metric |
| GET | `/companies/{company_id}/users/{user_id}/live-tracking-log-locations` | Tracking location log |

---

## Time Management Utilities

| Method | Endpoint | Description |
|---|---|---|
| GET | `/timezones` | Available timezones |
| GET | `/attendance_schedules/active` | Active attendance schedule |
| POST | `/cancel-request` | Cancel a pending request |

---

## Inbox

| Method | Endpoint | Description |
|---|---|---|
| GET | `/inbox` | Inbox index (paginated) |
| GET | `/inbox-detail/{inboxId}` | Inbox item detail |
| POST | `/inbox/file-download` | Download inbox attachment |

---

## Approval Requests

| Method | Endpoint | Description |
|---|---|---|
| POST | `/approval-request/overtime` | Approve/reject overtime |
| POST | `/approval-request/overtime-planning` | Approve/reject overtime planning |
| POST | `/approval-request/timeoff` | Approve/reject time-off |
| POST | `/approval-request/attendance` | Approve/reject attendance |
| POST | `/approval-request/live-attendance` | Approve/reject live attendance |
| POST | `/approval-request/change-shift` | Approve/reject shift change |
| POST | `/approval-request/change-personal-data` | Approve/reject personal data change |
| POST | `/approval-request/employee-transfer` | Approve/reject employee transfer |
| POST | `/approval-request/add-employee` | Approve/reject add employee |
| POST | `/approval-request/company-task` | Approve/reject task |
| POST | `/approval-request/custom-form` | Approve/reject custom form |
| POST | `/approval-request/reimbursement` | Approve/reject reimbursement |
| POST | `/approval-request/goal` | Approve/reject goal |
| GET | `/attendance/companies/{orgId}/attendance_clocks/{clockId}` | Clock info for inbox |
| GET | `/attendance/companies/{orgId}/locations/search/` | Address lookup for inbox |
| GET | `/custom-form-submissions/{submissionId}/questions/{questionId}/employees` | Custom form employee list |
| GET | `/custom-form-submissions/{submissionId}/edit-histories` | Submission edit history |

---

## Payslip

| Method | Endpoint | Description |
|---|---|---|
| GET | `/payslip/new` | Payslip v1 (period list or daily dates) |
| GET | `/payslip/check-auth` | Check payslip auth timeout |
| POST | `/verify-password` | Verify password for payslip access |
| GET | `/payroll/payslips/view` | Payroll micro-service payslip view (v3) |
| GET | `/payroll/payslips/check-auth` | Payroll micro-service auth check |
| GET | `/payroll/payslips/download` | Payroll micro-service download |
| GET | `/payslip/download` | Download payslip |
| GET | `/payslip/download-form-1721-a1` | Download 1721-A1 tax form |
| GET | `/payslip/download-1721-vi` | Download 1721-VI form |
| GET | `/payslip/download-1721-vii` | Download 1721-VII form |
| GET | `/payslip/download-1721-viii` | Download 1721-VIII form |
| GET | `/payslip/download-thr` | Download THR slip |

### Reimbursement

| Method | Endpoint | Description |
|---|---|---|
| GET | `/reimbursement-active-policy` | Reimbursement balance (active policies) |
| GET | `/history-request/reimbursement` | Reimbursement request list |
| GET | `/history-request/reimbursement/{id}` | Reimbursement request detail |
| POST | `/reimbursement-request/paid-amount` | Calculate total paid amount |
| GET | `/reimbursement-request` | Reimbursement request data |
| POST | `/reimbursement-request` | Submit reimbursement request (multipart) |
| POST | `/cancel-request` | Cancel reimbursement |
| GET | `/reimbursement-beneficiaries` | Beneficiary list |

---

## Account Profile

| Method | Endpoint | Description |
|---|---|---|
| GET | `/my-info/payroll-info` | Payroll info detail |
| GET | `/my-info/employment-info` | Employment info |
| GET | `/my-info/family-info` | Family info |
| GET | `/my-info/list-family` | Family relationship types |
| GET | `/employees/personal/emergency-contact` | Emergency contacts |
| POST | `/employees/personal/emergency-contact` | Create emergency contact |
| PUT | `/employees/personal/emergency-contact/{id}` | Edit emergency contact |
| DELETE | `/employees/personal/emergency-contact/{id}` | Delete emergency contact |
| POST | `/otp/request` | Request OTP (challenge-OTP headers) |
| GET | `/custom-field` | Custom fields (additional info) |
| PUT | `/custom-field` | Update custom fields |
| GET | `/personal-data-request` | Change data request current data |
| POST | `/personal-data-request` | Submit change data request (multipart) |
| GET | `/history-request/change-data` | Change data history list |
| GET | `/history-request/change-data/{id}` | Change data history detail |
| GET | `/setting/company/updatable-fields` | Updatable fields configuration |
| POST | `/cancel-request` | Cancel change data request |
| POST | `/bank-account/check` | Verify bank account |
| GET | `/asset-management/assets/assigned/{userId}` | Assigned assets list |
| GET | `/asset-management/asset-assignees/{id}` | Asset detail |
| GET | `/announcement` | Announcement list |
| GET | `/announcement/{id}` | Announcement detail |
| GET | `/announcement/categories` | Announcement categories |
| GET | `/sso-change-password` | SSO change password redirect URL |

---

## Performance

| Method | Endpoint | Description |
|---|---|---|
| GET | `/dashboard/reviews` | Performance WebView URL + badge flag (`IS_FROM_KONG` header) |
| GET | `/dashboard/latest-tasks-performance-management` | Pending performance tasks |
| GET | `/dashboard/latest-goals-performance-management` | Latest performance goals |

---

## Task Management

| Method | Endpoint | Description |
|---|---|---|
| POST | `/time-sheet/create-task` | Create task (multipart with files) |
| PUT | `/time-sheet/edit-task/{id}` | Edit task (multipart with files) |
| GET | `/time-sheet/check-approval-setting` | Check if approval required |
| GET | `/time-sheet/assignee-list` | Assignee list |
| GET | `/project` | Project list |
| GET | `/project/detail` | Project detail |
| PUT | `/project/{id}/set-archive` | Archive/unarchive project |
