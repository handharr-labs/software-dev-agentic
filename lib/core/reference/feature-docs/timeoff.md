**Feature:** Time Off
**Summary:** Lets employees submit time-off requests, view their balance and request history, and manage delegations. Managers can also review and approve team time-off requests.

---

**References**
- PRD: [pending]
- Figma: [pending]
- Jira: [pending]
- BE Contract: [pending]

---

**API Contracts**

| Method | Endpoint | Caller(s) | Notes |
|---|---|---|---|
| GET | `/time-off-request` | iOS: `TimeOffDataRequest.fetchTimeOff` · Android: `TimeOffApi.getTimeOffPolicies` · Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffPoliciesWithDelegate` | Returns policy list |
| POST | `/time-off-request` | iOS: `TimeOffDataRequest.timeOffRequest` · Android: `TimeOffApi.postRequestTimeOff` (multipart) · Flutter: `TimeOffRemoteDataSourceImpl.postRequestTimeOff` | Android sends multipart with optional file attachments |
| GET | `/history-request/timeoff` | iOS: `TimeOffDataRequest.fetchTimeOffHistory` · Android: `TimeOffApi.getHistoryRequestTimeOff` · Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffRequestList` | |
| GET | `/history-request/timeoff/{id}` | iOS: `TimeOffDataRequest.fetchTimeOffDetail` · Android: `TimeOffApi.getDetailHistoryTimeOff` | |
| GET | `/history-request/timeoff/delegation/{id}` | iOS: `TimeOffDataRequest.fetchTimeOffDelegation` · Android: `TimeOffApi.getDetailDelegationTimeOff` | |
| POST | `/cancel-request` | iOS: `TimeOffDataRequest.cancelTimeOffPost` · Android: `TimeOffApi.cancelRequestTimeOff` | |
| GET | `/time-off/balance-detail` | iOS: `TimeOffDataRequest.fetchTimeOffOverviewBalanceDetail` · Android: `TimeOffApi.getTimeOffBalanceHistory` | |
| GET | `/time-off/taken-list/{policyCode\|policyId}` | iOS: `TimeOffDataRequest.fetchTimeOffOverviewBalanceTaken` · Android: `TimeOffApi.getRequestHistoryTakenAllTimeOff` | Path param name differs: iOS uses `policyCode`, Android uses `policyId` |
| GET | `/time-off-request/delegation-list` | iOS: `TimeOffDataRequest.fetchTimeOffDelegate` · Android: `TimeOffApi.getDelegationListTimeOff` · Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffDelegations` | |
| GET | `/multiple-shift/check-status` | iOS: `TimeOffDataRequest.checkMultipleShift` · Android: `TimeOffApi.checkStatusMultipleShiftPerDateRequestTimeOff` · Flutter: `TimeOffRemoteDataSourceImpl.checkMultipleShiftTimeOff` | |
| GET | `/attendance/schedule` | iOS: `TimeOffDataRequest.hourlyGetDetail` | iOS only — hourly schedule resolution |
| GET | `/time-off-info` | iOS: `TimeOffDataRequest.getTimeOffInfo` · Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffInfo` | |
| GET | `/request/employee-list` | iOS: `TimeOffDataRequest.getEmployeeList` · Android: `TimeOffApi.getTimeOffSubordinateEmployeeList` | |
| GET | `/dashboard/time-off-policy` | iOS: `DashboardRemoteDataSource.getTimeOffPolicyList` | iOS only — dashboard menu surface |
| POST | `/approval-request/timeoff-bulk` | iOS: `TimeOffRequestApi.requestBulkTimeOff` | iOS only — bulk inbox approval |
| GET | `/calendar/timeoff` | Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffList` | Flutter only |
| GET | `/calendar/timeoff-detail` | Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffDetails` | Flutter only |
| GET | `/companies/{company_id}/users/{user_id}/balances` | Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffPolicies` | Flutter only — balance list |
| GET | `/companies/{company_id}/policies/{policy_id}` | Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffPolicyDetail` | Flutter only |
| GET | `/companies/{company_id}/policies` | Flutter: `TimeOffRemoteDataSourceImpl.getAllTimeOffPolicies` | Flutter only |
| GET | `/companies/{company_id}/users/{user_id}/balances/{policy_id}/overviews` | Flutter: `TimeOffRemoteDataSourceImpl.getTimeOffBalanceOverview` | Flutter only |
| GET | `/companies/{company_id}/teams/time-off-requests` | Flutter: `TimeOffRemoteDataSourceImpl.getTeamTimeOffRequestList` | Flutter only — team time-off index |

