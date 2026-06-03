---
platform: flutter
project: flutter-qontak-crm
discipline: engineering
topic: app
pattern: module_registration
---

## Theory

CRM uses a Melos monorepo. The root app package is the app-shell only; all feature code lives in `features/` as independent Flutter packages. Each feature implements `BaseModule` from `crm_core`. The app aggregates them via a `featureModules` list.

## Code Pattern

```dart
// features/crm_core/lib/src/base/base_module.dart
abstract class BaseModule {
  LocalizationsDelegate<dynamic>? localizationsDelegate();
  List<CollectionSchema> collectionSchemas();
}
```

```dart
// features/crm_company/lib/src/crm_company.dart
class CRMCompanyModule implements BaseModule {
  @override
  LocalizationsDelegate<dynamic>? localizationsDelegate() {
    if (FlavorChecker.isPyridam) return PyridamCompanyLocalizations.delegate;
    if (FlavorChecker.isKrasSalesGo) return KrasCompanyLocalizations.delegate;
    return CompanyLocalizations.delegate;
  }

  @override
  List<CollectionSchema> collectionSchemas() => [CompanyDbSchema];
}
```

```dart
// lib/configs/modules.dart
final List<BaseModule> featureModules = [
  CRMCompanyModule(),
  CRMContactModule(),
  CRMDealModule(),
  CRMTaskModule(),
  CRMNoteModule(),
  CRMTicketModule(),
  CRMProductModule(),
  CRMLiveGpsModule(),
  QontakCommonModule(),
];
```

**Feature package internal layout:**

```
features/crm_company/
└── lib/src/
    ├── crm_company.dart        ← BaseModule implementation
    ├── config/
    │   ├── constants/
    │   ├── di/                 ← QontakCompanyDependency
    │   ├── l10n/
    │   ├── objectbox/
    │   └── utils/
    ├── data/
    │   ├── data_sources/local/ + remote/
    │   ├── database/           ← Isar + ObjectBox
    │   ├── mappers/
    │   ├── models/local/ + remote/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── bloc/
        ├── screens/
        └── widgets/
```

## Definition

**Adding a new feature package:**
1. Create `features/crm_<domain>/` with the standard layout
2. Declare in `melos.yaml` under `packages:`
3. Add to root `pubspec.yaml` as a path dependency
4. Implement `BaseModule` → add to `featureModules` in `lib/configs/modules.dart`
5. Create `Qontak<Feature>Dependency` → call `register<Feature>()` from `CrmDi.initDependency()`
6. Run `melos bootstrap` to re-link packages

**Public API contract:** Each feature exports only its public API through the barrel file. Cross-feature code must import via the public barrel — never via relative paths across package boundaries.
