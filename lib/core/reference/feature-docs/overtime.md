**Feature:** Overtime
**Summary:** Lets employees submit overtime requests, view their overtime history, and track planning-based overtime assignments. Managers can review, approve, or reject their team's requests from a dedicated team view.

**References**
- PRD: [pending — not provided]
- Figma: [pending — not provided]
- Jira: [pending — not provided]
- BE Contract: [pending — not provided]

---

**API Contracts**

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/overtime-request` | Fetch form pre-fill data (current shift, day-off flag, compensation type) |
| POST | `/overtime-request` (multipart) | Submit overtime request; body varies for office-hour vs day-off subtypes |
| GET | `/history-request/overtime` | Paginated personal overtime history |
| GET | `/history-request/overtime/{id}` | Detail of a single overtime request |
| POST | `/cancel-request` | Cancel an existing overtime request |
| GET | `/history-request/overtime-pending` | Pending requests count / single-request flag (Flutter only) |
| GET | `/v2/overtime-request` | Date-range based request data query (iOS Clean path) |
| GET | `/companies/{companyId}/overtime-plannings/users` | List overtime planning entries for the current user |
| GET | `/companies/{companyId}/overtime-plannings/users/{id}?check_invalid=true` | Detail of a single planning entry |
| POST | `/overtime-request` (multipart, claim) | Claim an overtime planning entry into a request |
| POST | `/companies/{companyId}/overtime-plannings/users/{id}/reject` | Reject a planning entry (multipart) |
| POST | `/approval-request/bulk-overtime` | Bulk approve/reject overtime requests |
| POST | `/approval-request/bulk-overtime-planning` | Bulk approve/reject overtime planning entries (Android only) |
| GET | `/companies/{company_id}/teams/overtime-requests` | Team overtime requests list (Flutter; requires `X-TL-LEGACY-RESPONSE: true` header, routed to `TalentaService.timeOff`) |
| GET | `/request/employee-list` | Subordinate employee list for team overtime form (Flutter) |
| GET | `/inbox/overtime-info` | Notification badge count for overtime approvals (Android) |
| GET | `talenta://inbox/page/overtime-approval` | Deep-link: inbox overtime approval (iOS Flutter bridge) |
| GET | `talenta://inbox/page/index-overtime` | Deep-link: inbox overtime index (iOS Flutter bridge) |

---

**Data Model**

| Entity | Fields |
|--------|--------|
| OvertimeRequest | id: Int, description: String, overtimeType: String, statusApproval: Int (0=Pending, 1=Reject, 2=Approve, 3=Cancel), requestDate: String, scheduleIn: String, scheduleOut: String, hour: Int, minutes: Int, compensationType: Int, approvalList: List\<ApprovalHistoryItem\>, files: List\<FileAttachment\>, shift: Shift?, customFields: List\<OvertimeCustomField\> |
| OvertimePlanningDetail | id: Int, planningCode: String, planningDate: String, scheduleIn: String, scheduleOut: String, overtimeBefore: String, overtimeAfter: String, approvalStatus: String, claimStatus: Int, isClaimed: Bool, isHoliday: Bool, isShiftChanged: Bool, approvalList: List\<ApprovalHistoryItem\>, customFields: List\<OvertimePlanningCustomField\>, shift: Shift? |
| OvertimeFormData | currentShiftList: List\<Shift\>, dayOff: Int, compensationType: Int, useOvertimeOnBreak: Bool, restrictOvertimeOnBreak: Bool, customFields: List\<OvertimeCustomFieldConfig\> |
| OvertimeHistoryItem | id: Int, description: String, statusApproval: Int, requestDate: String, createDate: String, compensationType: Int, overtimeType: String, totalDuration: String, planningCode: String? |
| TeamOvertimeRequestItem | id: Int, userId: Int, requesterId: Int, employeeFullName: String, employeeId: String, compensation: OvertimeCompensationType?, description: String, status: OvertimeApprovalStatus?, canCancel: Bool, requestDate: String, totalOvertimeDuration: String, employeeAvatarUrl: String? |
| HistoryRequestOvertimePending | totalPendingRequest: Int?, isOvertimeSingleRequest: Bool? |
| ApprovalHistoryItem | (shared across platforms) approver: EmployeeModel, status: Int, date: String, notes: String? |
| FileAttachment | url: String, name: String, type: String |

---

