# app — ios-talenta

| Pattern | Description |
|---|---|
| `analytics_constants` | Event names and screen identifiers declared as a Swift struct in the feature's `Constants/` directory. |
| `deeplink_registration` | All deeplink sources converge on `DeeplinkStreamImpl.shared` — coordinators subscribe and never parse URLs directly. |
| `dependency_registration` | iOS uses Needle — a compile-time, hierarchical component tree where each feature has its own `Component<DependencyType>`. |
| `feature_flag_registration` | iOS uses `MekariFlagCustomProvider` backed by the MekariFlag SDK — add a case to `FeatureIdentity` for a new flag. |
| `push_notification_registration` | Push notifications and deeplinks share the same delivery path, both writing to `DeeplinkStreamImpl.shared`. |
| `route_registration` | iOS uses the Coordinator pattern with `BaseCoordinator<ResultType>`. |
