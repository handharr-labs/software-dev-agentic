# API Endpoints — ios-talenta

## Auth

| Method | Path | File |
|---|---|---|
| POST | login | Interface+Auth.swift |
| POST | logout | Interface+Auth.swift |
| POST | verify-password | Interface+Auth.swift |
| POST | sso-login | Interface+Auth.swift |
| POST | sso-change-password | Interface+Auth.swift |

## Dashboard

| Method | Path | File |
|---|---|---|
| GET | toggle | Interface+Dashboard.swift |
| GET | dashboard/user | Interface+Dashboard.swift |
| GET | dashboard/announcements | Interface+Dashboard.swift |
| GET | dashboard/time-off-policy | Interface+Dashboard.swift |
| GET | subordinates | Interface+Dashboard.swift |
| GET | expense-management/token | Interface+Dashboard.swift |
| GET | health_checks | Interface+Dashboard.swift |
| GET | onboarding/task-counter | Interface+Dashboard.swift |
| GET | mekari-flex/b2c/status | Interface+Dashboard.swift |
| GET | ems/mobile-config | Interface+Dashboard.swift |
| GET | dashboard/reviews | Interface+Reviews.swift |
| POST | auths/encrypt | Interface+Reviews.swift |

## Attendance

| Method | Path | File |
|---|---|---|
| GET | attendance/history/detail | Interface+Attendance.swift |
| GET | attendance/history/ | Interface+Attendance.swift |
| GET | history-request/change-shift | Interface+Attendance.swift |
| GET | history-request/change-shift/:id | Interface+Attendance.swift |
| POST | cancel-request | Interface+Attendance.swift |
| GET | v1/history-request/attendance | Interface+Attendance.swift |
| GET | v2/attendance/companies/:companyId/summary_attendance_clocks | Interface+Attendance.swift |
| GET | my-info/attendance-log/detail | Interface+Attendance.swift |
| GET | maintenance/token | Interface+Attendance.swift |
| GET | live-attendance/history-list | Interface+Attendance.swift |
| GET | live-attendance/server-time | Interface+Attendance.swift |
| GET | attendance/timezone | Interface+Attendance.swift |
| GET | live-attendance/address/:id | Interface+Attendance.swift |
| GET | attendance/companies/:companyId/locations/search | Interface+Attendance.swift |
| GET | attendance/companies/:companyId/locations/live_attendance | Interface+Attendance.swift |
| POST | v1/attendance-request | Interface+Attendance.swift |
| GET | v2/attendance-request | Interface+Attendance.swift |
| GET | live-attendance | Interface+Attendance.swift |
| POST | attendance/companies/:companyId/attendance_clocks | Interface+Attendance.swift |
| GET | attendance/companies/:companyId/attendance_schedules/active | Interface+Attendance.swift |
| GET | v2/organisations/:companyId/summary_attendance_clocks | Interface+Attendance.swift |
| POST | v2/attendance/organisations/:companyId/attendance_clocks/sync | Interface+Attendance.swift |
| POST | live-attendance/send-approval | Interface+Attendance.swift |
| POST | v2/attendance/companies/:companyId/attendance_clocks/validate_location | Interface+Attendance.swift |
| POST | v3/attendance/organisations/:companyId/attendance_clocks | Interface+Attendance.swift |
| GET | v2/attendance/organisations/:companyId/summary_attendance_clocks/metrics_agg | Interface+Attendance.swift |
| GET | v2/attendance/organisations/:companyId/summary_attendance_clocks/metrics | Interface+Attendance.swift |
| GET | attendance/organisations/:companyId/attendance_clocks/status | Interface+Attendance.swift |
| POST | v2/attendance/organisations/:companyId/attendance_clocks/enroll_profile | Interface+Attendance.swift |
| GET | companies/:companyId/users/:userId/live-tracking-log-locations | Interface+Attendance.swift |
| GET | companies/:companyId/users/:userId/live-tracking-status | Interface+Attendance.swift |
| GET | v1/attendance/organisations/:organisationId/on_call_plannings | Interface+Attendance.swift |

## TimeOff

| Method | Path | File |
|---|---|---|
| GET | time-off-request | Interface+TimeOff.swift |
| POST | cancel-request | Interface+TimeOff.swift |
| GET | history-request/timeoff | Interface+TimeOff.swift |
| GET | time-off-request/delegation-list | Interface+TimeOff.swift |
| GET | history-request/timeoff/:id | Interface+TimeOff.swift |
| GET | history-request/timeoff/delegation/:id | Interface+TimeOff.swift |
| GET | time-off/balance-detail | Interface+TimeOff.swift |
| GET | time-off/taken-list/:policyCode | Interface+TimeOff.swift |
| POST | time-off-request | Interface+TimeOff.swift |
| GET | multiple-shift/check-status | Interface+TimeOff.swift |
| GET | attendance/schedule | Interface+TimeOff.swift |
| GET | time-off-info | Interface+TimeOff.swift |
| GET | request/employee-list | Interface+TimeOff.swift |

