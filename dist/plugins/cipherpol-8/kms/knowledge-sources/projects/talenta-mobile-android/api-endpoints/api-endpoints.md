---
scope: project/talenta-mobile-android
platform: android
discipline: engineering
artifact: api-endpoints
---
# API Endpoints

## Auth

| Method | Path | File |
|---|---|---|
| POST | EndpointConstants.LOGIN | AuthApi.kt |
| GET | EndpointConstants.SECURITY_INFO | AuthApi.kt |
| POST | EndpointConstants.LOGOUT | AuthApi.kt |
| POST | EndpointConstants.VALIDATE_OTP | AuthApi.kt |
| POST | EndpointConstants.VALIDATE_PHONE_NUMBER | AuthApi.kt |
| POST | EndpointConstants.VERIFY_PASSWORD | AuthApi.kt |
| GET | EndpointConstants.SSO_LOGIN | AuthApi.kt |
| GET | EndpointConstants.SSO_CHANGE_PASSWORD | AuthApi.kt |

## LiveAttendance

| Method | Path | File |
|---|---|---|
| GET | live_attendance_companies/{organizationId}/active_schedule | LiveAttendanceApi.kt |
| POST | live_attendance_companies/{organizationId}/cico | LiveAttendanceApi.kt |
| POST | LIVE_ATTENDANCE_APPROVAL | LiveAttendanceApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE_HISTORY | LiveAttendanceApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE_DETAIL | LiveAttendanceApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE_EMERGENCY_TOKEN | LiveAttendanceApi.kt |
| POST | live_attendance_organisations/{organizationId}/attendance_clocks/sync | LiveAttendanceApi.kt |
| POST | live_attendance_companies/{organizationId}/attendance_clocks/validate_location | LiveAttendanceApi.kt |
| GET | attendance_companies/{organizationId}/summary_attendance_clocks | LiveAttendanceApi.kt |
| GET | live_attendance_organisations/{organizationId}/summary_attendance_clocks | LiveAttendanceApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE_HISTORY_LIST | LiveAttendanceApi.kt |
| GET | attendance/live_attendance_organisations/{organizationId}/summary_attendance_clocks/attendance_metrics_aggregation | LiveAttendanceApi.kt |
| GET | attendance/live_attendance_organisations/{organizationId}/summary_attendance_clocks/attendance_metrics | LiveAttendanceApi.kt |
| POST | live_attendance_organisations/{organizationId}/attendance_clocks | LiveAttendanceApi.kt |
| GET | live_attendance_organisations/{organizationId}/clocks_status | LiveAttendanceApi.kt |
| POST | live_attendance_organisations/{organizationId}/attendance_clocks/enroll_profile | LiveAttendanceApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE_ADDRESS | LiveAttendanceApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE_TIMEOFF | LiveAttendanceApi.kt |
| GET | live_attendance_organisations/{organizationId}/on_call_planning | LiveAttendanceApi.kt |

## Portal

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.VALIDATE_USER_PORTAL | PortalApi.kt |
| GET | EndpointConstants.EMPLOYEE | PortalApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE | PortalApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE_HISTORY_LIST | PortalApi.kt |
| POST | EndpointConstants.LIVE_ATTENDANCE | PortalApi.kt |
| POST | attendance_companies/{companyId}/attendance_clocks | PortalApi.kt |
| GET | EndpointConstants.TOGGLE | PortalApi.kt |
| GET | EndpointConstants.LIVE_ATTENDANCE_SERVER_TIME | PortalApi.kt |
| GET | attendance/timezone | PortalApi.kt |
| POST | EndpointConstants.NEW_AND_RESIGNED_PORTAL_EMPLOYEE | PortalApi.kt |
| GET | EndpointConstants.DEVICE_INFO_PORTAL | PortalApi.kt |
| GET | EndpointConstants.CHECK_DEVICE_AND_QUOTA_PORTAL | PortalApi.kt |
| POST | EndpointConstants.REGISTER_DEVICE_PORTAL | PortalApi.kt |

## TimeOff

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.TIMEOFF | TimeOffApi.kt |
| GET | EndpointConstants.TIMEOFF/{id} | TimeOffApi.kt |
| GET | EndpointConstants.TIMEOFF/delegation/{id} | TimeOffApi.kt |
| POST | EndpointConstants.CANCEL_REQUEST | TimeOffApi.kt |
| GET | EndpointConstants.TIME_OFF_TAKEN_LIST/{policyId} | TimeOffApi.kt |
| GET | EndpointConstants.BALANCE_DETAIL_TIMEOFF | TimeOffApi.kt |
| GET | EndpointConstants.TIME_OFF_REQUEST | TimeOffApi.kt |
| POST | EndpointConstants.TIME_OFF_REQUEST | TimeOffApi.kt |
| GET | EndpointConstants.TIME_OFF_DELEGATION_LIST | TimeOffApi.kt |
| GET | EndpointConstants.CHECK_STATUS_MULTIPLE_SHIFT | TimeOffApi.kt |
| GET | EndpointConstants.REQUEST_SUBORDINATE_EMPLOYEE_LIST | TimeOffApi.kt |

