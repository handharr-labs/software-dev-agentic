---
platform: flutter
project: flutter-qontak-crm
discipline: engineering
topic: dependency_injection
pattern: crm_di
---

## Theory

Qontak CRM uses `get_it` manually — `@injectable`/`@InjectableInit` annotations are forbidden. The app module is the DI root. Feature packages each expose a static `Dependency.register*()` method; `CrmDi.initDependency()` calls them in order.

All features share the **same** `GetIt.instance` — module accessor variables (`qontakCompanyDependency`, `qontakCoreDependency`, etc.) are aliases, not separate containers.

**Deviation from `flutter/` base:** Same as qontak-chat — manual `registerLazySingleton`/`registerFactory` instead of annotation-driven code generation.

## Code Pattern

```dart
// lib/engine.dart — boot sequence
Future<void> initEngine() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ObjectBoxInitializer.init();
  await CrmDi.initDependency();
  runApp(const CrmApp());
}
```

```dart
// lib/configs/di/crm_di.dart
class CrmDi {
  static Future<void> initDependency() async {
    QontakCommonDependency.registerCommon();   // 1. register first
    await GetIt.instance.allReady();           // await async deps
    QontakCoreDependency.registerCore();       // 2. core
    // 3. feature packages (order within this group does not matter)
    QontakCompanyDependency.registerCompany();
    QontakContactDependency.registerContact();
    QontakDealDependency.registerDeal();
    // ... other features
    QontakCrmDependency.registerApp();         // 4. app-level last
  }
}
```

```dart
// Feature DI class pattern
class QontakCompanyDependency {
  static void registerCompany() {
    _registerDatabase();
    _registerObjectBox();
    _registerCompanyData();
    _registerCompanyDomain();
  }

  static void _registerCompanyData() {
    qontakCompanyDependency
      ..registerLazySingleton<CompanyRemoteDataSource>(
          () => CompanyRemoteDataSourceImpl(baseApi: qontakCommonDependency()))
      ..registerLazySingleton<CompanyRepository>(
          () => CompanyRepositoryImpl(
                remoteDataSource: qontakCompanyDependency(),
                localDataSource: qontakCompanyDependency(),
              ));
  }

  static void _registerCompanyDomain() {
    qontakCompanyDependency
      ..registerLazySingleton(() => GetCompanyListUseCase(repository: qontakCompanyDependency()))
      ..registerLazySingleton(() => AddCompanyUseCase(repository: qontakCompanyDependency()));
  }
}
```

```dart
// BLoCs instantiated inline in route_manager.dart — never registered in GetIt
case AppRoute.company:
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => CompanyBloc(
        getCompanyListUseCase: qontakCompanyDependency(),
      ),
      child: const CompanyScreen(),
    ),
  );
```

```dart
// Cross-feature resolution — use source feature's accessor
qontakContactDependency.registerLazySingleton<ContactRepository>(
  () => ContactRepositoryImpl(
    companyLocalDataSource: qontakCompanyDependency(), // ← cross-module
    baseApi: qontakCommonDependency(),
  ),
);
```

## Definition

**Registration order:** Common → await allReady → Core → Features (any order) → App-level last.

**Scope rules:** Same as qontak-chat — `registerLazySingleton` for singletons, `registerFactory` for BLoCs. Never `registerLazySingleton` for BLoCs.
