# Flutter — Project Structure & Conventions

---

## Feature Folder Structure <!-- 78 -->

Each feature is self-contained under `lib/src/features/<feature_name>/`.

```
lib/
└── src/
    ├── features/
    │   └── employee/
    │       ├── configs/
    │       │   ├── employee_dependencies.dart   ← DI init (if feature-scoped)
    │       │   └── employee_endpoints.dart      ← route constants for this feature
    │       ├── data/
    │       │   ├── datasources/
    │       │   │   ├── employee_remote_data_source.dart
    │       │   │   └── employee_remote_data_source_impl.dart
    │       │   ├── mappers/
    │       │   │   └── employee_mapper.dart
    │       │   ├── models/
    │       │   │   ├── employee_model.dart
    │       │   │   └── update_employee_payload.dart
    │       │   └── repositories/
    │       │       └── employee_repository_impl.dart
    │       ├── domain/
    │       │   ├── entities/
    │       │   │   └── employee_entity.dart
    │       │   ├── enums/
    │       │   │   └── employment_type.dart
    │       │   ├── errors/
    │       │   │   └── failure.dart
    │       │   ├── repositories/
    │       │   │   └── employee_repository.dart
    │       │   ├── services/
    │       │   │   └── employee_status_resolver.dart
    │       │   └── usecases/
    │       │       ├── get_employee_usecase.dart
    │       │       ├── get_employees_usecase.dart
    │       │       └── update_employee_usecase.dart
    │       ├── presentation/
    │       │   ├── blocs/
    │       │   │   ├── employee_bloc.dart
    │       │   │   ├── employee_event.dart
    │       │   │   └── employee_state.dart
    │       │   ├── screens/
    │       │   │   ├── employee_list_screen.dart
    │       │   │   └── employee_detail_screen.dart
    │       │   ├── states/
    │       │   │   └── view_data_state.dart     ← shared; can live in core
    │       │   └── widgets/
    │       │       ├── employee_card.dart
    │       │       └── employee_avatar.dart
    │       └── employee.dart                    ← barrel file
    ├── shared/
    │   ├── domain/
    │   │   ├── errors/
    │   │   │   └── failure.dart
    │   │   └── usecases/
    │   │       └── use_case.dart
    │   ├── presentation/
    │   │   ├── states/
    │   │   │   └── view_data_state.dart
    │   │   └── widgets/
    │   │       └── loading_indicator.dart
    │   └── data/
    │       └── exceptions/
    │           └── app_exception.dart
    └── di/
        ├── injection.dart
        └── injection.config.dart                ← generated
```

**Rules:**
- Each feature is an island — it should compile independently of other features
- Cross-feature entities belong in `shared/`
- `di/` at the top is the global DI root

---

## Naming Conventions <!-- 74 -->

### Files

```
snake_case.dart

employee_entity.dart
get_employee_usecase.dart
employee_repository_impl.dart
employee_bloc.dart
employee_screen.dart
employee_card.dart
```

### Classes

```dart
// PascalCase for classes, enums, typedefs
class EmployeeRepositoryImpl {}
enum EmploymentType { fullTime, partTime, contract }
typedef OnEmployeeSelected = void Function(EmployeeEntity);
```

### Variables and Methods

```dart
// camelCase for variables, parameters, methods
final employeeName = 'Alice';
void fetchEmployeeData() {}
final isLoading = false;
```

### Constants

```dart
// lowerCamelCase for compile-time constants
const defaultTimeout = Duration(seconds: 30);
const maxRetryCount = 3;

// SCREAMING_SNAKE_CASE only for env-var keys
const String kApiBaseUrl = 'API_BASE_URL';
```

### Private Members

```dart
class SomeBloc {
  final String _employeeId;         // private field
  void _onLoadEmployee() {}         // private method
}
```

### Suffixes

| Type | Suffix | Example |
|------|--------|---------|
| Entity | `Entity` | `EmployeeEntity` |
| Model (DTO) | `Model` | `EmployeeModel` |
| Payload (write) | `Payload` | `UpdateEmployeePayload` |
| Params (domain input) | `Params` | `GetEmployeesParams` |
| Repository interface | `Repository` | `EmployeeRepository` |
| Repository impl | `RepositoryImpl` | `EmployeeRepositoryImpl` |
| DataSource interface | `DataSource` or `RemoteDataSource` | `EmployeeRemoteDataSource` |
| DataSource impl | `DataSourceImpl` | `EmployeeRemoteDataSourceImpl` |
| Mapper | `Mapper` | `EmployeeMapper` |
| Use case | `UseCase` | `GetEmployeeUseCase` |
| BLoC | `Bloc` | `EmployeeBloc` |
| Cubit | `Cubit` | `ThemeCubit` |
| Screen | `Screen` | `EmployeeDetailScreen` |
| Widget | (none, or `View`, `Card`, `Tile`) | `EmployeeCard` |

---

## Import Order <!-- 26 -->

```dart
// 1. Dart core imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party package imports (alphabetical)
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

// 4. Project imports (use package: imports, not relative, from lib/)
import 'package:my_app/src/features/employee/domain/entities/employee_entity.dart';
import 'package:my_app/src/shared/domain/errors/failure.dart';
```

---

## Barrel Files <!-- 24 -->

Each feature exposes a barrel that re-exports its public API:

```dart
// lib/src/features/employee/employee.dart
export 'domain/entities/employee_entity.dart';
export 'domain/repositories/employee_repository.dart';
export 'domain/usecases/get_employee_usecase.dart';
export 'presentation/blocs/employee_bloc.dart';
export 'presentation/blocs/employee_event.dart';
export 'presentation/blocs/employee_state.dart';
export 'presentation/screens/employee_list_screen.dart';
export 'presentation/screens/employee_detail_screen.dart';
```

Import the barrel from other features:

```dart
import 'package:my_app/src/features/employee/employee.dart';
```

---

## Code Style Rules <!-- 34 -->

```dart
// Trailing commas — always, for better diffs and auto-formatting
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Hello'),
      const SizedBox(height: 16),
    ],   // ← trailing comma
  );
}

// Named parameters for anything beyond 2 positional args
void createEmployee({
  required String name,
  required String email,
  String? departmentId,
}) {}

// const constructors wherever possible
const Text('Static label')
const SizedBox(height: 16)

// Never return raw exceptions from domain or data boundaries
// ❌
throw Exception('Something failed');

// ✅
return Left(Failure.serverFailure(message: 'Failed', developerMessage: '...'));
```

---

## Code Generation <!-- 23 -->

```bash
# Generate freezed, json_serializable, injectable, and mockito
dart run build_runner build --delete-conflicting-outputs

# Watch mode (development)
dart run build_runner watch --delete-conflicting-outputs
```

Generated file patterns:

| Pattern | Generator | Purpose |
|---------|-----------|---------|
| `*.freezed.dart` | freezed | Immutable classes, copyWith, sealed |
| `*.g.dart` | json_serializable | JSON serialization |
| `injection.config.dart` | injectable | DI registration |
| `*.mocks.dart` | mockito | Test mocks |

Add all generated files to `.gitignore` or commit them — choose one policy per project and stick to it. Committing avoids CI needing `build_runner` but creates noise in diffs.

---

## analysis_options.yaml <!-- 22 -->

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - '**/*.mocks.dart'
    - '**/injection.config.dart'

linter:
  rules:
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_print
    - prefer_single_quotes
    - require_trailing_commas
    - always_use_package_imports
    - unawaited_futures
```