## Overtime

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.OVERTIME | OvertimeApi.kt |
| GET | EndpointConstants.DATA_OVERTIME | OvertimeApi.kt |
| POST | EndpointConstants.OVERTIME_REQUEST | OvertimeApi.kt |
| GET | EndpointConstants.OVERTIME/{id} | OvertimeApi.kt |
| POST | EndpointConstants.CANCEL_REQUEST | OvertimeApi.kt |
| GET | companies/{companyId}/overtime_planning_users | OvertimeApi.kt |
| GET | companies/{companyId}/overtime_planning_users/{id} | OvertimeApi.kt |
| POST | companies/{companyId}/overtime_planning_users/{id}/reject | OvertimeApi.kt |

## Shift

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.HISTORY_REQUEST_SHIFT | ShiftApi.kt |
| GET | EndpointConstants.HISTORY_REQUEST_SHIFT/{id} | ShiftApi.kt |
| POST | EndpointConstants.CANCEL_REQUEST | ShiftApi.kt |
| GET | EndpointConstants.SHIFT_LIST | ShiftApi.kt |
| GET | EndpointConstants.SHIFT_REQUEST | ShiftApi.kt |
| POST | EndpointConstants.SHIFT_REQUEST | ShiftApi.kt |

## Task

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.TASK_DETAIL/{id} | TaskApi.kt |
| GET | EndpointConstants.TASK_LIST | TaskApi.kt |
| POST | EndpointConstants.CHANGE_TASK_STATUS/{id} | TaskApi.kt |
| DELETE | EndpointConstants.DELETE_TASK/{id} | TaskApi.kt |
| GET | EndpointConstants.TASK_ACTION | TaskApi.kt |
| POST | EndpointConstants.TASK_DETAIL/{id} | TaskApi.kt |
| PUT | EndpointConstants.TASK_DETAIL/{id} | TaskApi.kt |
| POST | EndpointConstants.DELETE_TASK_ACTIVITY/{id} | TaskApi.kt |
| GET | EndpointConstants.ASSIGNEE_LIST/{id} | TaskApi.kt |
| GET | EndpointConstants.ASSIGNEE_LIST | TaskApi.kt |
| PUT | EndpointConstants.TASK/{id}/notification | TaskApi.kt |

## Project

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.PROJECT | ProjectApi.kt |
| POST | EndpointConstants.PROJECT | ProjectApi.kt |
| PUT | EndpointConstants.EDIT_PROJECT | ProjectApi.kt |
| GET | EndpointConstants.PROJECT_DETAIL/{id} | ProjectApi.kt |
| PUT | EndpointConstants.PROJECT_SET_ARCHIVE | ProjectApi.kt |
| PUT | EndpointConstants.PROJECT_SET_ACTIVE | ProjectApi.kt |
| GET | EndpointConstants.PROJECT_MEMBER | ProjectApi.kt |
| POST | EndpointConstants.PROJECT_MEMBER | ProjectApi.kt |
| PUT | EndpointConstants.PROJECT_MEMBER | ProjectApi.kt |

## Employee

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.EMPLOYEE/{id} | EmployeeApi.kt |
| GET | EndpointConstants.ATTENDANCE_LOG_DETAILS | EmployeeApi.kt |
| GET | EndpointConstants.EMPLOYEE_LEAVE_TODAY | EmployeeApi.kt |
| GET | EndpointConstants.EMPLOYEE | EmployeeApi.kt |
| GET | EndpointConstants.BRANCH | EmployeeApi.kt |
| GET | EndpointConstants.ORGANIZATION | EmployeeApi.kt |
| GET | EndpointConstants.EMPLOYEE_LEAVE_TODAY/{id} | EmployeeApi.kt |

## User

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.DASHBOARD_USER | UserApi.kt |

## Dashboard

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.TIME_OFF_POLICY | DashboardApi.kt |
| GET | EndpointConstants.DASHBOARD_ANNOUNCEMENTS | DashboardApi.kt |
| GET | EndpointConstants.DASHBOARD_ICONS | DashboardApi.kt |
| GET | EndpointConstants.FLEX_B2C_STATUS | DashboardApi.kt |
| GET | EndpointConstants.MOBILE_CONFIG | DashboardApi.kt |