## Overtime

| Method | Path | File |
|---|---|---|
| GET | history-request/overtime/:id | Interface+Overtime.swift |
| GET | v2/overtime-request | Interface+Overtime.swift |
| POST | overtime-request | Interface+Overtime.swift |
| GET | history-request/overtime | Interface+Overtime.swift |
| POST | cancel-request | Interface+Overtime.swift |
| POST | approval-request/bulk-overtime | Interface+Overtime.swift |
| GET | companies/:companyId/overtime-plannings/users | Interface+Overtime.swift |
| GET | companies/:companyId/overtime-plannings/users/:id | Interface+Overtime.swift |
| POST | companies/:compId/overtime-plannings/users/:id/reject | Interface+Overtime.swift |

## Timesheet

| Method | Path | File |
|---|---|---|
| POST | time-sheet/update-task-status/:id | Interface+Timesheet.swift |
| GET | time-sheet/get-list-task | Interface+Timesheet.swift |
| GET | time-sheet | Interface+Timesheet.swift |
| DELETE | time-sheet/:timesheetId | Interface+Timesheet.swift |
| POST | time-sheet/:timesheetId/cancel | Interface+Timesheet.swift |
| GET | time-sheet/time-tracker-task-list | Interface+Timesheet.swift |
| POST | time-sheet/manual-timer | Interface+Timesheet.swift |
| POST | time-sheet/start-timer | Interface+Timesheet.swift |
| POST | time-sheet/stop-timer | Interface+Timesheet.swift |
| GET | time-sheet/check-timer | Interface+Timesheet.swift |
| GET | time-sheet/:taskId | Interface+Timesheet.swift |
| GET | time-sheet/setting/self | Interface+Timesheet.swift |
| GET | time-sheet/shift/self | Interface+Timesheet.swift |
| GET | time-sheet/list-location/self | Interface+Timesheet.swift |
| GET | v2/time-sheet/metrics | Interface+Timesheet.swift |

## Task

| Method | Path | File |
|---|---|---|
| POST | time-sheet/task-detail/:taskId | Interface+Task.swift |
| DELETE | time-sheet/delete-task/:taskId | Interface+Task.swift |
| GET | time-sheet/task-activity | Interface+Task.swift |
| GET | time-sheet/task-detail/:id | Interface+Task.swift |

## Reimbursement

| Method | Path | File |
|---|---|---|
| GET | reimbursement-active-policy | Interface+Reimbursement.swift |
| POST | reimbursement-request/paid-amount | Interface+Reimbursement.swift |
| GET | history-request/reimbursement | Interface+Reimbursement.swift |
| GET | history-request/reimbursement/:id | Interface+Reimbursement.swift |
| GET | reimbursement-request | Interface+Reimbursement.swift |
| POST | reimbursement-request | Interface+Reimbursement.swift |

## Inbox

| Method | Path | File |
|---|---|---|
| GET | consultant/company | Interface+Inbox.swift |
| POST | consultant/company/select | Interface+Inbox.swift |
| GET | inbox-detail/:inboxId | Interface+Inbox.swift |
| POST | approval-request/:detailType | Interface+Inbox.swift |
| POST | approval-request/change-data-bulk | Interface+Inbox.swift |
| POST | approval-request/change-shift-bulk | Interface+Inbox.swift |
| POST | approval-request/attendance-bulk | Interface+Inbox.swift |
| POST | approval-request/bulk-reimbursement | Interface+Inbox.swift |
| POST | approval/custom-form-bulk | Interface+Inbox.swift |
| POST | approval-request/bulk-overtime | Interface+Inbox.swift |
| GET | inbox/:notificationType | Interface+Inbox.swift |
| GET | inbox/overtime-info | Interface+Inbox.swift |
| GET | progress-bar | Interface+Inbox.swift |
| POST | inbox-notification/mark-all-read | Interface+Notification.swift |

## CustomForm

| Method | Path | File |
|---|---|---|
| GET | custom-form/all-form | Interface+CustomForm.swift |
| GET | custom-form-submissions/all | Interface+CustomForm.swift |
| GET | custom-form-submissions/detail | Interface+CustomForm.swift |
| GET | custom-form/generate-identity-token | Interface+CustomForm.swift |
| DELETE | custom-form-submissions/delete | Interface+CustomForm.swift |
| GET | inbox-detail/:id | Interface+CustomForm.swift |
| POST | approval-request/custom-form | Interface+CustomForm.swift |

## ChangeData

| Method | Path | File |
|---|---|---|
| POST | personal-data-request | Interface+ChangeData.swift |
| GET | personal-data-request | Interface+ChangeData.swift |
| GET | history-request/change-data | Interface+ChangeData.swift |
| GET | history-request/change-data/:id | Interface+ChangeData.swift |
| POST | cancel-request | Interface+ChangeData.swift |