**High Level Design**

```
                   Presentation                    Domain                      Data                          Network
                ─────────────────────────   ──────────────────────   ───────────────────────────   ────────────────────────────────
iOS             DashboardViewModel/          GetRequestOvertimeData   OvertimeRepositoryImpl        → POST /overtime-request
[Mixed]         DashboardCoordinator       → UseCase                → (manual singleton)           → GET  /overtime-request
                OvertimeCoordinator          PostRequestOvertime      OvertimeNetworkRequest          GET  /history-request/overtime
                RequestOvertimeVC/VM         UseCase                  (shared Moya client)            GET  /history-request/overtime/{id}
                DetailOvertimeVC/VM          GetDetailOvertimeRequest  DetailOvertimeLocalData         POST /cancel-request
                [Clean — TalentaTM module]   UseCase                  ServiceImpl (UserDefaults)      GET/POST planning endpoints
                                             GetOvertimePlanning
                                             DetailUseCase
                                             PostCancelOvertimeRequest
                                             UseCase

                OvertimeHistoryVC/VM   ──────────────────────────────→ OvertimeHistoryDataRequest    → GET /history-request/overtime
                PlanningOvertimeTab    ──────────────────────────────→ PlanningOvertimeTabRequest    → GET /companies/.../overtime-plannings/users
                VC/VM                                                   Service
                [pre-Clean — Controllers]   *(bypasses domain layer)

                DetailOvertimeNotification ─────────────────────────→ DetailOvertimeNotification     → InboxRequest (GET inbox/...)
                VC/VM [pre-Clean]           *(bypasses domain layer)   NetworkServiceImpl

                Flutter bridge path:
                DashboardCoordinator.openOvertime()
                  └─ useOvertimePlanning=false → TimeManagementManager → talenta://tm/page/overtime
                  └─ useOvertimePlanning=true  → OvertimeCoordinator (native planning flow)
                openTeamOvertime() → TimeManagementManager → talenta://tm/page/team-overtime-index (always)

                ─────────────────────────────   ──────────────────────   ───────────────────────────   ────────────────────────────────
Android         OvertimeIndexFragment            GetOvertimeHistoryData   OvertimeRepoImpl              → GET  /history-request/overtime
[Clean]         OvertimeIndexRequestFragment   → UseCase                → OvertimeApi (Retrofit)        → GET  /overtime-request
                OvertimeIndexPlanningFragment    GetOvertimeDataUseCase   *(no dedicated DataSource      → POST /overtime-request (multipart)
                FormOvertimeActivity             PostOvertimeOfficeHour     layer; Repo calls Api          GET  /history-request/overtime/{id}
                DetailOvertimeActivity           UseCase                    directly)                     POST /cancel-request
                [Presenter: MVP pattern]         PostOvertimeDayOffUseCase                                GET/POST planning endpoints
                OvertimeNeedApprovalActivity     GetDetailOvertimeUseCase                                 POST /approval-request/bulk-*
                (inbox)                          CancelRequestOvertimeUseCase                             GET  /inbox/overtime-info
                OvertimeRequest/Planning         GetListOvertimePlanningUseCase
                NeedApprovalPresenter            GetOvertimePlanningDetailUseCase
                                                 PostOvertimePlanningUseCase
                                                 RejectOvertimePlanningUseCase
                                                 BulkApprovalOvertimeRequestUseCase
                                                 BulkApprovalOvertimePlanningUseCase
                                                 GetInboxOvertimeNeedApprovalInfoUseCase

                Flutter bridge path:
                OvertimeNavigationImpl.navigateToOvertimeIndexActivity()
                  └─ isUseOvertimePlanning=false → TalentaModule.openTmOvertimeIndex()
                       → BrickActivity (FlutterActivity) via BrickChannelDelegate MethodChannel
                       ┄┄┄┄ FlutterEngine boundary ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
                       → Flutter OvertimeIndexScreen
                  └─ isUseOvertimePlanning=true  → DashboardMenuActivity (native)
                navigateToRequestOvertime() → TalentaModule.openTmRequestOvertime() → Flutter RequestOvertimeScreen
                navigateToOvertimeInboxDetail() → TalentaModule.openInboxDetails() → Flutter inbox detail

                ─────────────────────────────   ──────────────────────   ───────────────────────────   ────────────────────────────────
Flutter         OvertimeIndexScreen            → GetOvertimeDataUsecase → OvertimeRepositoryImpl      → GET  /overtime-request
[Clean]         RequestOvertimeScreen            PostOvertimeRequestUsecase OvertimeRemoteDataSourceImpl → POST /overtime-request (multipart)
                TeamOvertimeIndexScreen          GetOvertimeHistoryUsecase  (shared by both repos)       GET  /history-request/overtime
                GetOvertimeDataBloc              GetHistoryRequestOvertime                               GET  /history-request/overtime-pending
                PostOvertimeRequestBloc          PendingUseCase                                          GET  /companies/.../teams/overtime-requests
                GetOvertimeHistoryBloc           GetTeamOvertimeRequestsUseCase TeamOvertimeRepositoryImpl  (X-TL-LEGACY-RESPONSE: true)
                GetHistoryRequestOvertime        GetSubordinateEmployees                                 GET  /request/employee-list
                PendingBloc                      TeamApprovalRequestUseCase
                GetTeamOvertimeRequestsBloc
                GetOvertimeFormEmployee
                SubordinateListBloc
```

