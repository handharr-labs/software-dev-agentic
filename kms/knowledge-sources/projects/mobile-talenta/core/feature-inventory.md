---
scope: project/mobile-talenta
platform: flutter
discipline: engineering
artifact: feature-inventory
---
# Feature Inventory

Platform: Flutter | Module package: `talenta_module` (path: `talenta/`) | Root app: `talenta`

## App Structure

The app is structured as a Melos mono-repo with two packages: the root host app (`talenta`) and the feature module (`talenta_module`). Features are isolated into `BaseModule` implementations and loaded by the host via a Brick-Way routing protocol.

---

## Feature: Authentication

- **Module**: Root app (`lib/src/`)
- **Description**: Legacy username/password login and SSO authentication. Stores auth token in secure storage (`flutter_secure_storage`). Manages session via `AuthTokenRepository`.
- **Screens**: `LoginScreen`, `HomeScreen`
- **BLoCs**: `LoginBloc`, `LogoutBloc`, `GetUserInfoBloc`
- **Key use-cases**: `LoginUseCase`, `LogoutUseCase`, `GetUserInfoUseCase`
- **Status**: Fully implemented

---

## Feature: Time Management (`talenta_tm`)

- **Module**: `TmModule`
- **Base route**: `/tm`
- **Description**: Core HR time-tracking feature. Covers attendance, time-off, overtime, shift management, live location tracking, segmented tracking via MQTT, attendance summaries, and calendar.
- **Sub-features**:
  - **Calendar**: Monthly calendar with attendance events, holidays, activity log
  - **Attendance Clocks**: Clock-in/out with GPS address lookup, clock status
  - **Attendance Log**: History log with metrics, filtering, search by subordinate
  - **Attendance Summary**: Aggregated summary per employee with metrics dashboard
  - **Attendance Request**: Submit manual attendance correction
  - **Time Off**: My requests, team time-off, balance overview, delegation, request submission
  - **Overtime**: Personal overtime request and history, team overtime approval, pending overtime
  - **Shift Request**: Request shift change, view shift list, shift change detail
  - **Live Location Tracking**: Real-time GPS waypoint logging via background geolocation
  - **Segmented Tracking**: Tracking segments and summary from live tracking data
  - **Birthdays**: Employee birthday listing and greeting message
  - **Monthly Events**: Calendar event view per month
  - **Timezones**: Fetch available timezones
- **Screens (representative)**: `CalendarScreen`, `AttendanceLogScreen`, `AttendanceSummaryScreen`, `TimeOffScreen`, `TeamTimeOffScreen`, `RequestTimeOffScreen`, `TimeOffBalancesScreen`, `OvertimeIndexScreen`, `OvertimeDetailScreen`, `ShiftIndexScreen`, `RequestShiftScreen`, `ShiftChangeDetailScreen`, `SegmentedTrackingScreen`, `LocationDetailsScreen`, `BirthdayDetailsScreen`, `RequestAttendanceScreen`, `MonthlyEventScreen`, `TeamOvertimeIndexScreen`
- **Status**: Fully implemented, most complex feature in the app

---

## Feature: Inbox / Approval (`talenta_inbox`)

- **Module**: `InboxModule`
- **Base route**: `/inbox`
- **Description**: Approval inbox for managers. Displays pending approval items and allows approve/reject actions. Supports all request types: overtime, time-off, attendance, change shift, change data, live attendance, custom form, employee transfer, add employee, reimbursement, goals.
- **Sub-features**:
  - **Index**: Paginated inbox list
  - **Inbox Details**: Detail view per request type with type-specific content sections
  - **Post Approval**: Approve/reject action with note
  - **Custom Form**: Employee list selection, submission edit history
  - **File Download**: Download attachments from inbox
  - **Edit History**: View submission edit history
- **Screens**: `IndexInboxScreen`, `InboxDetailsScreen`, `EditHistoryScreen`
- **Supported inbox types**: `overtime`, `overtimePlanning`, `timeOff`, `attendance`, `liveAttendance`, `changeShift`, `changeData`, `task`, `employeeTransfer`, `addEmployee`, `customForm`, `reimbursement`, `goals`, `editGoals`, `updateGoalProgress`, `notification`
- **Status**: Fully implemented

---

## Feature: Payslip (`talenta_payslip`)

- **Module**: `PayslipModule`
- **Base route**: `/payslip`
- **Description**: View payslip with OTP/PIN auth protection. Supports v1 (period list) and v3 (new format) payslip. Download options for 1721-A1, 1721-VI, 1721-VII, 1721-VIII forms and THR slips. Includes payroll service micro-service variant.
- **Sub-features**:
  - **Payslip View**: Period selector, payslip detail with OTP challenge
  - **Payslip Download**: Multiple tax form download endpoints
  - **Reimbursement Index**: List of submitted reimbursement requests with pagination
  - **Request Reimbursement**: Submit reimbursement with attachments, beneficiary selection, benefit formula preview
  - **Reimbursement Detail**: Detail view of a specific reimbursement request
