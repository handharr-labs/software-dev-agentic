# Third-Party Integrations — talenta-mobile-android

## Firebase Authentication

- package: com.google.firebase:firebase-auth
- purpose: User authentication via Firebase
- layer: Data

## Firebase Crashlytics

- package: com.google.firebase:firebase-crashlytics
- purpose: Crash reporting and error tracking
- layer: Data / Base (via TalentaErrorHandler)

## Firebase Analytics

- package: com.google.firebase:firebase-analytics
- purpose: Event and user behaviour analytics
- layer: Data

## Firebase Cloud Messaging

- package: com.google.firebase:firebase-messaging
- purpose: Push notifications
- layer: App

## Firebase Remote Config

- package: com.google.firebase:firebase-config
- purpose: Remote feature flag configuration
- layer: Data

## Firebase Performance Monitoring

- package: com.google.firebase:firebase-perf
- purpose: App performance monitoring
- layer: App

## Firebase Realtime Database

- package: com.google.firebase:firebase-database
- purpose: Real-time data sync
- layer: Data

## Firebase App Check

- package: com.google.firebase:firebase-appcheck, firebase-appcheck-playintegrity
- purpose: Backend protection against fraudulent traffic
- layer: App

## MoEngage SDK

- package: com.moengage:moe-android-sdk
- purpose: Customer engagement, push notifications, in-app messaging
- layer: App (InAppCallback, ApplicationBackgroundListener, GeoFenceHitListener)

## MoEngage GeoFence

- package: com.moengage:moe-android-geofence
- purpose: Location-based engagement triggers
- layer: App

## MoEngage HMS Push Kit

- package: com.moengage:moe-android-hms
- purpose: Huawei push notification support via MoEngage
- layer: App

## MoEngage In-App

- package: com.moengage:in-app-nativ
- purpose: In-app message display
- layer: App

## Retrofit 2

- package: com.squareup.retrofit2:retrofit
- purpose: HTTP client for REST API calls
- layer: Data

## OkHttp 3

- package: com.squareup.okhttp3:okhttp, okhttp-logging-interceptor
- purpose: HTTP network layer with logging
- layer: Data

## Gson

- package: com.google.code.gson:gson
- purpose: JSON serialisation/deserialisation
- layer: Data

## RxJava 3

- package: io.reactivex.rxjava3:rxjava, rxandroid, rxkotlin
- purpose: Reactive programming for async data streams
- layer: Data / Domain / Presentation

## RxBinding 4

- package: com.jakewharton.rxbinding4:rxbinding
- purpose: Reactive bindings for Android UI events
- layer: Presentation

## Dagger 2

- package: com.google.dagger:dagger, dagger-android, dagger-android-support
- purpose: Dependency injection
- layer: All

## Room

- package: androidx.room:room-runtime, room-rxjava3
- purpose: Local database ORM
- layer: Data

## SQLCipher

- package: net.zetetic:android-database-sqlcipher
- purpose: Encrypted SQLite database
- layer: Data

## Glide

- package: com.github.bumptech.glide:glide
- purpose: Image loading and caching
- layer: Presentation

## Google Play Services Maps

- package: com.google.android.gms:play-services-maps
- purpose: Google Maps display for live attendance and live tracking
- layer: Presentation

## Google Play Services Location

- package: com.google.android.gms:play-services-location
- purpose: Fused location provider for attendance and tracking
- layer: Data / Feature

## Google Places

- package: com.google.android.libraries.places:places
- purpose: Location search/autocomplete
- layer: Presentation

## Google Play Integrity

- package: com.google.android.play:integrity
- purpose: Device integrity verification (anti-tampering)
- layer: Data (IntegrityApi.kt)

## Transistorsoft Background Geolocation

- package: com.transistorsoft:tslocationmanager
- purpose: Background location tracking for Live Tracking feature
- layer: feature_live_tracking (BackgroundGeoSource.kt)

## Intercom

- package: io.intercom.android:intercom-sdk
- purpose: In-app customer support messaging
- layer: lib_core_message (IntercomMessageProvider.kt)

## Mixpanel

- package: com.mixpanel.android:mixpanel-android
- purpose: Product analytics and event tracking
- layer: Data (CompanyApi.kt Mixpanel URL)

## WorkManager

- package: androidx.work:work-runtime, work-rxjava3
- purpose: Background task scheduling for offline sync (SyncOfflineLogWorker, SyncEmployeeWorker)
- layer: feature_portal

## Paging 3

- package: androidx.paging:paging-runtime, paging-rxjava3
- purpose: Paginated list loading
- layer: Presentation

## Timber

- package: com.jakewharton.timber:timber
- purpose: Logging utility
- layer: All

## JodaTime

- package: net.danlew:android.joda
- purpose: Date and time manipulation
- layer: Domain / Data

## Jetpack Navigation

- package: androidx.navigation:navigation-fragment-ktx, navigation-ui-ktx
- purpose: Fragment navigation graph
- layer: Presentation

## Jetpack Biometric

- package: androidx.biometric:biometric
- purpose: Fingerprint / biometric authentication
- layer: lib_core_biometric

## Mekari Commons

- package: co.mekari:mekari-commons (internal)
- purpose: Shared Mekari platform utilities
- layer: Data / App

## Mekari Flag

- package: co.mekari:mekari-flag (internal)
- purpose: Feature flag client for Mekari platform
- layer: Data

## Mekari Location

- package: co.mekari:mekari-location (internal)
- purpose: Mekari-platform location utilities
- layer: App

## Mekari Pixel (lib_core_mekari_pixel)

- package: internal module lib_core_mekari_pixel
- purpose: Design system / UI component library (Mekari Pixel design system)
- layer: Presentation

## RootBeer

- package: com.scottyab:rootbeer-lib
- purpose: Root detection for security checks
- layer: App (RootDetectionManagerImpl.kt)

## Jsoup

- package: org.jsoup:jsoup
- purpose: HTML parsing (announcement web content)
- layer: Presentation (AnnouncementWebView.kt)

## SDP / SSP

- package: com.intuit.sdp:sdp-android, com.intuit.ssp:ssp-android
- purpose: Scalable size units for responsive UI
- layer: Presentation (res)

## Balloon

- package: com.skydoves:balloon
- purpose: Tooltip/popover UI components
- layer: Presentation

## SimpleStack

- package: com.github.Zhuinden:simple-stack
- purpose: Navigation back-stack management
- layer: Presentation

## CircleIndicator

- package: me.relex:circleindicator
- purpose: ViewPager indicator dots
- layer: Presentation

## TopSnackbar

- package: com.github.tlaabs:TimetableView (or custom top snackbar lib)
- purpose: Top-positioned snackbar notifications
- layer: Presentation

## Google Play In-App Update

- package: com.google.android.play:app-update
- purpose: In-app update flow (flexible/immediate)
- layer: lib_core_version_update

## Google Play Feature Delivery

- package: com.google.android.play:feature-delivery
- purpose: Dynamic feature module delivery
- layer: Data / App

## CameraX

- package: androidx.camera:camera-*
- purpose: Camera capture for selfie attendance
- layer: lib_core_camera

## Apache Commons Lang 3

- package: org.apache.commons:commons-lang3
- purpose: General string/object utility functions
- layer: App