---

**Data Model**

**TimeOffPolicy** — a single leave policy assigned to an employee

| Field | Type | Notes |
|---|---|---|
| id | String / Int | String on iOS/Flutter; Int on Android |
| policyName | String | |
| policyCode | String? | |
| policyExpiredDate | String? | |
| allowHalfDay | Int? | 0/1 flag |
| allowFullDay | Int? | 0/1 flag |
| isFullMinute | Int? | 0/1 flag |
| manualSchedule | Int? | 0/1 flag |
| duration | Int? | |
| isHourlyAllowed | Bool? | |
| enableBlockLeave | Bool? | |
| blockLeaveMinimumDays | Int? | |
| eligibleBlockLeave | Bool? | |
| remainingBalance | String? / Int? | String on Android; Int on Flutter |

**TimeOffRequest / TimeOffItem** — a single time-off request record

| Field | Type | Notes |
|---|---|---|
| id | Int | |
| companyId | Int | Flutter only |
| userId | Int | Flutter only |
| policyId | Int | |
| startDate | String | |
| endDate | String | |
| halfdayFlag | Int? | |
| halfDayType | String? | Android |
| reason / comment | String? | Android uses `comment` |
| delegateTo | Int? / String? | |
| approveFlag | Int? | Flutter |
| approvedBy | Int? | Flutter |
| policyName | String? | Flutter |
| hourlyStart | String? | Flutter |
| hourlyDuration | String? | Flutter |
| hourlyEnd | String? | Flutter |
| isHourlyPolicy | Bool | Flutter |
| requested | String? | Flutter |
| scheduleIn / scheduleOut | String? | Android |
| useHalfDay | Int? | Android |
| isTakenForBlockLeave | Bool | |
| requestBlockLeaveCount | Double | |
| listTimeOffData | List\<TimeOff\> | Android |

**RequestTimeOffResult** — outcome of a POST time-off-request

| Field | Type |
|---|---|
| responseStatus | Int |
| message | String |
| timeOffData | List\<TimeOffItem\> |
| isTakenForBlockLeave | Bool |
| requestBlockLeaveCount | Double |

**UserTimeOffDelegate** — a delegate employee option

| Field | Type |
|---|---|
| value / id | Int? |
| name | String |
| job | String? |
| avatar | String? |

**CheckMultipleShiftTimeOff** — result of shift conflict check

| Field | Type |
|---|---|
| isMultipleShift | Bool |

**TimeOffDatum** (iOS raw response wrapper)

| Field | Type |
|---|---|
| policies (CodingKey: timeOffPolicies) | List\<TimeOffPolicies\> |
| users | List\<UserTimeOffDatum\> |

---

**High Level Design**

The feature has three distinct execution paths depending on platform and entry point:

```
                   Presentation              Domain                 Data                    Network
                ─────────────────────   ──────────────────   ──────────────────────   ──────────────────
iOS             DashboardViewModel    → TimeOffRepository  → TimeOffRepositoryImpl   → POST /time-off-request
[pre-Clean]     DashboardCoordinator    (TalentaTM only)     TimeOffDataRequest (Moya)  GET  /history-request/…
                TimeManagementManager                         TimeOffRequestApi           GET  /time-off/balance-detail
                RequestTimeOffVC *   ──────────────────────→ (bypasses domain) *          GET  /multiple-shift/…
                RequestTimeOffVM *

                ─────────────────────   ──────────────────   ──────────────────────   ──────────────────
Android         Fragment / Activity   → UseCase            → TimeOffRepositoryImpl   → POST /time-off-request
[pre-Clean]     Presenter               TimeOffRepository    (cache-first via           GET  /history-request/…
                                                             SessionPreference)          GET  /time-off/balance-detail
                                                             TimeOffApi (Retrofit)       GET  /multiple-shift/…

                ─────────────────────   ──────────────────   ──────────────────────   ──────────────────
Flutter         Screen / Widget       → UseCase            → TimeOffRepositoryImpl   → POST /time-off-request
[Clean]         BLoC                    TimeOffRepository    TimeOffRemoteDataSource    GET  /calendar/timeoff
                                                             (remote only)              GET  /companies/{id}/…
                                                                                        GET  /multiple-shift/…

  * iOS native fallback — bypasses domain layer; triggered by Flutter ACTION_OPEN_PAGE callback
```