## Inbox

| Method | Path | File |
|---|---|---|
| PATCH | EndpointConstants.INBOX_MARK_ALL_READ_NOTIFICATIONS | InboxApi.kt |
| GET | EndpointConstants.APPROVAL_INBOX_DETAIL/{id} | InboxApi.kt |
| GET | EndpointConstants.INBOX_DATA/{id} | InboxApi.kt |
| POST | EndpointConstants.APPROVAL_TIMESHEET_SINGLE | InboxApi.kt |
| GET | EndpointConstants.APPROVAL_OVERTIME_NOTIFICATION_COUNT | InboxApi.kt |
| GET | EndpointConstants.INBOX_NOTIFICATION_COUNT | InboxApi.kt |

## Reprimand

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.REPRIMAND | ReprimandApi.kt |
| GET | EndpointConstants.REPRIMAND/{reprimandId} | ReprimandApi.kt |
| GET | comment/reprimand_feedback/{reprimandId} | ReprimandApi.kt |
| POST | comment/reprimand_feedback/{reprimandId} | ReprimandApi.kt |
| PUT | comment/reprimand_feedback/{reprimandId}/{id} | ReprimandApi.kt |
| DELETE | comment/reprimand_feedback/{reprimandId}/{id} | ReprimandApi.kt |

## Reviews

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.PERFORMANCE_REVIEW_INFO | ReviewsApi.kt |
| POST | (dynamic URL) | ReviewsApi.kt |

## MyFiles

| Method | Path | File |
|---|---|---|
| DELETE | EndpointConstants.FILE_DELETE | MyFilesApi.kt |
| GET | EndpointConstants.MY_FILE | MyFilesApi.kt |
| GET | EndpointConstants.FILE | MyFilesApi.kt |
| POST | EndpointConstants.FILE | MyFilesApi.kt |
| POST | EndpointConstants.FILE_UPDATE/{id} | MyFilesApi.kt |

## Consultant

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.CONSULTANT_COMPANY_LIST | ConsultantApi.kt |
| POST | EndpointConstants.CONSULTANT_COMPANY_SELECTION | ConsultantApi.kt |

## CustomForm

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.ALL_CUSTOM_FORM | CustomFormApi.kt |
| GET | EndpointConstants.ALL_SUBMISSIONS | CustomFormApi.kt |
| GET | EndpointConstants.FORM_SUBMITTED_DETAIL | CustomFormApi.kt |
| GET | EndpointConstants.FORM_GENERATE_TOKEN | CustomFormApi.kt |
| DELETE | EndpointConstants.DELETE_FORM_SUBMISSION | CustomFormApi.kt |
| GET | form_submission/{formId}/form_question/{questionId}/form_employees | CustomFormApi.kt |

## Announcement

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.ANNOUNCEMENT | AnnouncementApi.kt |
| GET | EndpointConstants.ANNOUNCEMENT/{id} | AnnouncementApi.kt |
| GET | EndpointConstants.ANNOUNCEMENT/categories | AnnouncementApi.kt |

## LiveTracking

| Method | Path | File |
|---|---|---|
| GET | companies/{companyId}/users/{userId}/live_tracking_status | LiveTrackingApi.kt |
| GET | companies/{organizationId}/users/{userId}/live_attendance_tracking_waypoints | LiveTrackingApi.kt |
| GET | companies/{companyId}/users/{userId}/live_tracking_log_locations | LiveTrackingApi.kt |

## EducationInfo

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.WORKING_EXPERIENCE/{id} | EducationInfoApi.kt |
| POST | EndpointConstants.WORKING_EXPERIENCE | EducationInfoApi.kt |
| PUT | EndpointConstants.WORKING_EXPERIENCE/{id} | EducationInfoApi.kt |
| DELETE | EndpointConstants.WORKING_EXPERIENCE/{id} | EducationInfoApi.kt |
| POST | EndpointConstants.FORMAL_EDUCATION | EducationInfoApi.kt |
| PUT | EndpointConstants.FORMAL_EDUCATION/{id} | EducationInfoApi.kt |
| GET | EndpointConstants.FORMAL_EDUCATION/{id} | EducationInfoApi.kt |
| DELETE | EndpointConstants.FORMAL_EDUCATION/{id} | EducationInfoApi.kt |
| GET | EndpointConstants.INFORMAL_EDUCATION/{id} | EducationInfoApi.kt |
| DELETE | EndpointConstants.INFORMAL_EDUCATION/{id} | EducationInfoApi.kt |
| POST | EndpointConstants.INFORMAL_EDUCATION | EducationInfoApi.kt |
| PUT | EndpointConstants.INFORMAL_EDUCATION/{id} | EducationInfoApi.kt |
| GET | EndpointConstants.EDUCATION_INFO | EducationInfoApi.kt |
| GET | EndpointConstants.EDUCATION_LIST | EducationInfoApi.kt |

