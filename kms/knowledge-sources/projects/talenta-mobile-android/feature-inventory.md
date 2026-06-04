# Feature Inventory — talenta-mobile-android

Platform: Android (Kotlin)
Architecture: Clean Architecture + MVP
Last scanned: 2026-06-04

## Application Shell
| Module | Path | Description |
|---|---|---|
| `app` | `app/` | DI graph bootstrap, navigation orchestration, flavors (develop/prod), build variants |

## Shared Layers
| Module | Path | Description |
|---|---|---|
| `base` | `base/` | MVP base classes (BasePresenter, MvpPresenter, MvpView), shared helpers, navigation abstractions |
| `domain` | `domain/` | Use case base classes (SingleUseCase, CompletableUseCase, FlowableUseCase, MaybeUseCase), repository interfaces, domain entities |
| `data` | `data/` | Repository implementations, Retrofit API interfaces, response/request models, mappers, DB (Room/SQLCipher) |
| `commontest` | `commontest/` | Shared test fixtures, JUnitForger (Elmyr), test builders |

## Feature Modules (feature_*)
| Module | Path | HR Domain |
|---|---|---|
| `feature_auth` | `feature_auth/` | Login, logout, OTP/phone validation, SSO, biometric auth, PIN |
| `feature_live_attendance` | `feature_live_attendance/` | Check-in/check-out, schedule, offline CICO, approval request, attendance history, attendance metrics |
| `feature_shared_live_attendance` | `feature_shared_live_attendance/` | Shared UI widgets for live attendance — location bottom sheets, suggestion dialogs, out-of-radius info |
| `feature_live_tracking` | `feature_live_tracking/` | GPS waypoint tracking, live tracking status, location log playback |
| `feature_timeoff` | `feature_timeoff/` | Time-off request, balance, history, delegation, multi-shift check |
| `feature_overtime` | `feature_overtime/` | Overtime request (office hours & day-off), planning, approval, history |
| `feature_shift` | `feature_shift/` | Change-shift request, shift list, shift-request history |
| `feature_task` | `feature_task/` | Task CRUD, task activity log, assignee management, timer, timesheet |
| `feature_reviews` | `feature_reviews/` | Performance review info, encrypted token bridge to review web app |
| `feature_payslip` | `feature_payslip/` | Payslip listing and detail (WebView-based) |
| `feature_portal` | `feature_portal/` | Frontdesk portal mode — employee index, CICO on behalf, device registration, offline sync |
| `feature_frontdesk` | `feature_frontdesk/` | Frontdesk-specific attendance flows |
| `feature_employee` | `feature_employee/` | Employee directory, detail, branch/org filter, leave-today view |
| `feature_personal_info` | `feature_personal_info/` | My info — education, emergency contact, working experience, files |
| `feature_my_files` | `feature_my_files/` | File upload, update, delete, type listing |
| `feature_reprimand` | `feature_reprimand/` | Reprimand list, detail, feedback (comment thread) |
| `feature_form` | `feature_form/` | Custom form submissions — list, detail, generate token, delete |
| `feature_consultant` | `feature_consultant/` | Multi-company consultant role — company list, company switch |
| `feature_feedback` | `feature_feedback/` | Firebase-based feedback channel |
| `feature_integration` | `feature_integration/` | Third-party integration navigation hub |
| `feature_mekari_expense` | `feature_mekari_expense/` | Mekari Expense deep-link with encrypted token handoff |
| `feature_mekari_insight` | `feature_mekari_insight/` | Mekari Insight navigation bridge |
| `feature_mekari_credit` | *(in data module)* | Mekari Flex/credit registration |

## Core Library Modules (lib_core_*)
| Module | Path | Responsibility |
|---|---|---|
| `lib_core_network` | `lib_core_network/` | OkHttp/Retrofit setup, certificate pinning, URL resolution |
| `lib_core_helper` | `lib_core_helper/` | Extension functions, common utilities (orEmpty, orZero, orFalse) |
| `lib_core_biometric` | `lib_core_biometric/` | Biometric authentication wrapper |
| `lib_core_camera` | `lib_core_camera/` | CameraX-based selfie/photo capture |
| `lib_core_file_management` | `lib_core_file_management/` | File picker, download, directory helpers |
| `lib_core_localization` | `lib_core_localization/` | Locale/language management (new) |
| `lib_core_localization_legacy` | `lib_core_localization_legacy/` | Legacy locale support |
| `lib_core_mekari_pixel` | `lib_core_mekari_pixel/` | Mekari design system UI kit (components, themes, tabs) |
| `lib_core_message` | `lib_core_message/` | In-app messaging/notification utilities |
| `lib_core_shimmer` | `lib_core_shimmer/` | Facebook Shimmer loading skeleton wrapper |
| `lib_core_version_update` | `lib_core_version_update/` | In-app update (Google Play AppUpdate) |
| `lib_core_application` | `lib_core_application/` | Application-level base class and startup logic |

## Ancillary
| Module | Path | Description |
|---|---|---|
| `showcase_app` | `showcase_app/` | Internal component showcase using ViewModel (not production) |
| `bricks-talenta` | `bricks-talenta/` | Mason brick templates for code scaffolding |
| `macrobenchmark` | `macrobenchmark/` | Macrobenchmark tests |
