---
platform: flutter
project: flutter-qontak-chat
discipline: engineering
topic: dependency_injection
pattern: chat_di
---

## Theory

Qontak Chat uses `get_it` manually — no `injectable` code generation. The app module is the DI root. Feature packages each expose a static `register*()` method; `ChatDi.initDependency()` calls them in dependency order.

**Deviation from `flutter/` base:** `flutter/` base uses `@injectable`/`@lazySingleton` annotations with code generation. Qontak Chat uses manual `registerLazySingleton`/`registerFactory` calls and a typed accessor per module.

## Code Pattern

```
engine.dart
  └── ChatDi.initDependency()
        ├── CoreDependency.registerCore()          ← chat_core (networking, logger, prefs)
        ├── ContactDependency.registerContact()    ← chat_contact
        ├── ComposerDependency.registerComposer()  ← chat_composer
        ├── MessagingDependency.registerMessaging()
        ├── InboxDependency.registerInbox()
        ├── ConversationDependency.registerConversation()
        ├── CallDependency.registerCall()
        ├── MainDependency.registerMain()          ← app-level (depends on all above)
        └── ChatNotificationDependency.registerChatNotification()
```

```dart
// Module DI accessors — typed aliases for GetIt.instance
coreDependency<NavigationHelper>()
inboxDependency<GetRoomByIdUseCase>()
messagingDependency<GetMessageByIdUseCase>()
contactDependency<ContactRemoteDataSource>()
composerDependency<UploadFollowUpMediaUseCase>()
mainDependency<GetFirstRunUseCase>()
```

```dart
// App-level MainDependency — _registerData → _registerDomain → _registerPresentation
class MainDependency {
  static void registerMain() {
    _registerData();
    _registerDomain();
    _registerPresentation();
  }

  static void _registerPresentation() {
    mainDependency
      ..registerFactory(() => BottomNavigationBloc(
            getUnreadRoomCount: mainDependency(),
            subscribeMessageUseCase: mainDependency(),
          ))
      ..registerFactory(() => NotificationTrayBloc(
            getInitialMessageUseCase: mainDependency(),
          ));
  }
}
```

```dart
// BLoC resolved at route time in route_manager.dart
case QontakAppRoute.login:
  return BlocProvider(
    create: (_) => LoginBloc(
      getSSOTokenUseCase: mainDependency(),
      prefHelper: coreDependency(),
    ),
    child: const LoginScreen(),
  );
```

## Definition

**Scope rules:**

| Method | Scope | Use for |
|---|---|---|
| `registerLazySingleton` | Singleton, on first access | DataSources, Repositories, Use Cases, Services |
| `registerSingleton` | Singleton, eagerly | Services requiring immediate init |
| `registerFactory` | New instance per call | BLoCs, Cubits |

**Never `registerLazySingleton` for BLoCs** — use `registerFactory` so `BlocProvider` gets a fresh instance.
