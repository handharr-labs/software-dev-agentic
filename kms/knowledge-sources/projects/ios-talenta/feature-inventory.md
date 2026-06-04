# Feature Inventory — ios-talenta

Platform: iOS (Swift/UIKit)
Source: /Users/puras.handharmahuamekari.com/Workspace/talenta-ios
Scanned: 2026-06-04

## Features

| # | Feature | Module/Path | Notes |
|---|---------|-------------|-------|
| 1 | Authentication (Login / Logout) | `Talenta/Controllers/Login`, `Services/UserService/AuthService.swift` | SSO + OAuth2 with PKCE; MekariOAuth2; Kong API gateway client IDs per env |
| 2 | PIN Security | `Controllers/PIN/` | PIN input with biometric fallback; PIN-required-on-open setting |
| 3 | Biometric Auth | `Shared/Domain/Service/BiometricAuthService.swift` | Touch ID / Face ID via `BiometricAuthentication` pod |
| 4 | OTP Phone Verification | `Controllers/OTP Security/` | Enter code, verify phone number, search phone code |
| 5 | Dashboard (Home) | `Module/TalentaDashboard/` | Greeting, schedule card, menu section, announcements, direct reports, banners, shortcuts, onboarding menu |
| 6 | Announcements | `Controllers/Announcement/`, `Module/TalentaECM/` | List, detail, search, filter by category, download attachments; Clean-Arch module (TalentaECM) + legacy controllers |
| 7 | Live Attendance (CICO) | `Module/TalentaTM/`, `Controllers/Attendance/` | Check-in / check-out with GPS, selfie camera, async mode, multi-shift support; also as iOS widget extension |
| 8 | Attendance Request | `Module/TalentaTM/`, `Controllers/Attendance/RequestAttendance/` | Request attendance correction with history list |
| 9 | Attendance Log Sheet | `Module/TalentaTM/Utils/Legacy/` | View/download attendance log |
| 10 | Time Off Request | `Controllers/TimeOff/` | Request, bulk request, hourly leave, delegation selection, multi-shift check |
| 11 | Time Off History | `Controllers/TimeOff/TimeOffHistory/` | Request tab, overlapping bulk approval |
| 12 | Overtime Request | `Controllers/Overtime/`, `Module/TalentaTM/` | Request, planning/tab view, claim |
| 13 | Overtime History | `Controllers/Overtime/OvertimeHistory/` | List with status/date filters |
| 14 | Overtime Approval (Inbox) | `Controllers/Inbox/`, `Controllers/Overtime/Notification/` | Detail notification with approve/reject |
| 15 | Change Shift | `Controllers/ChangeShift/` | Request shift change, choose new shift, detail notification |
| 16 | Timesheet | `Controllers/TimeSheet/` | Index list and detail view |
| 17 | Task Management | `Controllers/Task/` | Task list, detail, create, edit; projects, members, completed tasks |
| 18 | Inbox / Approval | `Controllers/Inbox/` | Generic approval list/detail, notification detail, approve-all, consultant filter |
| 19 | Direct Report / Subordinate Activity | `Controllers/DirectReport/` | 1st and 2nd layer subordinate views, floating panel, attendance log cells |
| 20 | Organization Chart | `Controllers/OrganizationChart/` | Tree view, employee info, SBU filter, search |
| 21 | Employee Directory | `Controllers/Employee/` | List, search, detail (attendance history, emergency contact), on-leave filter, branch/org filter |
| 22 | My Account & Profile | `Controllers/Account/` | Profile header, additional info, change avatar (circle crop), FAQ |
| 23 | My File (Document Management) | `Controllers/MyFile/`, `Module/TalentaECM/` | View, upload, delete, update files; type picker |
| 24 | Change Personal Data | `Controllers/ChangeData/` | Request change for text/image data, list view, detail notification |
| 25 | Education & Work Experience | `Controllers/EducationInfo/` | Formal, informal education; work experience; grade bottom sheet |
| 26 | Custom Form | `Controllers/CustomForm/` | Index, form fill, submitted list, detail |
| 27 | Payslip | `Services/NetworkService/UserRequest.swift` (getPayslipData) | View payslip data with month/year selector |
| 28 | Reprimand | `Controllers/Reprimand/` | List with filter, detail view |
| 29 | Reimbursement | `Controllers/Reimbursement/` | Bottom sheet entry, notification detail, AI-enabled flag |
| 30 | Goals | `Controllers/Goals/` | Inbox detail for performance goals |
| 31 | Insight (Analytics) | `Controllers/Insight/` | WebView-based insight dashboard |
| 32 | Onboarding Tour | `Controllers/OnboardingTour/` | Guided tour: colleague, document, employee info, form, task, work location |
| 33 | Mekari Benefit / Flex | `Controllers/Mekari Benefit/` | Flex inquiry, input PIN/password security screen |
| 34 | Commerce / Mekari Credit | `Controllers/Commerce/`, `Services/NetworkService/CommerceService.swift` | Register commerce/Mekari Credit |
| 35 | Frontdesk | `Controllers/Frontdesk/` | WebView-based frontdesk feature |
| 36 | Peduli Lindungi (Health) | `Controllers/PeduliLindungi/` | WebView-based health certificate integration |
| 37 | Settings | `Controllers/Settings/` | Reminder for CICO, PIN activation, password change (SSO), timeout interval |
| 38 | Notifications (FCM) | `NotificationServiceExtension/`, `NotificationContentExtension/` | Rich push notification display and handling |
| 39 | Attendance Widget | `Attendance/` (extension target) | iOS home screen widget showing attendance shortcut |
| 40 | Flutter Module (brick_house) | Embedded via `cocoapods-embed-flutter` | Time Management and other features delegated to Flutter; `TimeManagementManager` / `flutterTmManager` |