\* Pre-Clean paths in iOS bypass the domain layer — ViewController/ViewModel call Service classes that hit the network directly.

---

**Data Flow**

```
┌─────────────────────────────────────────────────────────────────────────┐
│ iOS [Mixed]                                                              │
│                                                                          │
│  DashboardViewModel                                                      │
│       └─ DashboardCoordinator.openOvertime()                            │
│             ├─ [useOvertimePlanning=true]                               │
│             │     └─ OvertimeCoordinator                                │
│             │           ├─ [Clean path — TalentaTM]                    │
│             │           │    RequestOvertimeCoordinator                 │
│             │           │      → RequestOvertimeViewModel               │
│             │           │          → GetRequestOvertimeDataUseCase      │
│             │           │          → PostRequestOvertimeUseCase         │
│             │           │               → OvertimeRepository            │
│             │           │                    → OvertimeRepositoryImpl   │
│             │           │                         → OvertimeNetworkReq  │
│             │           │    DetailOvertimeCoordinator                  │
│             │           │      → DetailOvertimeViewModel                │
│             │           │          → GetDetailOvertimeRequestUseCase    │
│             │           │          → PostCancelOvertimeRequestUseCase   │
│             │           │          → PostRejectOvertimeUseCase          │
│             │           │               → OvertimeRepository            │
│             │           │                    → OvertimeRepositoryImpl   │
│             │           │                         → OvertimeNetworkReq  │
│             │           │    GetOvertimePlanningDetailUseCase           │
│             │           │          → OvertimeRepository                 │
│             │           │               → OvertimeRepositoryImpl        │
│             │           │                    → OvertimeNetworkRequest   │
│             │           │                                               │
│             │           └─ [pre-Clean path — Controllers]               │
│             │                OvertimeViewController (tab host)          │
│             │                  ├─ OvertimeHistoryViewController         │
│             │                  │    → OvertimeHistoryViewModel          │
│             │                  │    ✕ bypasses domain layer             │
│             │                  │    → OvertimeHistoryDataRequestService │
│             │                  │         → OvertimeNetworkRequest       │
│             │                  └─ PlanningOvertimeTabViewController     │
│             │                       → PlanningOvertimeTabViewModel      │
│             │                       ✕ bypasses domain layer             │
│             │                       → PlanningOvertimeTabRequestService │
│             │                            → OvertimeNetworkRequest       │
│             │                                                           │
│             └─ [useOvertimePlanning=false]                              │
│                   TimeManagementManager                                  │
│                ┄┄┄┄┄ FlutterEngine boundary ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄   │
│                   talenta://tm/page/overtime  (personal index)          │
│                   talenta://tm/page/request-overtime (new request form) │
│                                                                          │
│  DashboardCoordinator.openTeamOvertime() [always Flutter]              │
│    → TimeManagementManager                                              │
│  ┄┄┄ FlutterEngine boundary ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄   │
│    talenta://tm/page/team-overtime-index                                │
│                                                                          │
│  Notification path [pre-Clean]:                                         │
│    DetailOvertimeNotificationViewController                             │
│      → DetailOvertimeNotificationViewModel                              │
│      ✕ bypasses domain layer                                            │
│      → DetailOvertimeNotificationNetworkServiceImpl                     │
│           → InboxRequest (OvertimeNetworkRequest)                       │
│                                                                          │
│  Callback: DETAIL_OVERTIME_REQUEST_ACTIVITY                             │
│    → DetailOvertimeCoordinator (re-entry from Flutter)                  │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ Android [Clean — MVP]                                                    │
│                                                                          │
│  OvertimeNavigationImpl.navigate()                                      │
│    ├─ [isUseOvertimePlanning=false]                                     │
│    │     → TalentaModule.openTmOvertimeIndex()                          │
│    │     → BrickActivity (FlutterActivity) via BrickChannelDelegate     │
│    │   ┄┄ FlutterEngine boundary ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  │
│    │     → Flutter OvertimeIndexScreen                                  │
│    └─ [isUseOvertimePlanning=true] → OvertimeIndexFragment (tab host)  │
│          ├─ OvertimeIndexRequestFragment                                 │
│          │    → OvertimeIndexRequestPresenter                            │
│          │         → GetOvertimeHistoryDataUseCase                      │
│          │         → GetOvertimeDataUseCase                             │
│          │              → OvertimeRepository → OvertimeRepoImpl         │
│          │                   → OvertimeApi                              │
│          ├─ OvertimeIndexPlanningFragment                               │
│          │    → OvertimeIndexPlanningPresenter                          │
│          │         → GetListOvertimePlanningUseCase                     │
│          │         → GetOvertimePlanningDetailUseCase                   │
│          │              → OvertimeRepository → OvertimeRepoImpl         │
│          │                   → OvertimeApi                              │
│          └─ FormOvertimeActivity                                         │
│                → FormOvertimePresenter                                   │
│                     → PostOvertimeOfficeHourUseCase                     │
│                     → PostOvertimeDayOffUseCase                         │
│                     → PostOvertimePlanningUseCase                       │
│                          → OvertimeRepository → OvertimeRepoImpl        │
│                               → OvertimeApi                             │
│                → DetailOvertimeActivity                                 │
│                     → DetailOvertimePresenter                           │
│                          → GetDetailOvertimeUseCase                     │
│                          → CancelRequestOvertimeUseCase                 │
│                          → RejectOvertimePlanningUseCase                │
│                               → OvertimeRepository → OvertimeRepoImpl   │
│                                    → OvertimeApi                        │
│                                                                          │
│  OvertimeNeedApprovalActivity (inbox/notification entry)                │
│    ├─ OvertimeRequestNeedApprovalPixelFragment                          │
│    │    → OvertimeRequestNeedApprovalPresenter                          │
│    │         → BulkApprovalOvertimeRequestUseCase                       │
│    │              → OvertimeRepository → OvertimeRepoImpl               │
│    │                   → BulkApprovalApi                                │
│    └─ OvertimePlanningNeedApprovalPixelFragment                         │
│         → OvertimePlanningNeedApprovalPresenter                         │
│              → BulkApprovalOvertimePlanningUseCase                      │
│                   → OvertimeRepository → OvertimeRepoImpl               │
│                        → BulkApprovalApi                                │
│                                                                          │
│  GetInboxOvertimeNeedApprovalInfoUseCase                                │
│    → OvertimeRepository → OvertimeRepoImpl → InboxApi                  │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ Flutter [Clean — BLoC]                                                   │
│                                                                          │
│  OvertimeIndexScreen                                                     │
│    ├─ GetOvertimeDataBloc                                               │
│    │    → GetOvertimeDataUsecase                                        │
│    │         → OvertimeRepository → OvertimeRepositoryImpl              │
│    │              → OvertimeRemoteDataSourceImpl → GET /overtime-request│
│    ├─ PostOvertimeRequestBloc                                           │
│    │    → PostOvertimeRequestUsecase                                    │
│    │         → OvertimeRepository → OvertimeRepositoryImpl              │
│    │              → OvertimeRemoteDataSourceImpl                        │
│    │                   → POST /overtime-request (multipart)             │
│    ├─ GetOvertimeHistoryBloc                                            │
│    │    → GetOvertimeHistoryUsecase                                     │
│    │         → OvertimeRepository → OvertimeRepositoryImpl              │
│    │              → OvertimeRemoteDataSourceImpl                        │
│    │                   → GET /history-request/overtime (paginated)      │
│    └─ GetHistoryRequestOvertimePendingBloc                              │
│         → GetHistoryRequestOvertimePendingUseCase                       │
│              → OvertimeRepository → OvertimeRepositoryImpl              │
│                   → OvertimeRemoteDataSourceImpl                        │
│                        → GET /history-request/overtime-pending          │
│                                                                          │
│  RequestOvertimeScreen                                                   │
│    → PostOvertimeRequestBloc (shared)                                   │
│    → GetOvertimeFormEmployeeSubordinateListBloc                         │
│         → GetSubordinateEmployeesTeamApprovalRequestUseCase (type=ot)  │
│              → OvertimeRemoteDataSourceImpl                             │
│                   → GET /request/employee-list                          │
│                                                                          │
│  TeamOvertimeIndexScreen                                                 │
│    → GetTeamOvertimeRequestsBloc                                        │
│         → GetTeamOvertimeRequestsUseCase                                │
│              → TeamOvertimeRepository → OvertimeRepositoryImpl          │
│                   → OvertimeRemoteDataSourceImpl                        │
│                        → GET /companies/{id}/teams/overtime-requests    │
│                             [X-TL-LEGACY-RESPONSE: true]                │
└─────────────────────────────────────────────────────────────────────────┘
```

