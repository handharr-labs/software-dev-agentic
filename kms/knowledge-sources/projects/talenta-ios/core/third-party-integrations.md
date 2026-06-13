---
scope: project/talenta-ios
platform: ios
discipline: engineering
artifact: third-party-integrations
---
# Third-Party Integrations

## Firebase Core

- package: FirebaseCore 11.4.0
- purpose: Foundation for all Firebase services
- layer: Infrastructure (Services/Firebase/)

## Firebase Analytics

- package: FirebaseAnalytics 11.4.0
- purpose: User behaviour and event tracking
- layer: Infrastructure (Services/Firebase/)

## Firebase Crashlytics

- package: FirebaseCrashlytics 11.4.0
- purpose: Crash reporting and diagnostics
- layer: Infrastructure (Services/Firebase/)

## Firebase Remote Config

- package: FirebaseRemoteConfig 11.4.0
- purpose: Remote configuration and feature flags via Firebase
- layer: Infrastructure (Talenta/RemoteConfig/)

## Firebase Messaging

- package: FirebaseMessaging 11.4.0
- purpose: Push notification delivery
- layer: Infrastructure (Shared/Infrastructure/Notifications/)

## Firebase Database

- package: FirebaseDatabase 11.4.0
- purpose: Real-time data synchronisation
- layer: Data

## Firebase Auth

- package: FirebaseAuth 11.4.0
- purpose: User authentication via Firebase
- layer: Data

## Firebase Performance

- package: FirebasePerformance 11.4.0
- purpose: App performance monitoring (network, traces)
- layer: Infrastructure

## Firebase Dynamic Links

- package: FirebaseDynamicLinks 11.4.0
- purpose: Deep linking support for deferred/contextual links
- layer: AppLayer/Deeplink/

## Firebase App Check

- package: FirebaseAppCheck 11.4.0
- purpose: App integrity verification to prevent API abuse
- layer: Infrastructure

## RxSwift

- package: RxSwift ~> 6.5
- purpose: Reactive programming framework; used throughout ViewModels and data pipelines
- layer: Presentation / Data

## RxCocoa

- package: RxCocoa ~> 6.5
- purpose: RxSwift extensions for UIKit bindings
- layer: Presentation

## RxDataSources

- package: RxDataSources
- purpose: Reactive table view and collection view data sources
- layer: Presentation

## RxTest

- package: RxTest ~> 6.5
- purpose: Testing utilities for RxSwift observables
- layer: TalentaTests (test only)

## Moya

- package: Moya ~> 15.0
- purpose: Network abstraction layer; all API endpoints modelled as Swift enums
- layer: Data (Middleware/Network/)

## Moya RxSwift Integration

- package: Moya/RxSwift ~> 15.0
- purpose: RxSwift integration for Moya network requests
- layer: Data

## GoogleMaps

- package: GoogleMaps (via CocoaPods)
- purpose: Map rendering for location-based attendance (live attendance, location selection)
- layer: Presentation / Data

## Google Utilities

- package: GoogleUtilities
- purpose: Required utilities for Firebase SDKs
- layer: Infrastructure

## BiometricAuthentication

- package: BiometricAuthentication ~> 2
- purpose: Touch ID and Face ID authentication
- layer: Presentation (Controllers/Login/, Controllers/PIN/)

## SwiftyCam

- package: SwiftyCam
- purpose: Camera functionality for attendance selfie/photo capture
- layer: Presentation (Module/TalentaTM/Presentation/View/FrontCamera/)

## R.swift

- package: R.swift (via CocoaPods)
- purpose: Type-safe access to images, strings, storyboards, and other resources
- layer: Cross-cutting (code generation)

## NotificationBannerSwift

- package: NotificationBannerSwift ~> 3
- purpose: In-app notification banner display
- layer: Presentation

## MekariFlag

- package: MekariFlag 0.1.0 (private Mekari pod)
- purpose: Feature flag management system (Mekari internal)
- layer: Infrastructure (Shared/Infrastructure/FeatureFlag/, Utils/MekariFlag/)

## MekariAttachment

- package: MekariAttachment (local path: ./MekariAttachment/)
- purpose: File attachment handling for forms and submissions
- layer: Data / Presentation

## MekariPixel

- package: MekariPixel (local path: ./MekariPixel/)
- purpose: Mekari internal analytics and tracking pixel
- layer: Infrastructure (Services/Moengage/, MekariPixel/)

## NeedleFoundation

- package: NeedleFoundation (via Package.swift / SPM)
- purpose: Compile-time safe dependency injection framework (Uber)
- layer: Cross-cutting (DIComponents/)

## Mixpanel

- package: Mixpanel (keys managed via cocoapods-keys)
- purpose: Product analytics and funnel tracking
- layer: Infrastructure (Services/)

## MoEngage

- package: MoEngage (keys managed via cocoapods-keys)
- purpose: User engagement platform; push notifications and in-app campaigns
- layer: Infrastructure (Services/Moengage/)

## Microsoft Clarity

- package: Clarity (key: ClarityDevKey via cocoapods-keys)
- purpose: User session recording and heatmaps for UX insights
- layer: Infrastructure (Shared/Infrastructure/Analytics/)

## Flagsmith (EXM)

- package: Flagsmith (keys: EXMFlagsmithKeyProd, EXMFlagsmithKeyStag via cocoapods-keys)
- purpose: Feature flag service for Expense Management module
- layer: Infrastructure (Shared/Infrastructure/FeatureFlag/)

## FloatingPanel

- package: FloatingPanel (used via CustomFloatingPanelLayout)
- purpose: iOS floating panel (bottom sheet) UI component
- layer: Presentation (Views/Common/CustomFloatingPanelLayout.swift)

## Wormholy

- package: Wormholy (non-production builds only)
- purpose: In-app network request debugger
- layer: Debug/Development

## FLEX

- package: FLEX (non-production builds only)
- purpose: In-app UI and runtime debugger
- layer: Debug/Development

## brick_house (Flutter module)

- package: brick_house (git: bitbucket.org/mid-kelola-indonesia/brick-house.git, branch: develop/talenta)
- purpose: Embedded Flutter module providing Account, Auth, Calendar, Cashout, EXM, Inbox, Payslip, Performance, Task, TimeManagement features
- layer: Presentation / BrickWrap/

## TSBackgroundFetch

- package: TSBackgroundFetch (static xcframework, transitive from flutter_background_geolocation via brick_house)
- purpose: Background location fetch for live tracking in Flutter module
- layer: Data (BrickWrap/Modules/TimeManagement/)
