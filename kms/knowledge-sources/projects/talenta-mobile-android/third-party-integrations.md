# Third-Party Integrations — talenta-mobile-android

Source: `dependencies.gradle`, `app/build.gradle`, feature module `build.gradle` files.

## Analytics & Crash Reporting
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Firebase Analytics | `com.google.firebase:firebase-analytics` | BoM 33.7.0 | Event tracking |
| Firebase Crashlytics | `com.google.firebase:firebase-crashlytics-ktx` | BoM 33.7.0 | Crash reporting |
| Firebase Performance | `com.google.firebase:firebase-perf-ktx` | BoM 33.7.0 | App performance monitoring |
| MoEngage SDK | `com.moengage:moe-android-sdk` | 13.06.00 | User engagement, push, in-app |
| MoEngage InApp | `com.moengage:inapp` | 8.8.1 | In-app messaging |
| MoEngage GeoFence | `com.moengage:geofence` | 4.3.0 | Geo-fencing triggers |
| MoEngage HMS PushKit | `com.moengage:hms-pushkit` | 5.2.0 | Huawei push support |
| Mixpanel | `com.mixpanel.android:mixpanel-android` | 7.5.2 | Product analytics |
| Microsoft Clarity | `com.microsoft.clarity:clarity` | 3.5.1 | Session replay / heatmaps |

## Messaging & Push
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Firebase Cloud Messaging | `com.google.firebase:firebase-messaging-ktx` | BoM 33.7.0 | Push notifications |
| Eclipse Paho MQTT | `org.eclipse.paho:org.eclipse.paho.client.mqttv3` | 1.2.5 | Real-time live tracking pub/sub via VerneMQ |

## Authentication & Security
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Firebase Auth | `com.google.firebase:firebase-auth` | BoM 33.7.0 | Firebase token auth |
| Firebase App Check | `com.google.firebase:firebase-appcheck-ktx` | BoM 33.7.0 | App attestation |
| Google Play Integrity | `com.google.android.play:integrity` | 1.5.0 | Device integrity verification |
| SQLCipher | `net.zetetic:sqlcipher-android` | 4.7.2 | Encrypted local database |
| RootBeer | `com.scottyab:rootbeer-lib` | 0.1.1 | Root detection |
| FingerprintJS | `com.github.fingerprintjs:fingerprint-android` | 2.2.0 | Device fingerprinting for CICO |
| AndroidX Biometric | `androidx.biometric:biometric` | 1.1.0 | Fingerprint/face biometric auth |
| Mekari Security libs | Internal (`lib_core_mekari_pixel`, `lib_core_network`) | — | Certificate pinning, secure prefs |

## Networking
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Retrofit 2 | `com.squareup.retrofit2:retrofit` | 2.9.0 | REST API client |
| OkHttp 3 | `com.squareup.okhttp3:okhttp` | BoM 4.9.3 | HTTP transport layer |
| Gson | `com.google.code.gson:gson` | 2.8.6 | JSON serialization/deserialization |
| Chucker | `com.github.chuckerteam.chucker:library` | 3.5.2 | Debug HTTP inspector (debug only) |

## Location & Maps
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Google Play Services Maps | `com.google.android.gms:play-services-maps` | 18.1.0 | Map display |
| Google Play Services Location | `com.google.android.gms:play-services-location` | 20.0.0 (pinned) | GPS, geofencing, location updates |
| Google Places | `com.google.android.libraries.places:places` | 2.7.0 | Place autocomplete |
| Mekari Location | `com.mekari.mobile:location` | 1.0.5 | Internal location utilities |
| TSLocationManager (flutter_background_geolocation) | `com.transistorsoft:tslocationmanager` | 3.7.0 | Background geolocation for live tracking |

## Customer Support
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Intercom | `io.intercom.android:intercom-sdk` | 15.4.0 | In-app support chat |

## UI Components
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Glide | `com.github.bumptech.glide:glide` | 4.16.0 | Image loading with OkHttp3 integration |
| Facebook Shimmer | `com.facebook.shimmer:shimmer` | 0.5.0 | Loading skeleton animation |
| Material Calendar View | `com.github.prolificinteractive:material-calendarview` | 2.0.1 | Calendar date picker |
| Balloon | `com.github.skydoves:balloon` | 1.5.4 | Tooltip popups |
| Progress Button | `com.github.razir.progressbutton:progressbutton` | 2.1.0 | Buttons with loading state |
| TSnackBar | `com.github.Redman1037:TSnackBar` | V2.0.0 | Top-positioned Snackbar |
| Simple Stack | `com.github.Zhuinden:simple-stack` | 2.3.2 | Back-stack management |
| SDP/SSP | `com.intuit.sdp/ssp-android` | 1.0.6 | Size/dimension resource scaling |
| Scrolling Page Indicator | `ru.tinkoff.scrollingpagerindicator` | 1.0.6 | ViewPager dot indicator |
| Circle Indicator | `me.relex:circleindicator` | 2.1.6 | ViewPager circle indicator |
| World Country Data | `com.github.blongho:worldCountryData` | v1.5 | Country/dial-code data |
| Mekari Pixel | `lib_core_mekari_pixel` (internal module) | — | Mekari design system (buttons, tabs, dialogs, app bar) |

## Reactive Programming
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| RxJava 3 | `io.reactivex.rxjava3:rxjava` | 3.0.6 | Async stream processing |
| RxAndroid 3 | `io.reactivex.rxjava3:rxandroid` | 3.0.0 | Android main thread scheduler |
| RxKotlin 3 | `io.reactivex.rxjava3:rxkotlin` | 3.0.1 | Kotlin extensions for RxJava |
| RxBinding 4 | `com.jakewharton.rxbinding4:rxbinding` | 4.0.0 | View event streams |

## Dependency Injection
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Dagger 2 | `com.google.dagger:dagger` | 2.50 | Compile-time DI |
| Dagger Android | `com.google.dagger:dagger-android` | 2.50 | Activity/Fragment injection support |

## Persistence
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Room | `androidx.room:room-runtime` | 2.6.1 | SQLite ORM |
| DataStore | AndroidX (via gradle) | — | Key-value storage |

## Firebase
| SDK | Artifact | Usage |
|---|---|---|
| Firebase Remote Config | `com.google.firebase:firebase-config-ktx` | Feature flag management |
| Firebase Realtime Database | `com.google.firebase:firebase-database-ktx` | Realtime data (feedback) |

## Mekari Internal SDKs
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| Mekari Commons | `com.mekari.mobile:commons` | 0.0.5 | Shared extension functions (`orEmpty`, `orZero`, etc.) |
| Mekari Flag | `com.mekari.mobile:flag` | 0.6.1 | Feature flag client |

## Background Work
| SDK | Artifact | Version | Usage |
|---|---|---|---|
| WorkManager | `androidx.work:work-runtime-ktx` | 2.9.1 | Deferrable background tasks |
| WorkManager RxJava3 | `androidx.work:work-rxjava3` | 2.9.1 | RxJava3 integration for workers |

## Developer Tools (debug/test)
| SDK | Usage |
|---|---|
| LeakCanary 2.14 | Memory leak detection (debug build only) |
| Chucker 3.5.2 | HTTP traffic inspector (debug build only) |
| Timber 5.0.1 | Structured logging |
| Jsoup 1.18.3 | HTML parsing |
| JodaTime 2.10.6 | Date/time manipulation |