**Path A — iOS: submit overtime request (Clean path)**
1. `DashboardViewModel` triggers navigation; `DashboardCoordinator.openOvertime()` evaluates `useOvertimePlanning` flag.
2. Flag=true → `OvertimeCoordinator` → `RequestOvertimeCoordinator` opens `RequestOvertimeViewController`.
3. `RequestOvertimeViewModel` calls `GetRequestOvertimeDataUseCase` → `OvertimeRepository` → `OvertimeRepositoryImpl` → `OvertimeNetworkRequest` → GET `/v2/overtime-request`.
4. User submits → `PostRequestOvertimeUseCase` → `OvertimeRepositoryImpl` → `OvertimeNetworkRequest` → POST `/overtime-request` (multipart).

**Path B — iOS: view overtime history (pre-Clean path)**
1. `OvertimeCoordinator` presents `OvertimeViewController` (tab host) → `OvertimeHistoryViewController`.
2. `OvertimeHistoryViewModel` calls `OvertimeHistoryDataRequestServiceImpl` directly (bypasses domain layer) → `OvertimeNetworkRequest` → GET `/history-request/overtime`.

**Path C — iOS: bridge to Flutter overtime index**
1. `DashboardCoordinator.openOvertime()` with `useOvertimePlanning=false` → `TimeManagementManager.openTmOvertimeIndex()`.
2. Crosses FlutterEngine boundary → route `talenta://tm/page/overtime` → Flutter `OvertimeIndexScreen`.

