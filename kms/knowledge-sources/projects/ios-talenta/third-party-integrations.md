# Third-Party Integrations — ios-talenta

Platform: iOS (Swift/UIKit)
Source: Podfile, AppDelegate.swift, AuthService.swift, MekariFlagResponse.swift
Scanned: 2026-06-04

## Analytics & Monitoring

| Integration | Pod / SDK | Purpose | Notes |
|-------------|-----------|---------|-------|
| Firebase Analytics | `FirebaseAnalytics 11.4.0` | User behavior analytics | Pinned across all Firebase pods |
| Firebase Crashlytics | `FirebaseCrashlytics 11.4.0` | Crash reporting | Used in all build configs |
| Firebase Performance | `FirebasePerformance 11.4.0` | App performance traces | |
| Firebase Remote Config | `FirebaseRemoteConfig 11.4.0` | Feature flag V2 (inactive) + general config | |
| Mixpanel | `MixpanelTokenStag/Prod` (via `cocoapods-keys`) | Product analytics | Separate tokens per env |
| Microsoft Clarity | `ClarityDevKey` (via `cocoapods-keys`) | Session recording | `ClarityManager`; controlled by `isClarityEnabled` flag |
| Mekari Log | Internal (`MekariLogManager`) | Structured log shipping | Controlled by `isEnableTalentaModuleMekariLog` flag |

## Push Notifications & Engagement

| Integration | Pod / SDK | Purpose | Notes |
|-------------|-----------|---------|-------|
| Firebase Messaging (FCM) | `FirebaseMessaging 11.4.0` | Push notifications | Rich notifications via `NotificationServiceExtension` |
| MoEngage | `MoEngageSDK`, `MoEngageMessaging`, `MoEngageRichNotification` | User engagement, in-app messaging | `MoengageAppIdStag/Prod` keys; `MoengageHelper` |
| Firebase Dynamic Links | `FirebaseDynamicLinks 11.4.0` | Deep linking | Deferred deep links |

## Authentication & Security

| Integration | Pod / SDK | Purpose | Notes |
|-------------|-----------|---------|-------|
| OAuth2 (MekariOAuth2) | `OAuth2` (via Carthage/Pods) | SSO PKCE flow | `authorize_uri`, `token_uri` from `TalentaEnvironment`; Keychain storage |
| Kong API Gateway | `KongClientIdStag/PPE/Prod` | API authentication | Client ID injected via `cocoapods-keys` |
| BiometricAuthentication | `BiometricAuthentication ~> 2` | Touch ID / Face ID | `BiometricAuthService` |
| KeychainAccess | `KeychainAccess` | Secure token storage | Used in `AuthService` |
| Firebase App Check | `FirebaseAppCheck 11.4.0` | App integrity | Prevents API abuse |
| Firebase Auth | `FirebaseAuth 11.4.0` | Complementary auth | Used alongside SSO |

## Maps & Location

| Integration | Pod / SDK | Purpose | Notes |
|-------------|-----------|---------|-------|
| Google Maps | `GoogleMaps` | Map display for location-based CICO | `GoogleApiKeyStag/Prod` via `cocoapods-keys`; AppDelegate crash workaround applied |

## Networking & UI

| Integration | Pod / SDK | Purpose | Notes |
|-------------|-----------|---------|-------|
| Moya + RxSwift/RxCocoa | `Moya ~> 15`, `RxSwift/RxCocoa ~> 6.5` | Network abstraction + reactive programming | Core networking stack |
| RxDataSources | `RxDataSources` | Reactive table/collection data sources | |
| IQKeyboardManagerSwift | `IQKeyboardManagerSwift` | Auto keyboard avoidance | Enabled globally in AppDelegate |
| NotificationBannerSwift | `NotificationBannerSwift ~> 3` | In-app notification banners | |
| FloatingPanel | Dependency via BaseCoordinator | Draggable bottom panels | Coordinator-managed |
| R.swift | `R.swift` | Type-safe resource access | Images, localized strings, storyboards |

## Feature Flags

| Integration | Pod / SDK | Purpose | Notes |
|-------------|-----------|---------|-------|
| Flagsmith (MekariFlag) | `MekariFlag 0.1.0` (private Mekari pod) | Active feature flag management | `MekariFlagCustomProvider`; 20+ flags including `isEnableAnnouncementRevamp`, `isEnableRevampTimeOffRequest`, etc. |

## Debug Tools (Non-Production Only)

| Integration | Pod / SDK | Purpose | Notes |
|-------------|-----------|---------|-------|
| Wormholy | `Wormholy` | Network request inspector | Excluded from Release builds |
| FLEX | `FLEX` | In-app UI/runtime debugger | Excluded from Release builds |

## Flutter Bridge

| Integration | Pod / SDK | Purpose | Notes |
|-------------|-----------|---------|-------|
| brick_house (Flutter module) | `pub brick_house` via `cocoapods-embed-flutter` | Flutter-native bridge for Time Management features | `develop/talenta` branch; `flutter_downloader`, `flutter_background_geolocation` (TSBackgroundFetch static xcframework) |

## Internal Mekari Pods (Private Repository)

| Pod | Purpose |
|-----|---------|
| `MekariAttachment` (local path) | File attachment component |
| `MekariPixel` (local path) | Mekari design system |
| `MekariFlag 0.1.0` | Feature flag client |
| Source: `git@bitbucket.org:mid-kelola-indonesia/mekari-specs.git` | Private spec repo |
