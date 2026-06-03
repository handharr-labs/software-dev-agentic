---
platform: flutter
project: flutter-qontak-chat
discipline: engineering
topic: project_structure
pattern: project_structure
---

# Flutter Qontak — Project Structure & Conventions

---

## App Layout <!-- 46 -->

The application module (`qontak_chat_app`) is a standard Flutter app package. Feature code lives in **external pub packages** (not local path packages or a melos workspace). The app-level `lib/` contains only app-wiring, entry screens, and DI orchestration.

```
/ (application module root)
├── lib/
│   ├── main.dart                    ← delegates to engine.dart
│   ├── engine.dart                  ← runZonedGuarded, Firebase init, DI init, runApp
│   ├── app.dart                     ← MaterialApp widget + NotificationBloc listener
│   ├── route_manager.dart           ← AppRouteManager (centralized MaterialPageRoute switch)
│   ├── provider.dart                ← AppProvider (global MultiBlocProvider)
│   ├── config/
│   │   ├── di/                      ← DI orchestration
│   │   │   ├── chat_di.dart         ← ChatDi (orchestrates all module DI)
│   │   │   └── main_dependency.dart ← MainDependency (app-level registrations)
│   │   ├── constants/               ← DartDefine, enums, semantic IDs, route names
│   │   ├── environment/             ← Env, EnvType, EnvData (flavor config)
│   │   ├── firebase/                ← Firebase options per flavor
│   │   ├── localizations/           ← QontakChatLocalizations delegate
│   │   └── modules/                 ← Modules helper (stacked child bars)
│   ├── data/
│   │   ├── data_sources/            ← app-level data sources (e.g. ProductTourLocalDataSource)
│   │   ├── mapper/                  ← app-level mappers (e.g. RoomMapper, notification mappers)
│   │   └── repositories/            ← app-level repository implementations
│   ├── domain/
│   │   ├── models/                  ← app-level domain models
│   │   ├── repositories/            ← app-level repository interfaces
│   │   └── usecases/                ← app-level use cases
│   └── presentation/
│       ├── bloc/                    ← app-level BLoCs (login, product_tour, bottom_nav, etc.)
│       ├── screens/                 ← entry screens (splash, login, onboarding, main_page, rooms)
│       └── widgets/                 ← shared widgets (bottom nav, minimized calling, etc.)
├── android/
├── ios/
└── pubspec.yaml
```

**Rules:**
- `engine.dart` owns initialization order: Firebase → DB → DI → Bricks → runApp.
- `route_manager.dart` is the single routing authority — all `BlocProvider` wiring for route-scoped BLoCs lives here.
- `provider.dart` (`AppProvider`) wraps the app with a `MultiBlocProvider` for all global/app-wide BLoCs.
- App-level `lib/data`, `lib/domain`, and `lib/presentation` contain only app-shell concerns (splash, product tour, bottom nav). Feature code lives in the external packages.

---

## Module Types <!-- 11 -->

| Type | What it contains | Consumed as |
|---|---|---|
| **Application module** | `main.dart`, engine, DI orchestration, routing, entry screens | The Flutter app itself |
| **Feature packages** | Complete feature (data + domain + presentation) | External pub dependency (e.g. `chat_inbox`, `chat_messaging`) |
| **Core package** (`chat_core`) | Networking, base classes, shared BLoCs, interceptors | External pub dependency |
| **Qontak Common** (`qontak_common`) | Cross-app utilities, UseCase base, ViewDataState, Failure | External pub dependency |

---

## Dependency Graph <!-- 18 -->

```
qontak_chat_app (application)
  └─ chat_core
  └─ chat_inbox
  └─ chat_messaging
  └─ chat_conversation
  └─ chat_contact
  └─ chat_call
  └─ chat_composer
  └─ qontak_common (via chat_core re-export)
```

**Rule:** The application module depends on feature packages. Feature packages must NOT depend on each other — cross-package data sharing uses typedef callbacks injected at the DI layer (see `ChatDi`).

---

## App-Level Folder Structure <!-- 49 -->

The app module uses Clean Architecture in its own `lib/` for app-shell features only (product tour, bottom navigation, notification handling):

```
lib/data/
├── data_sources/
│   └── local/
│       └── product_tour_local_data_source.dart   ← abstract + impl in one file
├── mapper/
│   ├── room_notification_mapper.dart
│   ├── email_notification_mapper.dart
│   └── message_notification_mapper.dart
└── repositories/
    └── product_tour_repositories.dart

lib/domain/
├── models/                                       ← freezed domain models
├── repositories/
│   └── product_tour_repository.dart              ← abstract interface
└── usecases/
    ├── get_first_run_usecase.dart
    └── set_first_run_usecase.dart

lib/presentation/
├── bloc/
│   ├── login/
│   ├── product_tour/
│   ├── bottom_navigation/
│   ├── notification_tray/
│   ├── nav_bar/
│   └── app_initialization/
├── screens/
│   ├── splash_screen/
│   ├── login/
│   ├── onboarding/
│   ├── room/
│   ├── main_page.dart
│   ├── contact_screen.dart
│   ├── file_share_handler_screen.dart
│   └── file_share_preview_screen.dart
└── widgets/
    ├── chat_bottom_navigation.dart
    ├── minimized_calling.dart
    └── multiple_room_selection.dart
```

---

## Package Naming Conventions <!-- 12 -->

| What | Pattern | Example |
|---|---|---|
| Feature package | `[prefix]_[domain]` | `chat_inbox`, `chat_messaging` |
| Core shared | `[prefix]_core` | `chat_core` |
| Module dependency accessor | `[prefix]Dependency()` | `coreDependency()`, `inboxDependency()` |
| App-level DI class | `[Domain]Dependency` | `MainDependency`, `ChatDi` |
| Route constant class | `[Prefix]AppRoute` | `QontakAppRoute` |

---

## Model Naming (Data Layer) <!-- 12 -->

| Type | Suffix | Example |
|---|---|---|
| API response model | `Response` | `LoginResponse` |
| API request body | `Request` | `LoginRequest` |
| Database entity (DTO) | `Db` | `UserDb` |
| Domain entity | _(none)_ | `User` |
| Notification mapper | `Mapper` | `RoomNotificationMapper` |

---

## Mapper Convention <!-- 11 -->

Mapper is a non-instantiable class with static methods named `from{Source}To{Destination}`:

```dart
class RoomMapper {
  const RoomMapper._();

  static Room fromNotification({required RoomNotification notification}) => ...;
}
```