**Path D — iOS: team overtime (always Flutter)**
1. `DashboardCoordinator.openTeamOvertime()` → `TimeManagementManager.openTeamTmOvertimeIndex()`.
2. Crosses FlutterEngine boundary → route `talenta://tm/page/team-overtime-index` → Flutter `TeamOvertimeIndexScreen`.

**Path E — Android: view overtime index**
1. `OvertimeNavigationImpl` routes to `OvertimeIndexFragment`.
2. `OvertimeIndexRequestPresenter` calls `GetOvertimeHistoryDataUseCase` + `GetOvertimeDataUseCase` → `OvertimeRepository` → `OvertimeRepoImpl` → `OvertimeApi`.

**Path F — Android: submit overtime request**
1. `OvertimeIndexFragment` navigates to `FormOvertimeActivity`.
2. `FormOvertimePresenter` calls `PostOvertimeOfficeHourUseCase` or `PostOvertimeDayOffUseCase` (same endpoint, different body) → `OvertimeRepoImpl` → `OvertimeApi` → POST `/overtime-request`.

**Path G — Android: bulk approval from notification**
1. Push notification → `OvertimeNeedApprovalActivity` → `OvertimeRequestNeedApprovalPixelFragment` or `OvertimePlanningNeedApprovalPixelFragment`.
2. Presenter calls `BulkApprovalOvertimeRequestUseCase` or `BulkApprovalOvertimePlanningUseCase` → `OvertimeRepoImpl` → `BulkApprovalApi` → POST `/approval-request/bulk-overtime` or `/bulk-overtime-planning`.

