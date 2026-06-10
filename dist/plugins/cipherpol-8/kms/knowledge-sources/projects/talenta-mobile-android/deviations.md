# Architecture Deviations — talenta-mobile-android

## Custom MVP Pattern (MvpPresenter)

**Standard:** Android standard architecture recommends MVVM with Jetpack ViewModel for state management.
**This project:** Uses a custom MVP pattern (`MvpPresenter<V>` / `MvpView`) defined in the `base` module. Activities and Fragments extend `BaseMvpVbActivity` / `BaseMvpVbFragment` which bind a Presenter, not a ViewModel. Some newer screens use `BaseVbActivity` / `BaseVbFragment` without any presenter (ViewBinding only).
**Location:** base/src/main/java/co/talenta/base/view/BaseMvpVbActivity.kt, BaseMvpVbFragment.kt, presenter/MvpPresenter.kt, presenter/BasePresenter.kt

## Dagger 2 with dagger.android (no Hilt)

**Standard:** Android standard since ~2021 recommends Hilt (wrapper over Dagger 2).
**This project:** Uses plain Dagger 2 with `dagger.android` pattern (AndroidInjector, `@ContributesAndroidInjector` implied by binding modules). DI is wired via `MainComponent` in app/src/main/java/co/talenta/di/. No `@HiltAndroidApp` or `@AndroidEntryPoint` annotations found.
**Location:** app/src/main/java/co/talenta/di/MainComponent.kt

## Custom error handler chain (TalentaErrorHandler + DefaultErrorHandler)

**Standard:** Standard Android error handling uses either sealed classes returned from ViewModel or a centralized Crashlytics log in the data layer.
**This project:** Implements a custom `TalentaErrorHandler` that wraps `DefaultErrorHandler`, adds Crashlytics reporting, and delegates navigation side effects. Injected into Presenters.
**Location:** base/src/main/java/co/talenta/base/error/TalentaErrorHandler.kt, DefaultErrorHandler.kt

## RxJava 3 Reactive Streams (no Coroutines)

**Standard:** Android standard since ~2021 prefers Kotlin Coroutines + Flow.
**This project:** Uses RxJava 3 throughout the data layer (Retrofit RxAdapter, Room RxJava3, `rxAndroid3`, `rxBinding4`). No coroutines found in data/domain layers.
**Location:** data/build.gradle, app/build.gradle

## Monorepo with feature modules sharing a single `data` and `domain` module

**Standard:** Multi-module Android projects typically scope data/domain layers per feature or use a shared core with feature-specific repositories.
**This project:** Has a single top-level `data/` module and a single top-level `domain/` module shared by all 22 feature modules. Feature modules do not own their own repositories or use cases — they import directly from the central data/domain modules.
**Location:** data/, domain/, app/build.gradle (project dependencies list)

## Encrypted local database (SQLCipher)

**Standard:** Standard Android apps use unencrypted Room/SQLite or rely on file-system-level encryption.
**This project:** Uses SQLCipher for database encryption alongside standard Room. Both `sqlCipher` and `androidxSqlite` dependencies are present.
**Location:** app/build.gradle, data/build.gradle

## Offline CICO with WorkManager sync

**Standard:** Standard attendance apps are online-only.
**This project:** `feature_portal` implements offline Clock-In/Clock-Out (CICO) with a `SyncOfflineLogWorker` and `SyncEmployeeWorker` using WorkManager to sync queued records when connectivity is restored.
**Location:** feature_portal/src/main/java/co/talenta/feature_portal/workmanager/
