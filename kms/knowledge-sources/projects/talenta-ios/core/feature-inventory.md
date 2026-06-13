---
scope: project/talenta-ios
platform: ios
discipline: engineering
artifact: feature-inventory
---
# Feature Inventory

## Account

- module_path: Talenta/Controllers/Account/
- entry_point: AccountViewController (legacy Controllers layer)

## Announcement

- module_path: Talenta/Module/TalentaECM/
- entry_point: AnnouncementRemoteDataSource, AnnouncementViewModel (ECM module, Clean Architecture)

## Attendance

- module_path: Talenta/Module/TalentaTM/
- entry_point: AttendanceLogsCoordinator, AttendanceLogsViewModel
- sub-features: Attendance Logs, CICO (Check-In Check-Out), Live Attendance, Live Tracking, Break, Async Live Attendance, Attendance Shortcut, Attendance Shift, Request Attendance

## ChangeData

- module_path: Talenta/Controllers/ChangeData/
- entry_point: ChangeDataViewController (legacy Controllers layer)

## ChangeShift

- module_path: Talenta/Controllers/ChangeShift/
- entry_point: ChangeShiftViewController (legacy Controllers layer)

## Commerce

- module_path: Talenta/Controllers/Commerce/
- entry_point: CommerceViewController (legacy Controllers layer)

## CustomForm

- module_path: Talenta/Controllers/CustomForm/
- entry_point: CustomFormViewController (legacy Controllers layer)

## Dashboard

- module_path: Talenta/Module/TalentaDashboard/
- entry_point: DashboardViewModel (Clean Architecture module)
- sub-features: Announcements banner, Leave balance, Tour/Onboarding Tour, Menu config

## DirectReport

- module_path: Talenta/Controllers/DirectReport/
- entry_point: DirectReportViewController (legacy Controllers layer)

## EducationInfo

- module_path: Talenta/Controllers/EducationInfo/
- entry_point: EducationInfoViewController (legacy Controllers layer)

## Employee

- module_path: Talenta/Controllers/Employee/
- entry_point: EmployeeViewController (legacy Controllers layer)

## FamilyInfo

- module_path: Talenta/Controllers/FamilyInfo/
- entry_point: FamilyInfoViewController (legacy Controllers layer)

## Frontdesk

- module_path: Talenta/Controllers/Frontdesk/
- entry_point: FrontdeskViewController (legacy Controllers layer)

## GiveUsFeedback

- module_path: Talenta/Controllers/GiveUsFeedback/
- entry_point: GiveUsFeedbackViewController (legacy Controllers layer)

## Goals

- module_path: Talenta/Controllers/Goals/
- entry_point: GoalsViewController (legacy Controllers layer)

## Home

- module_path: Talenta/Controllers/Home/
- entry_point: HomeViewController (legacy Controllers layer)

## Inbox

- module_path: Talenta/Module/TalentaInbox/
- entry_point: InboxApprovalListViewModel, InboxApprovalBulkViewModel (Clean Architecture module)
- sub-features: Bulk approval (TimeOff, Reimbursement, Attendance, Shift, Custom Form, Overtime), Goal inbox, Reimbursement inbox

## Insight

- module_path: Talenta/Controllers/Insight/
- entry_point: InsightViewController (legacy Controllers layer)

## Login

- module_path: Talenta/Controllers/Login/
- entry_point: LoginViewModel (Talenta/ViewModels/LoginViewModel.swift)
- sub-features: SSO login, OTP Security

## Mekari Benefit

- module_path: Talenta/Controllers/Mekari Benefit/
- entry_point: MekariBenefitViewController (legacy Controllers layer)

## MyFile

- module_path: Talenta/Module/TalentaECM/
- entry_point: MyFilesRemoteDataSource (ECM module, Clean Architecture)

## OnboardingTour

- module_path: Talenta/Controllers/OnboardingTour/
- entry_point: OnboardingTourViewController (legacy Controllers layer)

## Onboarding

- module_path: Talenta/Controllers/Onboarding/
- entry_point: OnboardingViewController (legacy Controllers layer)

## OrganizationChart

- module_path: Talenta/Controllers/OrganizationChart/
- entry_point: OrganizationChartViewController (legacy Controllers layer)

## Overtime

- module_path: Talenta/Module/TalentaTM/
- entry_point: DetailOvertimeRequestCoordinator, RequestOvertimeFormCoordinator (TalentaTM Clean Architecture module)

## Payslip

- module_path: Talenta/Module/TalentaPayslip/
- entry_point: PayslipCoordinator (Clean Architecture module)

## PIN

- module_path: Talenta/Controllers/PIN/
- entry_point: PINViewController (legacy Controllers layer)

## Reimbursement

- module_path: Talenta/Controllers/Reimbursement/
- entry_point: ReimbursementViewController (legacy Controllers layer)

## Reprimand

- module_path: Talenta/Controllers/Reprimand/
- entry_point: ReprimandViewController (legacy Controllers layer)

## Reviews

- module_path: Talenta/Controllers/Reviews/
- entry_point: ReviewsViewController (legacy Controllers layer)

## Settings

- module_path: Talenta/Controllers/Settings/
- entry_point: SettingsViewController (legacy Controllers layer)

## Task

- module_path: Talenta/Controllers/Task/
- entry_point: TaskViewController (legacy Controllers layer)

## TimeOff

- module_path: Talenta/Module/TalentaTM/
- entry_point: TalentaTM module, TimeOff UseCase layer (Clean Architecture)

## TimeSheet

- module_path: Talenta/Controllers/TimeSheet/
- entry_point: TimeSheetViewController (legacy Controllers layer)

## Walkthrough

- module_path: Talenta/Controllers/Walkthrough/
- entry_point: WalkthroughViewController (legacy Controllers layer)

## BrickWrap-Account

- module_path: Talenta/BrickWrap/Modules/Account/
- entry_point: Flutter module bridge for Account (BricksEngineManager + FlutterEngine)

## BrickWrap-Auth

- module_path: Talenta/BrickWrap/Modules/Auth/
- entry_point: Flutter module bridge for Auth

## BrickWrap-Calendar

- module_path: Talenta/BrickWrap/Modules/Calendar/
- entry_point: Flutter module bridge for Calendar

## BrickWrap-Cashout

- module_path: Talenta/BrickWrap/Modules/Cashout/
- entry_point: Flutter module bridge for MekariFlex Cashout

## BrickWrap-Exm

- module_path: Talenta/BrickWrap/Modules/Exm/
- entry_point: Flutter module bridge for Expense Management

## BrickWrap-Inbox

- module_path: Talenta/BrickWrap/Modules/Inbox/
- entry_point: Flutter module bridge for Inbox

## BrickWrap-Payslip

- module_path: Talenta/BrickWrap/Modules/Payslip/
- entry_point: Flutter module bridge for Payslip

## BrickWrap-Performance

- module_path: Talenta/BrickWrap/Modules/Performance/
- entry_point: Flutter module bridge for Performance/Reviews

## BrickWrap-Task

- module_path: Talenta/BrickWrap/Modules/Task/
- entry_point: Flutter module bridge for Task

## BrickWrap-TimeManagement

- module_path: Talenta/BrickWrap/Modules/TimeManagement/
- entry_point: Flutter module bridge for Time Management
