# app — android-talenta

| Pattern | Description |
|---|---|
| `analytics_constants` | Feature-scoped `object` with `const val` event names — no logic, no SDK imports, snake_case string values. |
| `deeplink_registration` | All deeplinks enter via `RedirectionActivity` — URL patterns in `UrlHelper`, routing via Navigation interface. |
| `dependency_registration` | Dagger 2 `@Module` + `@Binds` + `@ContributesAndroidInjector` per feature; `MainComponent` assembles the graph. |
| `feature_flag_registration` | Three flag types: `LocalFeatureFlag`, `RemoteConfigFeatureFlag`, `FlagsmithFeatureFlag` — always provide description and link. |
| `hybrid_embedding` | Flutter-in-Android via bricks-talenta — `BricksEngineManager`, `BrickActivity`, `BrickHelper` HostParams assembly, `TalentaModule`. |
| `module_registration` | Two-part: Gradle wiring (`settings.gradle` + `app/build.gradle`) and Dagger wiring (`MainComponent`) — both required. |
| `planner_search_patterns` | Glob patterns for DI modules, navigation interfaces, Gradle wiring, analytics constants, feature flags, and hybrid embedding. |
| `push_notification_registration` | Centralised in `TalentaNotificationManagerImpl` — `PostFcmTokenUseCase` on login, `DeleteFcmTokenUseCase` on logout. |
| `route_registration` | Interface-based navigation — interface in `base/navigation/`, impl in `app/navigator/`, bound in `NavigationModule`. |