**Path H — Flutter: load overtime index + history**
1. `OvertimeIndexScreen` mounts; `GetOvertimeDataBloc` dispatches `GetOvertimeDataEvent` → `GetOvertimeDataUsecase` → `OvertimeRepositoryImpl` → `OvertimeRemoteDataSourceImpl` → GET `/overtime-request`.
2. `GetOvertimeHistoryBloc` dispatches `GetOvertimeHistoryEvent` → `GetOvertimeHistoryUsecase` → same stack → GET `/history-request/overtime` (paginated; list accumulates; resets on page 1).

**Path I — Flutter: team overtime view**
1. `TeamOvertimeIndexScreen` mounts; `GetTeamOvertimeRequestsBloc` dispatches event → `GetTeamOvertimeRequestsUseCase` → `TeamOvertimeRepository` → `OvertimeRepositoryImpl` → `OvertimeRemoteDataSourceImpl` → GET `/companies/{id}/teams/overtime-requests` with `X-TL-LEGACY-RESPONSE: true`, routed to `TalentaService.timeOff`.

---

**Artifacts**

| Layer | iOS Native | Android Native | Flutter Module |
|-------|-----------|----------------|----------------|
| Screen (index / tab host) | `OvertimeViewController` | `OvertimeIndexFragment` | `OvertimeIndexScreen` |
| Screen (request list tab) | — | `OvertimeIndexRequestFragment` | — |
| Screen (planning tab) | `PlanningOvertimeTabViewController` [pre-Clean] | `OvertimeIndexPlanningFragment` | — |
| Screen (request form) | `RequestOvertimeViewController` [Clean] | `FormOvertimeActivity` | `RequestOvertimeScreen` |
| Screen (detail) | `DetailOvertimeViewController` [Clean] | `DetailOvertimeActivity` | — |
| Screen (detail history sub-view) | `DetailOvertimeHistoryViewController` [Clean] | — | — |
| Screen (detail logs sub-view) | `DetailsOvertimeLogsViewController` [Clean] | — | — |
| Screen (detail menu sub-view) | `DetailOvertimeMenuViewController` [Clean] | — | — |
| Screen (notification/approval entry) | `DetailOvertimeNotificationViewController` [pre-Clean] | `OvertimeNeedApprovalActivity` | — |
| Screen (team overtime index) | — (Flutter bridge) | — (WebView fallback or native nav) | `TeamOvertimeIndexScreen` |
| Screen (tab page menu) | `OvertimePageMenuViewController` | — | — |
| Screen (approval pixel fragments) | — | `OvertimeRequestNeedApprovalPixelFragment`, `OvertimePlanningNeedApprovalPixelFragment` | — |
| State holder | `RequestOvertimeViewModel` [Clean], `DetailOvertimeViewModel` [Clean], `OvertimeHistoryViewModel` [pre-Clean], `PlanningOvertimeTabViewModel` [pre-Clean], `DetailOvertimeNotificationViewModel` [pre-Clean] | `OvertimeIndexRequestPresenter`, `OvertimeIndexPlanningPresenter`, `FormOvertimePresenter`, `DetailOvertimePresenter`, `OvertimeNeedApprovalPresenter`, `OvertimeRequestNeedApprovalPresenter`, `OvertimePlanningNeedApprovalPresenter` | `GetOvertimeDataBloc`, `PostOvertimeRequestBloc`, `GetOvertimeHistoryBloc`, `GetHistoryRequestOvertimePendingBloc`, `GetTeamOvertimeRequestsBloc`, `GetOvertimeFormEmployeeSubordinateListBloc` |
| Navigation | `DashboardCoordinator`, `OvertimeCoordinator`, `RequestOvertimeCoordinator` [Clean], `DetailOvertimeCoordinator` [Clean], `OvertimeHistoryCoordinator`, `PlanningOvertimeTabCoordinator`, `DetailOvertimeNotificationCoordinator` [pre-Clean] | `OvertimeNavigation` (interface), `OvertimeNavigationImpl` | — (route-based) |
| Use case | `GetRequestOvertimeDataUseCase`, `PostRequestOvertimeUseCase`, `GetOvertimePlanningDetailUseCase`, `GetDetailOvertimeRequestUseCase`, `PostCancelOvertimeRequestUseCase`, `PostRejectOvertimeUseCase` | `GetOvertimeHistoryDataUseCase`, `GetOvertimeDataUseCase`, `PostOvertimeOfficeHourUseCase`, `PostOvertimeDayOffUseCase`, `GetDetailOvertimeUseCase`, `CancelRequestOvertimeUseCase`, `GetListOvertimePlanningUseCase`, `GetOvertimePlanningDetailUseCase`, `PostOvertimePlanningUseCase`, `RejectOvertimePlanningUseCase`, `BulkApprovalOvertimeRequestUseCase`, `BulkApprovalOvertimePlanningUseCase`, `GetInboxOvertimeNeedApprovalInfoUseCase` | `GetOvertimeDataUsecase`, `PostOvertimeRequestUsecase`, `GetOvertimeHistoryUsecase`, `GetHistoryRequestOvertimePendingUseCase`, `GetTeamOvertimeRequestsUseCase`, `GetSubordinateEmployeesTeamApprovalRequestUseCase` |
| Repository interface | `OvertimeRepository` | `OvertimeRepository` | `OvertimeRepository` (abstract), `TeamOvertimeRepository` (abstract) |
| Repository impl | `OvertimeRepositoryImpl` [manual singleton] | `OvertimeRepoImpl` | `OvertimeRepositoryImpl` |
| Data source (remote) | `OvertimeNetworkRequest` (Moya; shared by Clean + pre-Clean paths) | `OvertimeApi` (Retrofit; called directly by repo) | `OvertimeRemoteDataSourceImpl` |
| Data source (local) | `DetailOvertimeLocalDataServiceImpl` (UserDefaults/Keychain), `OvertimeHistoryLocalDataService` [pre-Clean] | — (SessionPreference in-memory) | — |
| Service (pre-Clean wrappers) | `OvertimeHistoryDataRequestServiceImpl`, `PlanningOvertimeTabRequestService`, `DetailOvertimeNotificationNetworkServiceImpl`, `RequestOvertimeNetworkServiceImpl` | — | — |
| Flutter bridge | `TimeManagementManager`, `TimeManagementManagerProtocol` | — | — |
| Reusable widget | — | — | `RequestOvertimeWidget`, `OvertimeRequestListWidget`, `OvertimeHistoryListPaginationWidget`, `OvertimeSingleConcurrentAwaitingApprovalBanner` |
| Network interface | `OvertimeInterface` / `OvertimeDescription` (Moya target) | `OvertimeApi` (interface + Retrofit annotations) | `OvertimeRemoteDataSourceImpl` (Dio) |