**Native Shell → FlutterEngine → Flutter Module boundary:** iOS launches the time-off index, team time-off index, and request form through `TalentaModule` (BricksAddress). Flutter emits `ACTION_OPEN_PAGE` events back to iOS when it needs native screens (e.g. `CREATE_TIME_OFF_REQUEST_ACTIVITY`), and `TimeManagementManager.handleNativePageNavigation` routes to the appropriate native coordinator/ViewController.

---

**Data Flow**

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ iOS [pre-Clean]                                                                  │
│                                                                                  │
│  DashboardViewModel → DashboardCoordinator → TimeManagementManager              │
│                                                      │                           │
│                               ┌──────────────────────┴──────────────┐            │
│                               ↓ Flutter routes                       ↓ native    │
│                         TalentaModule                    RequestTimeOffCoordinator│
│                         (BricksAddress)                        │                 │
│                               │                      RequestTimeOffViewController │
│                    ┄┄┄FlutterEngine boundary┄┄┄              │                  │
│                               ↓                      RequestTimeOffNetworkService │
│                      Flutter TM Module                        │                  │
│                      (index, team, form)              TimeOffDataRequest (Moya)  │
│                                                       ✕ bypasses domain layer    │
│  Legacy screens (History, Detail, Balance) ──────────→ TimeOffDataRequest (Moya) │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ Android [pre-Clean]                                                              │
│                                                                                  │
│  Fragment / Activity                                                             │
│       ↓                                                                          │
│  Presenter ──→ UseCase ──→ TimeOffRepository (interface)                         │
│                                    ↓                                             │
│                          TimeOffRepositoryImpl                                   │
│                          (cache-first via SessionPreference)                     │
│                                    ↓                                             │
│                            TimeOffApi (Retrofit)                                 │
└──────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────┐
│ Flutter [Clean]                                                                  │
│                                                                                  │
│  Screen / Widget                                                                 │
│       ↓                                                                          │
│  BLoC ──→ UseCase ──→ TimeOffRepository (interface)                              │
│                               ↓                                                  │
│                      TimeOffRepositoryImpl                                       │
│                               ↓                                                  │
│                      TimeOffRemoteDataSource/Impl                                │
│                      (remote only)                                               │
└──────────────────────────────────────────────────────────────────────────────────┘
```

**Path A — iOS: view time-off index (Flutter-owned)**
1. `DashboardViewModel` reads `.timeOff` menu item; user taps.
2. `DashboardCoordinator` calls `TimeManagementManager` with `TalentaRoutes.Tm.pageTimeOffIndex`.
3. `TimeManagementManager` launches Flutter via `TalentaModule` (BricksAddress) to Flutter route `/page/time-off`.
4. Flutter module renders the time-off index screen; BLoC chain handles all data fetching (see Path C).

**Path B — iOS: submit a new request (native fallback)**
1. Flutter TM module emits `ACTION_OPEN_PAGE` with `CREATE_TIME_OFF_REQUEST_ACTIVITY`.
2. `TimeManagementManager.handleNativePageNavigation` intercepts; pushes `RequestTimeOffCoordinator`.
3. `RequestTimeOffCoordinator` presents `RequestTimeOffViewController`.
4. `RequestTimeOffViewModel` drives state; calls `RequestTimeOffNetworkServiceImpl`.
5. `RequestTimeOffNetworkServiceImpl` calls `TimeOffDataRequest` (Moya) directly — bypasses `TalentaTM` Clean UseCase/Repository.
6. `TimeOffDataRequest` makes `POST /time-off-request` and returns response to ViewModel.

**Path C — Flutter: submit a new request**
1. `RequestTimeOffScreen` dispatches `PostRequestTimeOffEvent.post` to `PostRequestTimeOffBloc`.
2. `PostRequestTimeOffBloc` calls `PostRequestTimeOffUseCase`.
3. `PostRequestTimeOffUseCase` calls `TimeOffRepository.postRequestTimeOff` (interface).
4. `TimeOffRepositoryImpl` delegates to `TimeOffRemoteDataSourceImpl`.
5. `TimeOffRemoteDataSourceImpl` makes `POST /time-off-request`; returns `RequestTimeOffResult`.
6. `PostRequestTimeOffBloc` emits `PostRequestTimeOffState` (success/failure); UI updates.

**Path D — Flutter: fetch policies with delegate**
1. `RequestTimeOffScreen` dispatches `GetTimeOffPoliciesWithDelegateEvent.fetch`.
2. `GetTimeOffPoliciesWithDelegateBloc` calls `GetTimeOffPoliciesWithDelegateUseCase`.
3. UseCase calls `TimeOffRepository`; impl calls `TimeOffRemoteDataSourceImpl.getTimeOffPoliciesWithDelegate`.
4. `GET /time-off-request` returns policy+delegate payload; bloc emits updated state.

**Path E — Android: submit a new request**
1. `RequestTimeOffActivity` triggers `RequestTimeOffPresenter`.
2. `RequestTimeOffPresenter` calls `PostRequestTimeOffUseCase` (+ `CheckMultipleShiftTimeOffUseCase` and `GetMultiLiveAttendanceUseCase` for shift resolution).
3. `PostRequestTimeOffUseCase` calls `TimeOffRepository` (interface).
4. `TimeOffRepositoryImpl` calls `TimeOffApi.postRequestTimeOff` (Retrofit, multipart).
5. Response propagates back through presenter; View updates.

**Path F — Android: view request history**
1. `TimeOffIndexFragment` → `TimeOffIndexPresenter` → `GetHistoryRequestTimeOffUseCase`.
2. UseCase calls `TimeOffRepository` → `TimeOffRepositoryImpl`.
3. `TimeOffRepositoryImpl` applies cache-first via `SessionPreference`; if stale, calls `TimeOffApi.getHistoryRequestTimeOff`.
4. Data returned to presenter; Fragment renders list.

---

**Artifacts**

| Layer | iOS Native [pre-Clean] | iOS → Flutter bridge (Flutter-owned, launched from iOS) | Android [pre-Clean] | Flutter [Clean] |
|---|---|---|---|---|
| Screen | `TimeOffHistoryViewController` · `DetailTimeOffViewController` · `DetailTimeOffDelegationViewController` · `TimeOffOverviewBalanceViewController` · `TimeOffNearExpiredViewController` · `RequestTimeOffViewController` · `InboxApprovalListTimeOffController` | Time-off index (`/page/time-off`) · Team time-off index (`/page/team-time-off`) · Request form (`/page/request-time-off`) | `TimeOffIndexFragment` · `RequestTimeOffIndexFragment` · `DelegationTimeOffIndexFragment` · `RequestTimeOffActivity` · `DetailRequestTimeOffActivity` · `TimeOffBalanceActivity` · `DetailDelegationTimeOffActivity` | `RequestTimeOffScreen` |
| Widget | — | — | — | `SelectTimeOffPolicyBottomSheet` · `SelectTimeOffDurationTypeBottomSheet` · `SelectTimeOffDelegationBottomSheet` |
| State holder | `DashboardViewModel` · `RequestTimeOffViewModel` · `TimeOffNearExpiredViewModel` · `InboxApprovalListTimeOffViewModel` | — | `TimeOffIndexPresenter` · `RequestTimeOffPresenter` · `DetailRequestTimeOffPresenter` · `TimeOffBalancePresenter` · `TimeOffAllTakenPresenter` · `RequestTimeOffIndexPresenter` · `DelegationTimeOffIndexPresenter` · `SelectTimeOffEmployeeDialogPresenter` | `PostRequestTimeOffBloc` · `CheckMultipleShiftTimeOffBloc` · `GetTimeOffPoliciesWithDelegateBloc` · `GetTimeOffDelegationsBloc` |
| Navigation | `DashboardCoordinator` · `RequestTimeOffCoordinator` · `TimeOffNearExpiredCoordinator` · `InboxApprovalListTimeOffCoordinator` | `TimeManagementManager` · `TalentaModule` (bridge launchers) | — | — |
| Use case | `GetTimeOffDataUseCase` · `GetTimeOffEmployeeListUseCase` (TalentaTM only) | — | `PostRequestTimeOffUseCase` · `GetTimeOffPoliciesWithDelegateUseCase` · `CheckMultipleShiftTimeOffUseCase` · `GetTimeOffDelegationsUseCase` · `GetTakenTimeOffHistoryUseCase` · `GetTimeOffBalanceHistoryUseCase` · `GetHistoryDelegationTimeOffUseCase` · `GetTimeOffSubordinateEmployeeListUseCase` · `CheckTakenTimeOffHistoryCacheUseCase` · `GetHistoryRequestTimeOffUseCase` · `GetDetailTimeOffUseCase` · `CancelRequestTimeOffUseCase` | `PostRequestTimeOffUseCase` · `GetTimeOffPoliciesWithDelegateUseCase` · `GetTimeOffDelegationsUseCase` · `CheckMultipleShiftTimeOffUseCase` |
| Repository | `TimeOffRepository` / `TimeOffRepositoryImpl` (TalentaTM only) | — | `TimeOffRepository` / `TimeOffRepositoryImpl` | `TimeOffRepository` / `TimeOffRepositoryImpl` |
| Service / data source | `RequestTimeOffNetworkServiceImpl` · `TimeOffDataRequest` (Moya) · `TimeOffRequestApi` (bulk inbox) | — | `TimeOffApi` (Retrofit) | `TimeOffRemoteDataSource` / `TimeOffRemoteDataSourceImpl` |
| Domain entity | — | — | — | `TimeOffItem` · `RequestTimeOffResult` · `CheckMultipleShiftTimeOff` · `UserTimeOffDelegate` · `TimeOffPolicyDelegateItem` |
| DI module | — | — | `FeatureTimeOffModule` | — |

---

**Platform Variants**

- **iOS** [pre-Clean]: Mixed. Primary time-off index, team index, and request form are Flutter-owned — iOS only launches them via `TalentaModule` (BricksAddress bridge). A partial Clean layer (`GetTimeOffDataUseCase` → `TimeOffRepository` → `TimeOffRepositoryImpl`) exists inside the `TalentaTM` module for the request form's policy/user data fetch. All other screens — history, detail, delegation detail, balance overview, near-expired balance — are legacy native ViewControllers calling `TimeOffDataRequest` (Moya) directly, bypassing the Clean layer entirely. Navigation uses Coordinator pattern throughout.

- **Android** [pre-Clean / hybrid]: MVP + Clean Architecture hybrid. `Fragment`/`Activity` → `Presenter` (no ViewModel class anywhere in the feature; Presenter fills that role) → `UseCase` → `TimeOffRepository` (interface) → `TimeOffRepositoryImpl` → `TimeOffApi` (Retrofit). Domain and data layers are properly separated, but the presentation layer uses MVP Contracts rather than MVVM/ViewModel — making it a hybrid, not pure Clean. `TimeOffRepositoryImpl` applies a cache-first strategy backed by `SessionPreference` (SharedPreferences). Cross-feature dependency: `GetMultiLiveAttendanceUseCase` from live attendance domain is injected into `RequestTimeOffPresenter` for shift schedule resolution.

- **Flutter** [Clean]: Pure BLoC + Clean Architecture. `Screen`/`Widget` → `BLoC` → `UseCase` → `TimeOffRepository` (interface) → `TimeOffRepositoryImpl` → `TimeOffRemoteDataSourceImpl`. Remote-only — no local data source. BLoC state is split across two directories: `blocs/request_time_off/` (3 BLoCs for submission flow) and `blocs/get_time_off_delegations/` (1 BLoC with paginated load-more). Flutter is the canonical owner of the time-off index, team index, and request form UI; iOS wraps it via the native–Flutter bridge.

---

**Gotchas / Known Constraints**

- **iOS native fallback bypasses the Clean layer (architectural risk).** When Flutter emits `ACTION_OPEN_PAGE` with `CREATE_TIME_OFF_REQUEST_ACTIVITY`, control transfers to `RequestTimeOffCoordinator` → `RequestTimeOffViewController` → `RequestTimeOffNetworkServiceImpl` → `TimeOffDataRequest` (Moya). The `TalentaTM` Clean UseCase/Repository is not involved. Any validation or business logic added to the Clean UseCases will not apply to this path — bugs fixed in the Clean layer may still reproduce on iOS native.

- **Android cache-first may serve stale data.** `TimeOffRepositoryImpl` uses a `networkBoundHandler` backed by `SessionPreference` (SharedPreferences). On repeat visits, the cached policy list and request history may be returned without a network call. This has caused display bugs where an approved/cancelled request still appears pending.

- **Android POST uses multipart; Flutter POST does not.** `TimeOffApi.postRequestTimeOff` sends `multipart/form-data` with optional file attachments. `TimeOffRemoteDataSourceImpl.postRequestTimeOff` in Flutter does not — `PostRequestTimeOffParams.files` is typed `List<dynamic>` with a documented TODO; the concrete type `AttachmentData` lives in the presentation layer, violating domain independence. File attachment behavior on Flutter is unreliable until this is resolved.

- **`/time-off/taken-list/{param}` path param name mismatch.** iOS calls it with `policyCode`; Android calls it with `policyId`. Confirm with the backend contract which is authoritative — a mismatch here can cause 404s on one platform when policies are renamed.
