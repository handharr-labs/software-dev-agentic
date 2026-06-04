# Third-Party Integrations — flutter-mobile-talenta

| # | Integration | Package | Version | Purpose |
|---|---|---|---|---|
| 1 | Firebase Analytics | `firebase_analytics` | 11.3.6 | Event tracking |
| 2 | Firebase Crashlytics | `firebase_crashlytics` | 4.2.0 | Crash reporting |
| 3 | Firebase Performance | `firebase_performance` | 0.10.0+11 | Performance monitoring |
| 4 | Firebase Remote Config | `firebase_remote_config` | 5.2.0 | Feature flags / remote config |
| 5 | Firebase Core | `firebase_core` | 3.9.0 | Firebase bootstrap |
| 6 | Mekari Network (`mekari_network`) | Internal Bitbucket | network-1.6.1 | HTTP client (Dio wrapper) |
| 7 | Network Inspector | Internal Bitbucket | network_inspector-1.3.x | Debug network inspection overlay |
| 8 | Auth Module (`auth_module`) | Internal Bitbucket | auth_module-1.41.0 | SSO/auth token lifecycle |
| 9 | Mekari Pixel (`mekari_pixel`) | Internal Bitbucket | v2.22.0 | Mekari design system UI components |
| 10 | Mekari Pixel Illustrations | Internal Bitbucket | illustrations-1.4.0 | Illustration assets |
| 11 | Mekari Flag (`mekari_flag`) | Internal Bitbucket | flag-1.7.0 | Feature flag client |
| 12 | Mekari QA Tools (`mekari_qa_tools`) | Internal Bitbucket | qa_tools-1.0.5 | QA overlays / device preview |
| 13 | Mekari Log (`mekari_log`) | Internal Bitbucket | log-1.38.2 | Structured logging |
| 14 | Brick Way (`brick_way`) | Internal Bitbucket | v1.21.3 | Brick-based server-driven UI (page/dialog/bottom-sheet) |
| 15 | MQTT Client (`mqtt_client`) | pub.dev | 10.5.1 | Real-time push for inbox/live tracking via MQTT broker (VerneMQ) |
| 16 | Flutter Background Service | `flutter_background_service` | 5.1.0 | MQTT persistence in background |
| 17 | Google Maps Flutter | `google_maps_flutter` | 2.2.5 | Map display for attendance/live tracking |
| 18 | Background Geolocation | `flutter_background_geolocation` | 4.18.0 | Live tracking waypoint collection |

## Internal Packages (Mekari Bitbucket)

All internal packages are hosted on Mekari's private Bitbucket. Versions are pinned via `dependency_overrides` in both `talenta_module/pubspec.yaml` and host `pubspec.yaml`.
