# API Endpoints — talenta-mobile-android

Source: `data/src/main/java/co/talenta/data/EndpointConstants.kt` + all `*Api.kt` interfaces
Base URL injected at runtime via `lib_core_network` (dev/prod flavors).
Kong gateway prefix is applied for Kong-routed endpoints; non-Kong requests go directly to Talenta API.

## Auth
| Method | Path | Interface | Description |
|---|---|---|---|
| POST | `login` | AuthApi | Email/password login |
| GET | `security/info` | AuthApi | Get security settings |
| POST | `logout` | AuthApi | Logout |
| POST | `security/otp/validate` | AuthApi | Validate OTP |
| POST | `security/verified-phone/validate` | AuthApi | Validate phone number |
| POST | `verify-password` | AuthApi | Verify current password |
| GET | `sso-login` | AuthApi | SSO login with code |
| GET | `sso-change-password` | AuthApi | Get SSO change-password URL |
| GET | `oauth2/token` | OAuthApi | Get OAuth2 token |
| GET | `auth/oauth2/token` | OAuthApi | Legacy OAuth2 token |
| GET | `users/me/current_company` | OAuthApi | Current company for SSO |

## Dashboard
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `dashboard/time-off-policy` | DashboardApi | Time-off policy summary |
| GET | `dashboard/announcements` | DashboardApi | Announcements list |
| GET | `dashboard/user` | UserApi / DashboardApi | Logged-in user info |
| GET | `dashboard/icons` | DashboardApi | Dashboard icon config |
| GET | `mekari-flex/b2c/status` | DashboardApi | Mekari Flex B2C status |
| GET | `ems/mobile-config` | DashboardApi | Mobile config flags |
| GET | `toggle` | PortalApi / ToggleApi | Feature toggles |

## Live Attendance
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `attendance/companies/{orgId}/attendance_schedules/active` | LiveAttendanceApi | Active schedule for org |
| POST | `attendance/companies/{orgId}/attendance_clocks` | LiveAttendanceApi | Multi-company CICO (v1) |
| POST | `attendance/organisations/{orgId}/attendance_clocks` | LiveAttendanceApi | CICO (v3 + fingerprint) |
| POST | `live-attendance/send-approval` | LiveAttendanceApi | Request approval |
| GET | `live-attendance/history` | LiveAttendanceApi | CICO history by date |
| GET | `live-attendance/history-list` | LiveAttendanceApi | Paginated history log |
| GET | `live-attendance/detail` | LiveAttendanceApi | CICO log detail |
| GET | `maintenance/token` | LiveAttendanceApi | Emergency token |
| POST | `attendance/organisations/{orgId}/attendance_clocks/sync` | LiveAttendanceApi | Sync offline CICO batch |
| POST | `attendance/companies/{orgId}/attendance_clocks/validate_location` | LiveAttendanceApi | Validate location |
| GET | `attendance/organisations/{orgId}/summary_attendance_clocks/metrics_agg` | LiveAttendanceApi | Attendance metrics aggregation |
| GET | `attendance/organisations/{orgId}/summary_attendance_clocks/metrics` | LiveAttendanceApi | Attendance metrics logs |
| GET | `attendance/companies/{orgId}/summary_attendance_clocks` | LiveAttendanceApi | Request attendance log |
| GET | `attendance/organisations/{orgId}/summary_attendance_clocks` | LiveAttendanceApi | Monthly attendance log |
| GET | `live-attendance/address` | LiveAttendanceApi | Location address |
| GET | `time-off-info` | LiveAttendanceApi | Time-off info per date |
| GET | `attendance/organisations/{orgId}/on_call_plannings` | LiveAttendanceApi | On-call planning |
| POST | `attendance/organisations/{orgId}/attendance_clocks/enroll_profile` | LiveAttendanceApi | Verify selfie photo |
| GET | `attendance/organisations/{orgId}/attendance_clocks/status` | LiveAttendanceApi | Async clock-in progress |
| GET | `attendance/companies/{companyId}/attendance_clocks/{id}` | KongLiveAttendanceApi | Log detail (Kong) |
| GET | `attendance/companies/{companyId}/locations/search` | KongLiveAttendanceApi | Location search (Kong) |
| GET | `attendance/companies/{companyId}/locations/live_attendance` | KongLiveAttendanceApi | Live attendance locations |

## Live Tracking
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `companies/{companyId}/users/{userId}/live-tracking-status` | LiveTrackingApi | Employee tracking status |
| GET | `companies/{orgId}/users/{userId}/live-tracking-waypoints` | LiveTrackingApi | GPS waypoints |
| GET | `companies/{companyId}/users/{userId}/live-tracking-log-locations` | LiveTrackingApi | Location log |
| POST | `companies/{companyId}/vernemq/generate-auth` | MqttAuthApi | MQTT broker auth token |