---

**Platform Variants**

- **iOS** [Mixed]: Two coexisting stacks within the same binary. The `TalentaTM` module (`Module/TalentaTM/`) implements Clean Architecture with `ViewController → ViewModel → UseCase → OvertimeRepository → OvertimeRepositoryImpl → OvertimeNetworkRequest` for the request form, detail, and planning-detail flows. The legacy Controllers module (`Controllers/Overtime/`) uses a pre-Clean `ViewController → ViewModel → Service → OvertimeNetworkRequest` pattern (domain layer absent) for the history tab, planning tab, and notification-detail screens. `OvertimeRepositoryImpl` is a manual singleton (`sharedInstance`), not DI-injected. The team overtime entry point always bridges to Flutter regardless of feature flag; the personal overtime entry uses a `useOvertimePlanning` toggle to choose between native planning flow and Flutter bridge.

- **iOS Flutter Bridge**: Native iOS delegates overtime rendering to Flutter via `TimeManagementManager`. When `useOvertimePlanning=false`, `DashboardCoordinator.openOvertime()` calls `TimeManagementManager.openTmOvertimeIndex()` which launches the route `talenta://tm/page/overtime`. Team overtime always uses `openTeamTmOvertimeIndex()` → `talenta://tm/page/team-overtime-index`. New request form can be triggered directly via `talenta://tm/page/request-overtime` (with `CalendarParams`). Flutter can callback to native via `DETAIL_OVERTIME_REQUEST_ACTIVITY` (`TimeManagementPageIdentifier.requestOvertimeDetail`) → `DetailOvertimeCoordinator`. Deep-links for inbox approval (`talenta://inbox/page/overtime-approval`, `talenta://inbox/page/index-overtime`) are handled by `TalentaModule` via `BricksAddress`.