## TimeSheet

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.TIMESHEET_LIST | TimeSheetApi.kt |
| GET | EndpointConstants.TIMESHEET_LIST/{id} | TimeSheetApi.kt |
| POST | EndpointConstants.MANUAL_TIMER | TimeSheetApi.kt |
| PUT | EndpointConstants.MANUAL_TIMER | TimeSheetApi.kt |
| DELETE | EndpointConstants.TIMESHEET_LIST/{id} | TimeSheetApi.kt |
| POST | EndpointConstants.START_TIMER | TimeSheetApi.kt |
| PUT | EndpointConstants.STOP_TIMER | TimeSheetApi.kt |
| GET | EndpointConstants.TIME_TRACKER_TASK_LIST | TimeSheetApi.kt |
| GET | EndpointConstants.CHECK_TIMER | TimeSheetApi.kt |
| POST | EndpointConstants.TIMESHEET_LIST/{id}/cancel | TimeSheetApi.kt |
| GET | EndpointConstants.SHIFT_SELF | TimeSheetApi.kt |
| GET | EndpointConstants.SETTING_SELF | TimeSheetApi.kt |
| GET | EndpointConstants.LOCATION_SELF | TimeSheetApi.kt |
| GET | EndpointConstants.TIMESHEET_METRICS | TimeSheetApi.kt |

## BulkApproval

| Method | Path | File |
|---|---|---|
| POST | EndpointConstants.APPROVAL_ATTENDANCE_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_SHIFT_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_CHANGEDATA_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_FORM_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_TIME_OFF | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_REIMBURSEMENT_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_OVERTIME_PLANNING_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_OVERTIME_REQUEST_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_ADD_EMPLOYEE_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_EMPLOYEE_TRANSFER_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_TIMESHEET_TRANSFER_BULK | BulkApprovalApi.kt |
| POST | EndpointConstants.APPROVAL_TASK_BULK | BulkApprovalApi.kt |
| GET | EndpointConstants.APPROVAL_PROGRESS_BAR | BulkApprovalApi.kt |

## Subordinate

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.SUBORDINATES | SubordinateApi.kt |
| GET | EndpointConstants.SUBORDINATE_ACTIVITIES | SubordinateApi.kt |
| GET | EndpointConstants.SUBORDINATE_COUNT | SubordinateApi.kt |

## Onboarding

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.ONBOARDING_TASK_COUNTER | OnboardingApi.kt |
| GET | EndpointConstants.ONBOARDING_DETAIL | OnboardingApi.kt |
| GET | EndpointConstants.ONBOARDING_TASKS | OnboardingApi.kt |
| GET | EndpointConstants.ONBOARDING_FORMS | OnboardingApi.kt |
| POST | EndpointConstants.ONBOARDING_TASKS | OnboardingApi.kt |
| GET | EndpointConstants.ONBOARDING_DOCUMENTS | OnboardingApi.kt |
| GET | EndpointConstants.ONBOARDING_COLLEAGUES | OnboardingApi.kt |
| GET | EndpointConstants.ONBOARDING_WORK_LOCATION | OnboardingApi.kt |
| GET | EndpointConstants.ONBOARDING_DETAIL_PIC/{id} | OnboardingApi.kt |
| GET | EndpointConstants.ONBOARDING_TASKS_PIC/{id} | OnboardingApi.kt |

## MekariExpense

| Method | Path | File |
|---|---|---|
| GET | EndpointConstants.MEKARI_EXPENSE_TOKEN | MekariExpenseApi.kt |

## MekariCredit

| Method | Path | File |
|---|---|---|
| POST | EndpointConstants.MEKARI_REGISTER | MekariCreditApi.kt |

## Company

| Method | Path | File |
|---|---|---|
| GET | {MIXPANEL_URL}/mix_panel_company | CompanyApi.kt |

## IntegrityCheck

| Method | Path | File |
|---|---|---|
| GET | companies/{companyId}/integrity_status | IntegrityApi.kt |
| POST | companies/{companyId}/integrity_validate | IntegrityApi.kt |
| POST | companies/{companyId}/integrity_verify_action | IntegrityApi.kt |