## Time Off
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `history-request/timeoff` | TimeOffApi | Time-off history list |
| GET | `history-request/timeoff/{id}` | TimeOffApi | Time-off detail |
| GET | `history-request/timeoff/delegation/{id}` | TimeOffApi | Delegation detail |
| POST | `cancel-request` | TimeOffApi | Cancel time-off request |
| GET | `time-off/taken-list/{policyId}` | TimeOffApi | Taken time-off history |
| GET | `time-off/balance-detail` | TimeOffApi | Balance history |
| GET | `time-off-request` | TimeOffApi | Policies for request form |
| POST | `time-off-request` | TimeOffApi | Submit time-off request |
| GET | `time-off-request/delegation-list` | TimeOffApi | Delegation employee list |
| GET | `multiple-shift/check-status` | TimeOffApi | Check multi-shift status |
| GET | `request/employee-list` | TimeOffApi | Subordinate employee list |

## Overtime
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `history-request/overtime` | OvertimeApi | Overtime history |
| GET | `overtime-request` | OvertimeApi | Overtime request form data |
| POST | `overtime-request` | OvertimeApi | Submit overtime request |
| GET | `history-request/overtime/{id}` | OvertimeApi | Overtime detail |
| POST | `cancel-request` | OvertimeApi | Cancel overtime |
| GET | `companies/{companyId}/overtime-plannings/users` | OvertimeApi | Overtime planning list |
| GET | `companies/{companyId}/overtime-plannings/users/{id}` | OvertimeApi | Planning detail |
| POST | `overtime-request` | OvertimeApi | Submit overtime planning |
| POST | `companies/{companyId}/overtime-plannings/users/{id}/reject` | OvertimeApi | Reject planning |

## Shift
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `history-request/change-shift` | ShiftApi | Shift change history |
| GET | `history-request/change-shift/{id}` | ShiftApi | Shift change detail |
| POST | `cancel-request` | ShiftApi | Cancel shift request |
| GET | `shift-list` | ShiftApi | Available shifts |
| GET | `shift-request` | ShiftApi | Change shift form data |
| POST | `shift-request` | ShiftApi | Submit shift change request |

## Task / Timesheet
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `time-sheet/get-list-task` | TaskApi | Task list |
| GET | `time-sheet/task-detail/{id}` | TaskApi | Task detail |
| POST | `time-sheet/update-task-status/{id}` | TaskApi | Update task status |
| DELETE | `time-sheet/delete-task/{id}` | TaskApi | Delete task |
| GET | `time-sheet/task-activity` | TaskApi | Task activity list |
| POST | `time-sheet/task-detail/{id}` | TaskApi | Create task action |
| PUT | `time-sheet/task-detail/{id}` | TaskApi | Update task action |
| DELETE/POST | `time-sheet/delete-task-activity/{id}` | TaskApi | Delete task activity |
| GET | `time-sheet/assignee-list/{id}` | TaskApi | Assignee list by project |
| PUT | `task/{id}/notification` | TaskApi | Edit notification flag |

## Employee
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `employee/{id}` | EmployeeApi | Employee detail |
| GET | `my-info/attendance-log/detail` | EmployeeApi | Attendance log details |
| GET | `employee/on-leave` | EmployeeApi | Employees on leave today |
| GET | `employee` | EmployeeApi / PortalApi | Employee list (with filter) |
| GET | `branch` | EmployeeApi | Branch list |
| GET | `organization` | EmployeeApi | Organization list |
| GET | `employee/on-leave/{id}` | EmployeeApi | Employee leave detail |

## Inbox / Approval
| Method | Path | Interface | Description |
|---|---|---|---|
| PATCH | `inbox-notification/mark-all-read` | InboxApi | Mark all notifications read |
| GET | `inbox-detail/{id}` | InboxApi | Approval inbox detail |
| GET | `inbox/{id}` | InboxApi | Need-approval inbox data |
| POST | `approval-request/time-sheet` | InboxApi | Approve single timesheet |
| GET | `inbox/overtime-info` | InboxApi | Overtime notification count |
| GET | `inbox-notification` | InboxApi | Notification count |
| POST | `approval-request/attendance-bulk` | BulkApprovalApi | Bulk approve attendance |
| POST | `approval-request/change-shift-bulk` | BulkApprovalApi | Bulk approve shift change |
| POST | `approval-request/change-data-bulk` | BulkApprovalApi | Bulk approve change data |
| POST | `approval/custom-form-bulk` | BulkApprovalApi | Bulk approve forms |
| POST | `approval-request/timeoff-bulk` | BulkApprovalApi | Bulk approve time off |
| POST | `approval-request/bulk-reimbursement` | BulkApprovalApi | Bulk approve reimbursement |
| POST | `approval-request/bulk-overtime-planning` | BulkApprovalApi | Bulk approve OT planning |
| POST | `approval-request/bulk-overtime` | BulkApprovalApi | Bulk approve OT request |
| POST | `approval-request/bulk-add-employee` | BulkApprovalApi | Bulk approve add employee |
| POST | `approval-request/bulk-employee-transfer` | BulkApprovalApi | Bulk approve transfer |
| POST | `approval-request/bulk-time-sheet` | BulkApprovalApi | Bulk approve timesheet |
| POST | `approval-request/bulk-company-task` | BulkApprovalApi | Bulk approve tasks |
| GET | `progress-bar` | BulkApprovalApi | Bulk approval progress |