## ChangeShift

| Method | Path | File |
|---|---|---|
| GET | v2/shift-request | Interface+ChangeShift.swift |
| GET | shift-list | Interface+ChangeShift.swift |
| POST | shift-request | Interface+ChangeShift.swift |

## Employees

| Method | Path | File |
|---|---|---|
| GET | employees | Interface+EmployeesList.swift |
| GET | employees/:id | Interface+EmployeesList.swift |
| GET | employees/on-leave-today | Interface+EmployeesList.swift |
| GET | time-off-requests/:timeOffRequestId | Interface+EmployeesList.swift |

## OrgChart

| Method | Path | File |
|---|---|---|
| GET | employee/organization-chart | Interface+OrgChart.swift |
| GET | employee/organization-chart/:userId/childrens | Interface+OrgChart.swift |
| GET | employee/organization-chart/:userId/parents | Interface+OrgChart.swift |
| GET | employee/organization-chart/filter-component | Interface+OrgChart.swift |
| GET | employee/organization-chart/search | Interface+OrgChart.swift |

## Onboarding

| Method | Path | File |
|---|---|---|
| GET | onboarding/detail | Interface+Onboarding.swift |
| GET | onboarding/tasks | Interface+Onboarding.swift |
| POST | onboarding/tasks | Interface+Onboarding.swift |
| GET | onboarding/documents | Interface+Onboarding.swift |
| GET | onboarding/forms | Interface+Onboarding.swift |
| GET | onboarding/colleagues | Interface+Onboarding.swift |
| GET | onboarding/work-locations | Interface+Onboarding.swift |
| GET | onboarding/detail-pic/:onboardingId | Interface+Onboarding.swift |
| GET | onboarding/tasks-pic/:onboardingId | Interface+Onboarding.swift |

## Reprimand

| Method | Path | File |
|---|---|---|
| GET | reprimand | Interface+Reprimand.swift |
| GET | reprimand/:id | Interface+Reprimand.swift |
| GET | comment/reprimand-feedback/:id | Interface+Reprimand.swift |
| POST | comment/reprimand-feedback/:id | Interface+Reprimand.swift |
| PUT | comment/reprimand-feedback/:reprimandId/:feedbackId | Interface+Reprimand.swift |
| DELETE | comment/reprimand-feedback/:reprimandId/:feedbackId | Interface+Reprimand.swift |

## EducationInfo

| Method | Path | File |
|---|---|---|
| GET | my-info/list-education | Interface+EducationInfo.swift |
| GET | employees/personal/formal-education/:id | Interface+EducationInfo.swift |
| POST | employees/personal/formal-education | Interface+EducationInfo.swift |
| PUT | employees/personal/formal-education/:id | Interface+EducationInfo.swift |
| DELETE | employees/personal/formal-education/:id | Interface+EducationInfo.swift |
| GET | employees/personal/informal-education/:id | Interface+EducationInfo.swift |
| POST | employees/personal/informal-education | Interface+EducationInfo.swift |
| PUT | employees/personal/informal-education/:id | Interface+EducationInfo.swift |
| DELETE | employees/personal/informal-education/:id | Interface+EducationInfo.swift |

## WorkExperience

| Method | Path | File |
|---|---|---|
| GET | employees/personal/working-experience/:id | Interface+WorkExperience.swift |
| POST | employees/personal/working-experience/create | Interface+WorkExperience.swift |
| PUT | employees/personal/working-experience/:id | Interface+WorkExperience.swift |
| DELETE | employees/personal/working-experience/:id | Interface+WorkExperience.swift |

## Subordinate

| Method | Path | File |
|---|---|---|
| GET | subordinate/activities | Interface+Subordinate.swift |
| GET | attendance/companies/:companyId/attendance_clocks/:id | Interface+Subordinate.swift |
| GET | live-attendance/detail | Interface+Subordinate.swift |
| GET | subordinate/activities-count | Interface+Subordinate.swift |
| GET | subordinates | Interface+Subordinate.swift |

## Payroll

| Method | Path | File |
|---|---|---|
| GET | my-info/payroll-info | Interface+PayrollInfo.swift |

## Calendar

| Method | Path | File |
|---|---|---|
| GET | calendar | Interface+Calendar.swift |

## Insights

| Method | Path | File |
|---|---|---|
| GET | v1.1/users/me/current_company | Interface+Insights.swift |

## Announcement (ECM)

| Method | Path | File |
|---|---|---|
| GET | announcement | AnnouncementAPIService.swift |
| GET | announcements/:id | Interface+Announcement.swift |
| GET | announcement-categories | Interface+Announcement.swift |

## MyFile (ECM)

| Method | Path | File |
|---|---|---|
| GET | my-info/my-file | MyFilesRemoteDataSource.swift |
| GET | file | MyFilesRemoteDataSource.swift |
| DELETE | files/delete | MyFilesRemoteDataSource.swift |