- **Screens**: `PayslipScreen`, `ReimbursementIndexScreen`, `RequestReimbursementScreen`, `RequestReimbursementDetailScreen`
- **Status**: Fully implemented

---

## Feature: Account / Profile (`talenta_account`)

- **Module**: `AccountModule`
- **Base route**: `/account`
- **Description**: Employee self-service profile and company information. Covers personal info, employment info, family info, emergency contacts, payroll info, asset management, announcements, additional info (custom fields), change data requests, LMS, FAQ, help center, privacy policy, change password.
- **Sub-features**:
  - **Personal Info**: View employee personal data
  - **Employment Info**: View employment details
  - **Payroll Info**: View payroll-related information
  - **Family Info**: View and manage family members
  - **Emergency Contact**: Create, edit, delete emergency contacts
  - **Change Data**: Request personal data change with OTP challenge, history, cancellation
  - **Bank Account**: Add/select bank account with verification
  - **Asset Management**: View assigned assets and asset detail
  - **Announcements**: Browse and view company announcements
  - **Additional Info**: View and edit custom fields
  - **LMS**: WebView to Learning Management System
  - **FAQ / Help Center / Privacy Policy**: Remote-config-driven WebView screens
  - **Change Password**: SSO redirect to change password
- **Screens**: `PersonalInfoScreen`, `EmploymentInfoScreen`, `PayrollInfoScreen`, `FamilyInfoScreen`, `FamilyInfoDetailsScreen`, `EmergencyContactScreen`, `CreateEmergencyContactScreen`, `ChangeDataIndexScreen`, `ChangeDataDetailsScreen`, `RequestChangeDataScreen`, `SelectBankScreen`, `AddBankScreen`, `AssetManagementIndexScreen`, `AssetManagementDetailScreen`, `AnnouncementListScreen`, `AnnouncementDetailScreen`, `AdditionalInfoScreen`, `AdditionalInfoEditScreen`, `LmsScreen`, `FaqScreen`, `HelpCenterScreen`, `PrivacyPolicyScreen`, `ChangePasswordScreen`
- **Status**: Fully implemented

---

## Feature: Performance (`talenta_performance`)

- **Module**: `PerformanceModule`
- **Base route**: `/performance`
- **Description**: Performance management dashboard. Shows pending performance tasks, latest performance goals with progress, and provides a WebView redirect into the full performance review portal. Badge visibility driven by API response.
- **Sub-features**:
  - **Performance Home**: Summary card with tasks and goals sections
  - **Performance WebView**: Full performance review portal embedded in WebView
  - **Performance Account**: Tie into account-level display
- **Screens**: `PerformanceHomeScreen`, `PerformanceWebviewScreen`, `PerformanceAccountScreen`
- **Status**: Fully implemented

---

## Feature: Task & Timesheet (`talenta_tnt`)

- **Module**: `TntModule`
- **Base route**: `/tnt`
- **Description**: Create and manage company tasks with timesheet tracking. Supports project browsing, task creation/editing with attachments, assignee selection, and optional approval workflow.
- **Sub-features**:
  - **Project Index**: Browse and search projects
  - **Project Detail**: View project members and task progress
  - **Create Task**: Form to create a task with assignees, due date, attachments, unit tracking
  - **Edit Task**: Edit existing task with old file management
  - **Select Assignee**: Employee picker
  - **Select Project**: Project picker
  - **Archive Project**: Toggle archive status
  - **Timesheet Approval Setting**: Check if approval is required before task creation
- **Screens**: `ProjectIndexScreen`, `ProjectDetailScreen`, `CreateTaskScreen`, `SelectAssigneeScreen`, `SelectProjectScreen`
- **Status**: Fully implemented

---

## Feature: Officeless (`talenta_officeless`)

- **Module**: `OfficelessModule`
- **Base route**: `/officeless`
- **Description**: BPJS portal WebView integration. Minimal native implementation — renders a WebView at a configured URL/path passed by the host app via JSON handshake. No dedicated API calls in the data source stub.
- **Screens**: `BpjsPortalScreen`
- **Status**: Stub/minimal — `OfficelessRemoteDataSource` is empty; routing and host JSON parsing are in place

---

## Brick-Way Integration

All features expose their entry points via the `BaseModule` interface. The host app navigates using `brick://` scheme URIs with `page://`, `bottom-sheet://`, `dialog://`, and `service://` variants. Module initialization is triggered on first navigation to a module route.