## Reprimand
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `reprimand` | ReprimandApi | Reprimand list |
| GET | `reprimand/{id}` | ReprimandApi | Reprimand detail |
| GET | `comment/reprimand-feedback/{id}` | ReprimandApi | Feedback thread |
| POST | `comment/reprimand-feedback/{id}` | ReprimandApi | Create feedback |
| PUT | `comment/reprimand-feedback/{reprimandId}/{id}` | ReprimandApi | Update feedback |
| DELETE | `comment/reprimand-feedback/{reprimandId}/{id}` | ReprimandApi | Delete feedback |

## Custom Forms
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `custom-form/all-form` | CustomFormApi | All forms |
| GET | `custom-form-submissions/all` | CustomFormApi | All submissions |
| GET | `custom-form-submissions/detail` | CustomFormApi | Submission detail |
| GET | `custom-form/generate-identity-token` | CustomFormApi | Identity token |
| POST/DELETE | `custom-form-submissions` | CustomFormApi | Submit / delete form |

## Portal (Frontdesk)
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `portal/validation` | PortalApi | Validate user for portal |
| GET | `live-attendance` | PortalApi | Get employee live attendance |
| POST | `live-attendance` | PortalApi | Post CICO (portal v1) |
| POST | `attendance/companies/{companyId}/attendance_clocks` | PortalApi | Post CICO (portal v2) |
| GET | `live-attendance/history-list` | PortalApi | History log |
| GET | `live-attendance/server-time` | PortalApi | Server time (v1) |
| GET | `attendance/timezone` | PortalApi | Server time (v2) |
| POST | `portal/employee` | PortalApi | Sync new/resigned employees |
| GET | `portal/device` | PortalApi | Device info |
| GET | `portal/check` | PortalApi | Device/quota availability |
| POST | `portal/register` | PortalApi | Register device |

## Onboarding
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `onboarding/task-counter` | OnboardingApi | Task counter |
| GET | `onboarding/detail` | OnboardingApi | Employee onboarding detail |
| GET | `onboarding/tasks` | OnboardingApi | Tasks |
| GET | `onboarding/forms` | OnboardingApi | Forms |
| POST | `onboarding/tasks` | OnboardingApi | Update task status |
| GET | `onboarding/documents` | OnboardingApi | Documents |
| GET | `onboarding/colleagues` | OnboardingApi | Colleagues |
| GET | `onboarding/work-locations` | OnboardingApi | Work locations |

## Subordinate
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `subordinates` | SubordinateApi | Subordinate dashboard |
| GET | `subordinate/activities` | SubordinateApi | Subordinate activities |
| GET | `subordinate/activities-count` | SubordinateApi | Subordinate activity count |

## My Files
| Method | Path | Interface | Description |
|---|---|---|---|
| DELETE | `files/delete` | MyFilesApi | Delete file |
| GET | `my-info/my-file` | MyFilesApi | File list |
| GET | `file` | MyFilesApi | File types |
| POST | `file` | MyFilesApi | Upload file |
| POST | `files/update/{id}` | MyFilesApi | Update file |

## Performance Reviews
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `dashboard/reviews` | ReviewsApi | Review info |
| POST | `{dynamic_url}/auths/encrypt` | ReviewsApi | Encrypted token for review app |

## Consultant
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `consultant/company` | ConsultantApi | Company list |
| POST | `consultant/company/select` | ConsultantApi | Select active company |

## Integrations / System
| Method | Path | Interface | Description |
|---|---|---|---|
| GET | `expense-management/token` | MekariExpenseApi | Expense encrypted token |
| GET | `mekari-credit/register` | (data layer) | Mekari Flex registration |
| GET | `companies/{companyId}/integrity/status` | IntegrityApi | Device integrity status |
| POST | `companies/{companyId}/integrity/validate` | IntegrityApi | Validate integrity token |
| POST | `companies/{companyId}/integrity/verify-action` | IntegrityApi | Verify action integrity |
| GET | `health_checks` | KongHealthCheckApi | Kong gateway health check |
| POST | `mobile/fcm-tokens` | (data layer) | Register FCM token |
| DELETE | `mobile/fcm-tokens/delete` | (data layer) | Remove FCM token |
| GET | `employee/organization-chart` | OrganizationChartApi | Org chart |
| GET | `public_api/mixpanel/get-data` | CompanyApi | Mixpanel company data |