- **Android Flutter Bridge**: Android delegates overtime rendering to Flutter via the Bricks framework. When `isUseOvertimePlanning=false`, `OvertimeNavigationImpl.navigateToOvertimeIndexActivity()` calls `Bricks.getModule<TalentaModule>().openTmOvertimeIndex()`, which launches `BrickActivity` (a `FlutterActivity` subclass). The URI command is delivered to the Flutter engine via `BrickChannelDelegate` over a `MethodChannel`. This is the same Flutter module (`mobile-talenta`) as iOS. `navigateToRequestOvertime()` calls `talentaModule.openTmRequestOvertime()`. Inbox/approval detail calls `talentaModule.openInboxDetails()`. Note the toggle logic is **inverted** vs iOS: on Android, flag=false → Flutter bridge; flag=true → native `DashboardMenuActivity`.

- **Android** [Clean]: Clean Architecture with MVP presentation layer. Presenters (not ViewModels) are constructor-injected via Dagger. Feature is split across two Gradle modules: `feature_overtime` (main index, form, detail) and `app` module (inbox/notification approval screens). `OvertimeRepoImpl` calls `OvertimeApi` directly — no dedicated `DataSource` interface exists. `postOvertimeOfficeHour` and `postOvertimeDayOff` use the same API endpoint with different multipart bodies. Caching handled via `SessionPreference` (shared prefs / in-memory). Navigation has a dual-path: `isUseOvertimePlanning=false` → Flutter bridge via Bricks/TalentaModule (`BrickActivity`); flag=true → native `DashboardMenuActivity` / `OvertimeIndexFragment`.

- **Flutter** [Clean]: Full Clean Architecture with BLoC presentation layer. Personal and team overtime separated into two repository interfaces (`OvertimeRepository`, `TeamOvertimeRepository`) both backed by the same `OvertimeRepositoryImpl` and `OvertimeRemoteDataSourceImpl`. All BLoCs are transient (`@injectable`); use cases and data sources are `@lazySingleton`. `GetOvertimeHistoryBloc` implements manual pagination by accumulating items into a mutable list, resetting on `page == 1`. The team overtime endpoint requires a non-standard `X-TL-LEGACY-RESPONSE: true` header and is routed through `TalentaService.timeOff`, diverging from the standard service routing.

---

**Gotchas / Known Constraints**

- **Feature-toggle dual-path (iOS + Android, inverted logic):** Both platforms gate the overtime index behind a toggle but with opposite polarity. iOS `DashboardCoordinator.openOvertime()`: `useOvertimePlanning=true` → native; `false` → Flutter bridge. Android `OvertimeNavigationImpl`: `isUseOvertimePlanning=false` → Flutter bridge (`TalentaModule.openTmOvertimeIndex()` via `BrickActivity`); `true` → native `DashboardMenuActivity`. Any cross-platform bug report must confirm which branch was active on each platform — the same flag value routes to opposite implementations.
- **iOS singleton repository:** `OvertimeRepositoryImpl` is instantiated as a manual `sharedInstance`, not registered with the DI container. It does not participate in the standard injectable lifecycle, cannot be replaced in tests via DI, and shares state across the app's lifetime.
- **iOS pre-Clean / Clean parallel stacks share one network client:** Both `OvertimeHistoryDataRequestServiceImpl` (pre-Clean) and `OvertimeRepositoryImpl` (Clean) call `OvertimeNetworkRequest` (the Moya target). A change to `OvertimeNetworkRequest` (endpoint rename, response shape change) affects both stacks simultaneously — test both paths.
- **Android split-module approval screens:** The inbox-entry approval screens (`OvertimeNeedApprovalActivity` and pixel fragments) live in the `:app` module, not in `:feature_overtime`. Bulk-approval use cases call `BulkApprovalApi`, not `OvertimeApi`. An engineer touching only `:feature_overtime` will miss this surface.
- **Flutter pagination mutation:** `GetOvertimeHistoryBloc` accumulates pages into a mutable `List` held in bloc state. The reset condition (`page == kInitialPage`) is checked inside the bloc event handler — if an event is dispatched with `page=1` mid-session (e.g. pull-to-refresh) the accumulated list is discarded silently. Ensure any refresh trigger always passes `page=1`.
- **Flutter team overtime legacy header:** GET `/companies/{company_id}/teams/overtime-requests` requires `X-TL-LEGACY-RESPONSE: true`. If this header is dropped (e.g. during a Dio interceptor refactor), the response shape changes silently and the team overtime list will fail to parse with no obvious error at the network layer.
