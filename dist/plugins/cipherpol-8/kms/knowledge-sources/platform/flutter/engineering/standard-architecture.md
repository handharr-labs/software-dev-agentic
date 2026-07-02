---
scope: platform/flutter
discipline: engineering
artifact: standard-architecture
---
Consolidated Flutter Clean Architecture reference — covers all engineering layers, patterns, and cross-cutting concerns used across Flutter projects.

# Domain

## Creation Order

### Theory

When building a new feature's domain layer:

```
Entity → Repository Interface → Use Case(s) → Domain Service (only if needed)
```

Never create a use case before the repository interface it depends on.

---

When building a new feature's domain layer, create files in this sequence. Never create a use case before the repository abstract class it depends on.

### Code Pattern

```
1. domain/entities/[feature]_entity.dart           ← Entity (@freezed, no fromJson)
2. domain/repositories/[feature]_repository.dart   ← Repository abstract class
3. domain/usecases/[feature]/get_[feature]_usecase.dart
   domain/usecases/[feature]/update_[feature]_usecase.dart
   ...                                              ← Use Case(s)
4. domain/services/[feature]_[calculator|validator].dart
                                                   ← Domain Service (only if needed)
```

## Dependency Rule

### Theory

Domain is the innermost layer. It imports nothing from outer layers.

```
UI  →  Presentation  →  Data  →  Domain
```

Allowed imports: language primitives and pure functional utilities only.
Forbidden: any framework, UI library, HTTP client, database driver, or data-layer type.

---

Domain is the innermost layer — it imports nothing from outer layers.

**Allowed:** `dart:core`, `package:freezed_annotation`, `package:equatable`, `package:fpdart` (for `Either`/`Option`).

**Forbidden:**
- `package:dio` / `package:http` — HTTP clients belong in data
- `package:flutter/material.dart` or any Flutter UI package — domain must be pure Dart
- Any BLoC, Cubit, or state-management import (`package:flutter_bloc`, `package:bloc`)
- Any data-layer import — no `*Model`, `*Dto`, or `*DataSource` types from `data/`

## Domain Enum

### Theory

Business-level constants. Place in `domain/enums/`.

**Rules:**
- Raw `String` values only when needed for direct API mapping
- No UI strings — display formatting belongs in presentation

### Code Pattern

```dart
// domain/enums/leave_status.dart
enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled;

  bool get isTerminal =>
      this == approved || this == rejected || this == cancelled;
}
```

## Domain Error

### Theory

A **Domain Error** is the unified error type returned from all repository and use case operations. It decouples the domain from transport-layer error types (HTTP status codes, network errors).

**Invariants:**
- Domain operations return a Result/Either typed with the domain error — they never propagate raw network errors upward
- Repositories map transport errors to domain errors before returning
- Error codes are business-meaningful (`notFound`, `validationFailed`, `unauthorized`) — not HTTP status codes

---

The unified error type returned from all repository and use case calls. All failures are typed variants of `Failure<T>` — no raw exceptions leak into domain or presentation.

### Code Pattern

```dart
// domain/errors/failure.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
abstract class Failure<T> with _$Failure<T> {
  /// API returned an error status.
  factory Failure.serverFailure({
    required String message,
    required String developerMessage,
    int? statusCode,
    String? errorCode,
  }) = ServerFailure;

  /// API returned validation errors keyed by field.
  factory Failure.validationFailure({
    required String message,
    T? errors,
    int? statusCode,
  }) = ValidationFailure<T>;

  /// No internet connection or DNS failure.
  factory Failure.networkFailure({
    required String message,
  }) = NetworkFailure;

  /// Unexpected error (bug, null response, parse error).
  factory Failure.unknownFailure({
    required String message,
  }) = UnknownFailure;

  /// Local storage read/write failure.
  factory Failure.localFailure({
    required String message,
  }) = LocalFailure;
}
```

## Domain Service

### Theory

A **Domain Service** contains pure business logic that spans multiple entities or is reused across multiple use cases.

**Invariants:**
- No I/O — no async, no network, no database, no file system
- No side effects — pure functions; same input always produces the same output
- No framework imports
- Returns structured data — never formatted strings, CSS classes, or display labels (presentation formats output)

**When to extract to a service:**

| Scenario | Decision |
|----------|----------|
| 1–3 line condition | Keep inline in use case |
| Complex multi-step validation | Extract to service |
| Logic reused across ≥ 2 use cases | Extract to service |
| Needs independent unit testing | Extract to service |

**Naming:** `[Feature][Noun]` — e.g. `LeaveBalanceCalculator`, `AttendanceScheduleResolver`

---

Pure synchronous functions — no I/O, no async, no side effects. Encapsulate domain logic that is too complex to inline in a use case or is reused by multiple use cases.

**Rules:**
- No `@injectable` unless dependencies need to be injected
- Returns structured data — never formatted strings or display text
- Presentation layer formats service output for display

**When to extract to a service:**

| Scenario | Action |
|---|---|
| 1–3 line condition | Keep inline in use case |
| Complex multi-step validation | Service |
| Reused by ≥ 2 use cases | Service |
| Needs unit testing in isolation | Service |

### Code Pattern

```dart
// domain/services/leave_balance_calculator.dart
import '../entities/leave_entitlement_entity.dart';

class LeaveBalanceCalculator {
  int remainingDays(LeaveEntitlementEntity entitlement) {
    final pendingDays = entitlement.pendingRequests
        .where((r) => r.status == LeaveStatus.pending)
        .fold(0, (sum, r) => sum + r.days);
    final remaining =
        entitlement.annualDays - entitlement.usedDays - pendingDays;
    return remaining < 0 ? 0 : remaining;
  }

  bool isSufficient(LeaveEntitlementEntity entitlement, int requestedDays) =>
      remainingDays(entitlement) >= requestedDays;
}
```

## Entity

### Theory

An **Entity** is a pure data structure representing a business concept.

**Invariants:**
- No framework imports — value types or pure classes only
- No business logic — entities hold data; use cases execute logic
- No serialization annotations — no `@JsonKey`, no `Codable`, no `fromJson`
- Immutable — all properties are read-only; mutation produces a new instance (`copyWith`)
- Represent domain concepts, not API shapes — field names match the business domain, not the JSON payload

**When to create:** When the domain needs a named, typed concept with identified fields (e.g. `Employee`, `LeaveRequest`, `AttendanceRecord`).

---

Immutable business objects. `@freezed` is recommended for `copyWith` and pattern matching, but plain Dart classes are acceptable when the entity is simple and not pattern-matched in the UI.

**Rules:**
- `@freezed` recommended for immutability + `copyWith`; plain Dart class acceptable for simple entities
- Only `.freezed.dart` part — never `.g.dart`
- No `@JsonKey` annotations
- No `fromJson` / `toJson` factories
- Represent business concepts, not API shapes

### Code Pattern

```dart
// domain/entities/employee_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_entity.freezed.dart';

@freezed
class EmployeeEntity with _$EmployeeEntity {
  const factory EmployeeEntity({
    required String id,
    required String name,
    required String email,
    DateTime? joinDate,
  }) = _EmployeeEntity;
}
```

## Repository Interface

### Theory

A **Repository** is a contract that defines data access operations — *what* is needed, not *how* it is done.

**Invariants:**
- Lives in Domain as an interface/protocol/abstract class only — implementation lives in Data
- Returns domain Entities — never raw DTOs, API response types, or database records
- Method names follow the operation's intent: `get*`, `create*`, `update*`, `delete*`, `submit*`
- Parameters are domain objects — not raw dictionaries, JSON maps, or HTTP types
- Error type is the domain error type — never a networking or transport error

**When to create:** One repository per aggregate root or feature domain. Created before use cases — use cases depend on the repository interface.

---

Abstract contract that the data layer must implement. Domain defines the interface — it never knows how data is fetched.

**Rules:**
- `abstract class` (not `interface` or `mixin`)
- Return `Either<Failure, T>` — never throw from a repository
- Return domain entities, never DTOs
- Method names follow REST: `get*`, `create*`, `update*`, `delete*`
- Params are domain objects, not raw `Map<String, dynamic>`

### Code Pattern

```dart
// domain/repositories/employee_repository.dart
import 'package:fpdart/fpdart.dart';
import '../entities/employee_entity.dart';
import '../errors/failure.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, EmployeeEntity>> getEmployee(String id);
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees({
    int page = 1,
    int limit = 20,
    String? departmentId,
  });
  Future<Either<Failure, EmployeeEntity>> updateEmployee(
    String id,
    UpdateEmployeeParams params,
  );
  Future<Either<Failure, void>> deleteEmployee(String id);
}
```

## Use Case

### Theory

A **UseCase** encapsulates a single business operation: one class, one public method, one responsibility.

**Invariants:**
- One business operation per class — never combine unrelated operations
- Depends only on repository interfaces — never on repository implementations or data-layer types
- No framework dependencies — no HTTP clients, no UI types
- Accepts typed input (Params/Request struct) — never raw dictionaries or loose primitives
- Returns domain entities or primitives — never DTOs or view models
- All I/O goes through the repository — use cases never call APIs or databases directly

**Mandatory call flow — no exceptions:**
```
Presentation → UseCase → Repository    ✅
Presentation → Repository              ❌  direct call is a CLEAN violation
```

**When to create:** One use case per business operation (e.g. `GetEmployeeUseCase`, `SubmitLeaveRequestUseCase`, `ApproveLeaveRequestUseCase`). Even thin pass-through use cases are mandatory — they preserve a stable indirection point for future validation, caching, or logging without touching the presentation layer.

---

Single-responsibility units of business logic. Each use case calls exactly one repository method. Registered with `@lazySingleton` via injectable.

**Naming:** `[Verb][Feature]UseCase` — `GetEmployeeUseCase`, `UpdateAttendanceUseCase`, `SubmitLeaveRequestUseCase`

**Params naming:**

| HTTP | Params structure |
|---|---|
| GET (single) | Plain `String` or typed ID |
| GET (list) | `XxxParams { page, limit, filters... }` |
| POST | `XxxParams { field1, field2... }` (pure Dart) |
| PUT | `XxxParams { id, field1... }` (pure Dart) |
| DELETE | Plain `String` ID |
| No input | `NoParams` |

### Code Pattern

```dart
// domain/usecases/use_case.dart
import 'package:fpdart/fpdart.dart';
import '../errors/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

```dart
// GET — single item
// domain/usecases/employee/get_employee_usecase.dart
@lazySingleton
class GetEmployeeUseCase implements UseCase<EmployeeEntity, String> {
  GetEmployeeUseCase({required this.repository});
  final EmployeeRepository repository;

  @override
  Future<Either<Failure, EmployeeEntity>> call(String id) =>
      repository.getEmployee(id);
}
```

```dart
// GET — list with params
@lazySingleton
class GetEmployeesUseCase
    implements UseCase<List<EmployeeEntity>, GetEmployeesParams> {
  GetEmployeesUseCase({required this.repository});
  final EmployeeRepository repository;

  @override
  Future<Either<Failure, List<EmployeeEntity>>> call(
    GetEmployeesParams params,
  ) =>
      repository.getEmployees(
        page: params.page,
        limit: params.limit,
        departmentId: params.departmentId,
      );
}

class GetEmployeesParams {
  const GetEmployeesParams({this.page = 1, this.limit = 20, this.departmentId});
  final int page;
  final int limit;
  final String? departmentId;
}
```

```dart
// POST/PUT — write with params
@lazySingleton
class UpdateEmployeeUseCase
    implements UseCase<EmployeeEntity, UpdateEmployeeParams> {
  UpdateEmployeeUseCase({required this.repository});
  final EmployeeRepository repository;

  @override
  Future<Either<Failure, EmployeeEntity>> call(UpdateEmployeeParams params) =>
      repository.updateEmployee(params.id, params);
}

class UpdateEmployeeParams {
  const UpdateEmployeeParams({
    required this.id,
    required this.name,
    required this.email,
    this.departmentId,
  });
  final String id;
  final String name;
  final String email;
  final String? departmentId;
}
```

```dart
// No-params use case
@lazySingleton
class GetCurrentUserUseCase implements UseCase<EmployeeEntity, NoParams> {
  GetCurrentUserUseCase({required this.repository});
  final AuthRepository repository;

  @override
  Future<Either<Failure, EmployeeEntity>> call(NoParams _) =>
      repository.getCurrentUser();
}
```

# Data

## Creation Order

### Theory

**Remote API feature:**

```
DTO → Mapper → DataSource interface → DataSource impl → Repository impl
```

**Local DB feature:**

```
DB Record → DB DataSource interface → DB DataSource impl → DB Mapper → Repository impl
```

Never create a repository implementation before the DataSource it depends on.

---

When building a new feature's data layer, create files in this sequence. Never create a repository implementation before the data source it depends on.

### Code Pattern

```
1. data/models/[feature]_model.dart                          ← DTO (@freezed, fromJson, .g.dart)
   data/models/[feature]_payload.dart                        ← Write payload (if POST/PUT)
2. data/mappers/[feature]_mapper.dart                        ← Mapper (BaseMapper subclass)
3. data/datasources/[feature]_remote_data_source.dart        ← DataSource abstract class
   data/datasources/[feature]_remote_data_source_impl.dart   ← DataSource implementation (Dio)
4. data/repositories/[feature]_repository_impl.dart          ← Repository implementation
```

## Data Source

### Theory

A **DataSource** is an abstract interface for raw data access — remote (HTTP) or local (DB, cache).

**Invariants:**
- Interface only in the data layer — implementation is injected, never instantiated directly
- Methods return raw data (DTOs or primitives) — never domain entities
- One DataSource per data origin (remote API, local DB, cache) — do not mix sources in one interface
- Throws or returns transport-layer errors — the repository implementation maps these to domain errors

**When to create:** One DataSource interface per data origin per feature. Created after the DTO and mapper, before the repository implementation.

---

Separate remote and local data sources via abstract interface + implementation. DataSources only throw — they never return `Either`. The repository catches and converts.

### Code Pattern

```dart
// data/datasources/employee_remote_data_source.dart
abstract class EmployeeRemoteDataSource {
  Future<EmployeeModel> getEmployee(String id);
  Future<List<EmployeeModel>> getEmployees({int page = 1, int limit = 20, String? departmentId});
  Future<EmployeeModel> updateEmployee(String id, UpdateEmployeePayload payload);
  Future<void> deleteEmployee(String id);
}
```

```dart
// data/datasources/employee_remote_data_source_impl.dart
@LazySingleton(as: EmployeeRemoteDataSource)
class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  EmployeeRemoteDataSourceImpl({required this.dio});
  final Dio dio;

  @override
  Future<EmployeeModel> getEmployee(String id) async {
    final response = await dio.get('/api/v1/employees/$id');
    final base = BaseResponse<EmployeeModel>.fromJson(
      response.data as Map<String, dynamic>,
      fromJsonT: EmployeeModel.fromJson,
    );
    return base.data!;
  }

  @override
  Future<List<EmployeeModel>> getEmployees({int page = 1, int limit = 20, String? departmentId}) async {
    final response = await dio.get(
      '/api/v1/employees',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (departmentId != null) 'department_id': departmentId,
      },
    );
    final base = BaseResponse<List<dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      fromJsonT: (data) => data as List<dynamic>,
    );
    return (base.data ?? [])
        .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

```dart
// data/models/base_response.dart
class BaseResponse<T> {
  const BaseResponse({this.status, this.message, this.data});
  final int? status;
  final String? message;
  final T? data;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(dynamic) fromJsonT,
  }) =>
      BaseResponse<T>(
        status: json['status'] as int?,
        message: json['message'] as String?,
        data: json['data'] != null ? fromJsonT(json['data']) : null,
      );
}
```

## DTO

### Theory

A **DTO (Data Transfer Object)** mirrors the raw API or database shape exactly.

**Invariants:**
- No domain logic — plain data container only
- No computed fields — no derived values, no formatting
- No domain entity types — DTOs use primitive types and nested DTOs
- Serialization annotations live here, not on domain entities (`@JsonKey`, `Codable`, `fromJson`)
- Field names match the API/DB schema — not the business domain vocabulary

**When to create:** One DTO per API response type or DB table row. Created before the mapper that consumes it.

---

DTO classes for API responses. Always have `fromJson` — entities never do. All fields nullable — API data is untrusted.

**Rules:**
- Both `.freezed.dart` and `.g.dart` parts
- `@JsonKey(name:)` for snake_case → camelCase mapping
- No business logic
- Never returned from repository — always mapped to entity first

### Code Pattern

```dart
// data/models/employee_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_model.freezed.dart';
part 'employee_model.g.dart';

@freezed
class EmployeeModel with _$EmployeeModel {
  const factory EmployeeModel({
    @JsonKey(name: 'employee_id') String? id,
    @JsonKey(name: 'full_name') String? name,
    String? email,
    @JsonKey(name: 'join_date') String? joinDate,
    @JsonKey(name: 'department_id') String? departmentId,
  }) = _EmployeeModel;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);
}
```

## Exception

### Theory

Typed exceptions thrown by DataSources. Converted to `Failure` in the repository via `toFailure()`. Never propagated to domain or presentation.

### Code Pattern

```dart
// data/exceptions/app_exception.dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  factory AppException.server({required String message, int? statusCode, String? errorCode}) = ServerException;
  factory AppException.validation<T>({required String message, T? errors, int? statusCode}) = ValidationException<T>;
  factory AppException.network({required String message}) = NetworkException;
  factory AppException.unknown({required String message}) = UnknownAppException;
}

final class ServerException extends AppException {
  const ServerException({required super.message, this.statusCode, this.errorCode});
  final int? statusCode;
  final String? errorCode;
}

final class ValidationException<T> extends AppException {
  const ValidationException({required super.message, this.errors, this.statusCode});
  final T? errors;
  final int? statusCode;
}

final class NetworkException extends AppException {
  const NetworkException({required super.message});
}

final class UnknownAppException extends AppException {
  const UnknownAppException({required super.message});
}

extension AppExceptionX on AppException {
  Failure toFailure() => switch (this) {
        ServerException e => Failure.serverFailure(
            message: e.message,
            developerMessage: 'HTTP ${e.statusCode}',
            statusCode: e.statusCode,
            errorCode: e.errorCode,
          ),
        ValidationException e => Failure.validationFailure(
            message: e.message,
            errors: e.errors,
            statusCode: e.statusCode,
          ),
        NetworkException e => Failure.networkFailure(message: e.message),
        UnknownAppException e => Failure.unknownFailure(message: e.message),
      };
}
```

## HTTP Client

### Theory

`ErrorInterceptor` translates Dio errors → `AppException` before they reach the repository. Registered on Dio creation.

### Code Pattern

```dart
// data/network/error_interceptor.dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = switch (err.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        AppException.network(message: 'No internet connection'),
      DioExceptionType.badResponse => _mapStatusCode(err),
      _ => AppException.unknown(message: err.message ?? 'Unknown error'),
    };
    handler.reject(
      DioException(requestOptions: err.requestOptions, error: exception),
    );
  }

  AppException _mapStatusCode(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final message =
        (err.response?.data as Map<String, dynamic>?)?['message'] as String? ??
        err.message ??
        'Server error';
    return statusCode == 422
        ? AppException.validation(message: message, statusCode: statusCode)
        : AppException.server(message: message, statusCode: statusCode);
  }
}
```

## Local Data Source

### Theory

Cache-first pattern: try local cache first, fall back to remote, then cache the result.

### Code Pattern

```dart
// data/datasources/employee_local_data_source.dart
abstract class EmployeeLocalDataSource {
  Future<EmployeeModel?> getCachedEmployee(String id);
  Future<void> cacheEmployee(String id, EmployeeModel model);
  Future<void> clearCache();
}
```

```dart
// Repository cache-first variant
@override
Future<Either<Failure, EmployeeEntity>> getEmployee(String id) async {
  final cached = await localDataSource.getCachedEmployee(id);
  if (cached != null) return Right(mapper.toEntity(cached));

  try {
    final model = await remoteDataSource.getEmployee(id);
    await localDataSource.cacheEmployee(id, model);
    return Right(mapper.toEntity(model));
  } on AppException catch (e) {
    return Left(e.toFailure());
  } catch (e) {
    return Left(Failure.unknownFailure(message: e.toString()));
  }
}
```

## Mapper

### Theory

A **Mapper** converts between a DTO and a domain entity — always defined as an interface with a concrete implementation.

**Invariants:**
- Always interface + implementation — never a plain utility function or static helper
- One direction per method: `toDomain(dto)` converts inward; `toDTO(entity)` converts outward (if write operations exist)
- No I/O — pure transformation only; no network calls, no DB reads
- No business logic — field mapping only; validation belongs in domain use cases
- Null/missing fields handled defensively — never let a missing API field crash the mapper

**When to create:** One mapper per DTO ↔ entity pair. Created after the DTO, before the DataSource implementation.

---

Convert Models → Entities. One mapper per aggregate root. Handle nulls with explicit defaults.

**Rules:**
- One mapper per entity type
- Handle nulls with explicit defaults — never assume API fields are present
- Date strings → `DateTime` conversion happens in mapper, not entity
- List mappers call `toEntity` per item: `models.map(mapper.toEntity).toList()`

### Code Pattern

```dart
// data/mappers/base_mapper.dart
abstract class BaseMapper<Model, Entity> {
  Entity toEntity(Model model);
}
```

```dart
// data/mappers/employee_mapper.dart
@lazySingleton
class EmployeeMapper extends BaseMapper<EmployeeModel, EmployeeEntity> {
  @override
  EmployeeEntity toEntity(EmployeeModel model) => EmployeeEntity(
        id: model.id ?? '',
        name: model.name ?? '',
        email: model.email ?? '',
        joinDate: model.joinDate != null
            ? DateTime.tryParse(model.joinDate!)
            : null,
      );
}
```

## Payload

### Theory

Separate class for write request bodies. Keeps read DTOs clean. Domain Params → Data Payload conversion happens in the repository impl.

**Domain Params → Data Payload flow:**
```
Domain Params (pure Dart)
      ↓
Repository Impl converts
      ↓
Data Payload (@JsonKey, freezed, .toJson())
      ↓
DataSource sends to API
```

Simple conversions happen inline in the repository. Complex conversions warrant a `PayloadMapper`.

### Code Pattern

```dart
// data/models/update_employee_payload.dart
@freezed
class UpdateEmployeePayload with _$UpdateEmployeePayload {
  const factory UpdateEmployeePayload({
    @JsonKey(name: 'full_name') required String name,
    required String email,
    @JsonKey(name: 'department_id') String? departmentId,
  }) = _UpdateEmployeePayload;

  factory UpdateEmployeePayload.fromJson(Map<String, dynamic> json) =>
      _$UpdateEmployeePayloadFromJson(json);
}
```

```dart
// data/mappers/update_employee_payload_mapper.dart (complex case)
@lazySingleton
class UpdateEmployeePayloadMapper {
  UpdateEmployeePayload fromParams(UpdateEmployeeParams params) =>
      UpdateEmployeePayload(
        name: params.name,
        email: params.email,
        departmentId: params.departmentId,
      );
}
```

## Repository Implementation

### Theory

A **Repository Implementation** implements the domain repository interface using a DataSource and Mapper.

**Invariants:**
- Implements a domain repository interface — it is the bridge between Data and Domain
- Calls the DataSource for raw data, calls the Mapper to convert to domain entities
- Wraps all DataSource calls with error handling — maps transport errors to domain errors before returning
- Never lets raw HTTP errors, DB exceptions, or transport-layer types propagate to the domain
- Never calls another repository implementation directly

**When to create:** Last in the creation order — after DataSource interface and implementation exist.

---

Implements domain repository interface. Orchestrates datasource → mapper → Either. The `try/catch` boundary lives here — never in datasources.

**Rules:**
- Catch `AppException` first, then `catch (e)` for unexpected errors
- Never let exceptions escape into domain or presentation layers
- `*Model` instances never cross into domain — `mapper.toEntity()` is the boundary
- Registered with `@LazySingleton(as: RepositoryInterface)`

### Code Pattern

```dart
// data/repositories/employee_repository_impl.dart
@LazySingleton(as: EmployeeRepository)
class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl({required this.remoteDataSource, required this.mapper});

  final EmployeeRemoteDataSource remoteDataSource;
  final EmployeeMapper mapper;

  @override
  Future<Either<Failure, EmployeeEntity>> getEmployee(String id) async {
    try {
      final model = await remoteDataSource.getEmployee(id);
      return Right(mapper.toEntity(model));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> updateEmployee(
    String id,
    UpdateEmployeeParams params,
  ) async {
    try {
      final payload = UpdateEmployeePayload(
        name: params.name,
        email: params.email,
        departmentId: params.departmentId,
      );
      final model = await remoteDataSource.updateEmployee(id, payload);
      return Right(mapper.toEntity(model));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
}
```

# Presentation

## BLoC

### Theory

A **StateHolder** is the single source of truth for a screen's UI state. Platform names vary (ViewModel, BLoC, Presenter) but the contract is identical across platforms.

**Invariants:**
- Owns no view imports — no UI framework, no widget, no component type
- Depends on use case interfaces only — never calls repositories or data sources directly
- Use cases are injected via DI — never instantiated directly inside the StateHolder
- Exposes state as a read-only stream or observable — UI observes, never mutates
- One StateHolder per screen — never shared across screens unless explicitly scoped

**State** is an immutable snapshot of what the UI should render. **Events** represent user intentions. **Actions** (Output) are one-shot side effects emitted after processing an event.

---

BLoC for event-driven state management. Widgets dispatch events, BLoC handles them via `on<Event>`, emits immutable states. Use cases are injected via constructor.

**Rules:**
- `@injectable` — created fresh per screen via DI, never `@lazySingleton`
- `on<Event>(_handler)` for each event type
- Each handler emits loading first, then result
- Always use `result.fold()` — never `result.getOrElse()` alone
- Never import from data layer — no DTOs, no `RepositoryImpl`

**BLoC vs Cubit:**

| Use BLoC | Use Cubit |
|---|---|
| Complex event-driven flows | Simple state toggles |
| Multiple event handlers | 1-3 method calls |
| Events with payloads | No input needed |
| Needs event replay | Immediate state updates |

### Code Pattern

```dart
// presentation/blocs/employee_event.dart
@freezed
sealed class EmployeeEvent with _$EmployeeEvent {
  const factory EmployeeEvent.loadEmployee({required String employeeId}) = LoadEmployee;
  const factory EmployeeEvent.refreshEmployee() = RefreshEmployee;
  const factory EmployeeEvent.updateEmployee({required String name, required String email}) = UpdateEmployee;
}
```

```dart
// presentation/blocs/employee_state.dart
@freezed
class EmployeeState with _$EmployeeState {
  const factory EmployeeState({
    required ViewDataState<EmployeeEntity> employeeState,
    required ViewDataState<void> updateState,
  }) = _EmployeeState;

  factory EmployeeState.initial() => EmployeeState(
        employeeState: ViewDataState.initial(),
        updateState: ViewDataState.initial(),
      );
}
```

```dart
// presentation/blocs/employee_bloc.dart
@injectable
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc({required this.getEmployeeUseCase, required this.updateEmployeeUseCase})
      : super(EmployeeState.initial()) {
    on<LoadEmployee>(_onLoadEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
  }

  final GetEmployeeUseCase getEmployeeUseCase;
  final UpdateEmployeeUseCase updateEmployeeUseCase;

  Future<void> _onLoadEmployee(LoadEmployee event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(employeeState: ViewDataState.loading()));
    final result = await getEmployeeUseCase(event.employeeId);
    result.fold(
      (failure) => emit(state.copyWith(
        employeeState: ViewDataState.error(message: failure.message, failure: failure),
      )),
      (employee) => emit(state.copyWith(
        employeeState: ViewDataState.loaded(data: employee),
      )),
    );
  }
}
```

```dart
// presentation/states/view_data_state.dart
enum ViewState { initial, loading, loaded, error, empty }

class ViewDataState<T> extends Equatable {
  const ViewDataState._({required this.status, this.data, this.message, this.failure});

  final ViewState status;
  final T? data;
  final String? message;
  final Failure? failure;

  factory ViewDataState.initial() => const ViewDataState._(status: ViewState.initial);
  factory ViewDataState.loading({String? message}) =>
      ViewDataState._(status: ViewState.loading, message: message);
  factory ViewDataState.loaded({T? data}) => ViewDataState._(status: ViewState.loaded, data: data);
  factory ViewDataState.error({required String message, Failure? failure, T? data}) =>
      ViewDataState._(status: ViewState.error, message: message, failure: failure, data: data);
  factory ViewDataState.empty({String? message}) =>
      ViewDataState._(status: ViewState.empty, message: message);

  bool get isInitial => status == ViewState.initial;
  bool get isLoading => status == ViewState.loading;
  bool get isLoaded => status == ViewState.loaded;
  bool get hasError => status == ViewState.error;
  bool get isEmpty => status == ViewState.empty;

  @override
  List<Object?> get props => [status, data, message, failure];
}
```

## Cubit

### Theory

A **StateHolder** is the single source of truth for a screen's UI state — in Flutter, a Cubit is a simplified StateHolder with no events, only direct method calls.

**Invariants:**
- Depends on use case interfaces only — never calls repositories or data sources directly
- Exposes state as a stream — UI observes, never mutates
- One StateHolder per screen — use `@lazySingleton` only for globally shared state (theme, locale)

---

Use Cubit when there are no events — only direct method calls. Simpler than BLoC for state toggles and shared global state.

Use `@lazySingleton` for shared state (theme, locale). Use `@injectable` for per-screen state.

### Code Pattern

```dart
// presentation/cubits/theme_cubit.dart
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void setLight() => emit(ThemeMode.light);
  void setDark() => emit(ThemeMode.dark);
  void toggle() => emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
}
```

## BLoC Listener

### Theory

**Actions** (also called Output or SideEffects) represent one-time side effects the StateHolder emits after processing an event.

**Invariants:**
- One-shot — consumed once; not part of persistent state
- Named after the outcome — `NavigateToDetail`, `ShowErrorToast`, `CloseScreen`
- Navigation targets are abstract — the StateHolder says *what*, the UI/navigator decides *how*

In Flutter, `BlocListener` is the mechanism for consuming Actions from a BLoC.

---

`BlocListener` handles one-time side effects — navigation, toasts, dialogs — that are not reflected in the UI rebuild cycle.

| Use | When |
|---|---|
| `BlocBuilder` | Rebuild widgets based on state |
| `BlocListener` | Side effects: navigate, show toast, analytics |
| `BlocConsumer` | Both in the same widget tree |

### Code Pattern

```dart
BlocListener<EmployeeBloc, EmployeeState>(
  listenWhen: (prev, curr) => prev.updateState != curr.updateState,
  listener: (context, state) {
    if (state.updateState.isLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
      Navigator.of(context).pop();
    }
    if (state.updateState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.updateState.message ?? 'Failed')),
      );
    }
  },
  child: ...,
)
```

## Component

### Theory

A **Component** (also called Sub-view, Widget, or View) is a reusable UI element smaller than a full screen.

**Invariants:**
- Stateless by default — receives data via props/parameters and emits callbacks
- If stateful, bound to a scoped StateHolder — never manages business state inline
- No use case calls — all data passed in from the parent screen or a scoped StateHolder
- Reuse check required before creating — search shared component directories first

**When to create:** When a UI element appears in ≥2 screens, or when a screen section is complex enough to isolate for readability.

---

Reusable presentational widget — BLoC-unaware. Receives plain domain entities via constructor. Shared cross-feature widgets go in `lib/src/shared/core/`.

**Rules:**
- No `BlocProvider`, `BlocBuilder`, or `context.read` inside a component
- `const` constructor — all fields `final`

**Component reuse search paths:**

| Scope | Path |
|---|---|
| Shared core (cross-feature) | `talenta/lib/src/shared/core/` |
| Feature screens | `talenta/lib/src/features/*/presentation/screens/` |
| Feature widgets | `talenta/lib/src/features/*/presentation/widgets/` |

### Code Pattern

```dart
// presentation/widgets/employee_card.dart
class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key, required this.employee});
  final EmployeeEntity employee;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(employee.email),
          ],
        ),
      ),
    );
  }
}
```

## Screen Structure

### Theory

A **Screen** is a full-page view bound to a single StateHolder. It observes state and sends events — it contains no business logic.

**Invariants:**
- Bound to exactly one StateHolder — instantiated via DI, never with direct `new` / `init`
- Observes every State field declared in the StateHolder contract — no State field goes unhandled
- Sends events to the StateHolder for every user interaction — never mutates state directly
- Contains no business logic — conditionals exist only to decide what to render, not what to compute
- No use case calls — all data flows through the StateHolder

**When to create:** One screen per route/destination. Created after the StateHolder contract exists.

---

Screens split into two widgets: outer `Screen` (owns `BlocProvider` + initial event) and inner `_View` (stateless, reads BLoC). Keeps provider wiring separate from rendering.

**Rules:**
- `BlocProvider` in the outer screen widget only
- `getIt<XBloc>()` creates a fresh instance — never `getIt.get()` inside a `BlocBuilder`
- `buildWhen` to limit rebuilds to relevant state slices

### Code Pattern

```dart
// presentation/screens/employee_screen.dart
class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key, required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EmployeeBloc>()
        ..add(EmployeeEvent.loadEmployee(employeeId: employeeId)),
      child: const _EmployeeView(),
    );
  }
}

class _EmployeeView extends StatelessWidget {
  const _EmployeeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee')),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        buildWhen: (prev, curr) => prev.employeeState != curr.employeeState,
        builder: (context, state) {
          final s = state.employeeState;
          if (s.isLoading || s.isInitial) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return Center(child: Text(s.message ?? 'Error'));
          if (s.data == null) return const Center(child: Text('Not found'));
          return EmployeeContent(employee: s.data!);
        },
      ),
    );
  }
}
```

## Screen Entry Points

### Theory

When tracing a screen's full layer stack for system design extraction or exploration, start from the screen widget and follow imports inward through each layer.

### Definition

**Layer file patterns:**

| Layer | Glob | Grep |
|---|---|---|
| Screen | `**/presentation/**/*screen.dart`, `**/presentation/**/*page.dart` | `class.*Screen.*extends`, `class.*Page.*extends` |
| BLoC / Cubit | `**/presentation/**/*bloc.dart`, `**/presentation/**/*cubit.dart` | `class.*Bloc extends Bloc`, `class.*Cubit extends Cubit` |
| UseCase | `**/domain/usecases/**/*use_case.dart` | `class.*UseCase` |
| Repository interface | `**/domain/repositories/**/*repository.dart` | `abstract class.*Repository` |
| Repository impl | `**/data/repositories/**/*repository_impl.dart` | `class.*RepositoryImpl.*implements` |
| Remote DataSource | `**/data/datasources/**/*remote_data_source.dart` | `class.*RemoteDataSource` |
| Local DataSource | `**/data/datasources/**/*local_data_source.dart` | `class.*LocalDataSource` |
| DTO / Model | `**/data/models/**/*dto.dart`, `**/data/models/**/*model.dart` | `class.*Dto`, `class.*Model` |
| Mapper | `**/data/mappers/**/*mapper.dart` | `class.*Mapper` |

**Tracing strategy:**
1. Read the screen file — find the BLoC/Cubit class name from `BlocProvider.of<...>()` or `context.read<...>()`
2. Read the BLoC/Cubit — find UseCase class names from constructor parameters
3. Read each UseCase — find the Repository interface from the constructor parameter type
4. Grep `class.*RepositoryImpl.*implements.*{RepositoryName}` — find the concrete implementation
5. Read the RepositoryImpl — find DataSource class names from constructor parameters
6. Read each DataSource — extract HTTP method, endpoint string, and DTO class names

### Code Pattern

```bash
# Find the BLoC/Cubit associated with a screen (replace {ScreenName} with PascalCase)
grep -rn "BlocProvider\|context.read\|context.watch" path/to/{screen_name}_screen.dart

# Find UseCases injected into a BLoC/Cubit
grep -n "UseCase" path/to/{screen_name}_bloc.dart

# Find the concrete repository for a given interface
grep -rn "class.*RepositoryImpl.*implements.*{RepositoryName}" --include="*.dart" lib/

# Find HTTP endpoint strings in a remote data source
grep -n "\"/" path/to/{feature}_remote_data_source.dart
```

# Dependency Injection

## External Dependencies

### Theory

| Scope | Use for | Lifetime |
|---|---|---|
| Singleton | Shared infrastructure — HTTP client, token store, logger | App lifetime |
| Feature-scoped | StateHolders and use cases for a single feature | Screen/route lifetime |
| Transient | Stateless helpers, mappers, pure services | Per-resolution |

**Never register a StateHolder as a singleton** — it holds mutable UI state that must be reset when the screen is destroyed.

---

Third-party instances (Dio, SharedPreferences) registered via `@module` abstract class. `@preResolve` tells injectable to await async futures before resolving dependents.

### Code Pattern

```dart
// di/app_module.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.example.com',
        ),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ))
        ..interceptors.addAll([
          ErrorInterceptor(),
          LogInterceptor(logPrint: (obj) => debugPrint(obj.toString())),
        ]);

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

```dart
// Environment-based registration (prod vs dev)
@module
abstract class NetworkModule {
  @lazySingleton
  @prod
  Dio get prodDio => Dio(BaseOptions(baseUrl: 'https://api.example.com'));

  @lazySingleton
  @dev
  Dio get devDio => Dio(BaseOptions(baseUrl: 'https://api.staging.example.com'));
}
```

```dart
// main.dart — configure environment at startup
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(
    environment: const String.fromEnvironment('ENV', defaultValue: 'prod'),
  );
  runApp(const App());
}
```

## get_it

### Theory

These rules apply regardless of framework (Next.js React Context, Swinject, get_it):

1. **Constructor injection** — dependencies are declared as constructor parameters, never fetched inside a class body
2. **Depend on interfaces, not implementations** — callers reference abstract types; the container resolves the concrete class
3. **No `new` inside business logic** — use cases, StateHolders, and repository implementations never instantiate their own dependencies
4. **Container owns lifecycle** — the DI container decides whether a dependency is a singleton, feature-scoped, or transient; callers never manage this
5. **One container per runtime boundary** — if your platform has multiple runtimes (e.g. server + client), each runtime gets its own container; never share a container across boundaries

---

`get_it` service locator + `injectable` annotation-driven code generation. One DI module per feature.

**Annotation lifecycle:**

| Annotation | Lifecycle | Use For |
|---|---|---|
| `@lazySingleton` | Singleton, created on first access | Repositories, use cases, mappers, datasources |
| `@singleton` | Singleton, created at startup | Core services (auth, analytics) |
| `@injectable` | New instance per `getIt.get()` call | BLoCs, Cubits |
| `@LazySingleton(as: Interface)` | Singleton bound to interface | Repository/datasource implementations |
| `@module` | Abstract class providing external dependencies | Dio, SharedPreferences |

**Never register a BLoC as `@lazySingleton`** — BLoC holds mutable state; every screen must get a fresh instance.

### Code Pattern

```dart
// di/injection.dart
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

```dart
// di/app_module.dart — external dependencies
@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(
        baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com'),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ))
        ..interceptors.addAll([ErrorInterceptor(), LogInterceptor()]);

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

```dart
// Registration order (leaf nodes first):
// 1. External deps (@module)
// 2. DataSources
// 3. Mappers
// 4. Repositories (@LazySingleton(as: Interface))
// 5. Use Cases (@lazySingleton)
// 6. BLoCs (@injectable)
```

```bash
# Generate after adding/changing annotations
dart run build_runner build --delete-conflicting-outputs
```

## Registration Order

### Theory

Dependencies must be registered before they are resolved. The correct registration order mirrors the dependency graph:

```
Infrastructure (HTTP client, DB driver)
  → DataSources
  → Mappers
  → Repository Implementations
  → Use Cases
  → StateHolders
```

Register leaf nodes (no dependencies) first. Register consumers after their dependencies.

---

`injectable` resolves registration order automatically via the dependency graph. Declare annotations in leaf-first order so the generated `injection.config.dart` registers correctly.

| Layer | Lifecycle | Why |
|---|---|---|
| External deps (`@module`) | Before anything | No app dependencies |
| DataSources | `@lazySingleton` | Depend on Dio/storage |
| Mappers | `@lazySingleton` | Stateless, no dependencies |
| Repositories | `@LazySingleton(as:)` | Depend on DataSource + Mapper |
| Use Cases | `@lazySingleton` | Depend on Repository |
| BLoCs | `@injectable` | Stateful — fresh instance per screen |

**Never register a BLoC as `@lazySingleton`** — BLoC holds mutable state; every screen must get a fresh instance via `BlocProvider`.

### Code Pattern

```dart
// 1. External dependencies (no app dependencies)
@module abstract class AppModule {
  @lazySingleton Dio get dio => ...;
  @preResolve Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}

// 2. DataSources (depend on Dio)
@LazySingleton(as: EmployeeRemoteDataSource)
class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource { ... }

// 3. Mappers (no dependencies)
@lazySingleton class EmployeeMapper { ... }

// 4. Repositories (depend on DataSource + Mapper)
@LazySingleton(as: EmployeeRepository)
class EmployeeRepositoryImpl implements EmployeeRepository { ... }

// 5. Use Cases (depend on Repository)
@lazySingleton class GetEmployeeUseCase { ... }

// 6. BLoCs (depend on Use Cases) — @injectable, not singleton
@injectable class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> { ... }
```

# Navigation

## Deep Link

### Theory

**Deep Links** are external URLs or URIs that navigate directly to a specific in-app destination.

**Invariants:**
- URI schemes and host patterns declared in platform manifests/info.plist — not in application code
- Deep link paths match route constant definitions exactly — no separate deep-link-only paths
- Screen always has a fallback when extra/prefetched data is unavailable (e.g., fetch by ID from path parameter)
- Auth guard applies to deep-linked routes — unauthenticated deep links redirect to login first

**When to create:** When a feature destination must be reachable from a notification, email link, or external app. Added alongside the route constant for that destination.

---

go_router handles deep links automatically when incoming URIs match declared route paths. Native intent-filter / URL scheme registration is required; no extra Dart configuration needed beyond route definitions.

### Code Pattern

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="example.com" />
</intent-filter>
```

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>https</string></array>
  </dict>
</array>
```

go_router routes that match the incoming URL are activated automatically. Ensure route paths align with the deep link URI paths:

```dart
GoRoute(
  path: '/employees/:id',
  builder: (context, state) => EmployeeScreen(
    employeeId: state.pathParameters['id']!,
  ),
),
```

## go_router

### Theory

**Route Constants** are named, centralized identifiers for every navigation destination in the app.

**Invariants:**
- All destination identifiers defined in a single constants file per feature or app — never hard-coded at the call site
- String paths (web/Flutter) or typed class references (Android/iOS) — platform dictates the form, the principle is the same
- Parameterised routes expose a typed helper function/method — callers never construct path strings inline
- Route constants exported from the feature or navigation module — consumers import the constant, not a string literal

**When to create:** Before any screen that navigates to a destination. Constants file created once per feature; entries added as destinations are added.

---

`go_router` is the standard Flutter navigation solution — declarative, deep-link ready. Define all route paths as constants. Never hard-code path strings.

### Code Pattern

```dart
// presentation/navigation/routes.dart
abstract class Routes {
  Routes._();
  static const String login = '/login';
  static const String employees = '/employees';
  static const String employeeDetail = '/employees/:id';
  static String employeeDetailPath(String id) => '/employees/$id';
}
```

```dart
// presentation/navigation/app_router.dart
@singleton
class AppRouter {
  AppRouter({required this.authCubit});
  final AuthCubit authCubit;

  late final router = GoRouter(
    initialLocation: Routes.employees,
    redirect: _guard,
    routes: [
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: Routes.employees,
        builder: (_, __) => const EmployeeListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => EmployeeDetailScreen(
              employeeId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );

  String? _guard(BuildContext context, GoRouterState state) {
    final isAuthenticated = authCubit.state.isAuthenticated;
    final isOnLoginPage = state.matchedLocation == Routes.login;
    if (!isAuthenticated && !isOnLoginPage) return Routes.login;
    if (isAuthenticated && isOnLoginPage) return Routes.employees;
    return null;
  }
}
```

```dart
// app.dart
MaterialApp.router(routerConfig: getIt<AppRouter>().router)
```

## Navigate From BLoC

### Theory

A **Navigation Action** is the signal emitted by a StateHolder to request navigation without the StateHolder knowing the destination implementation.

**Invariants:**
- Expressed as a typed value in the StateHolder's output (state field, Observable result, or action callback)
- Consumed by the UI layer (BlocListener, Coordinator subscribe, ViewModel hook) — never handled inside the StateHolder
- Cleared after consumption — the UI layer resets the navigation action field so it is not re-triggered on recomposition/re-render
- Carries only the data needed to resolve the destination (IDs, flags) — not the destination itself

**When to create:** Whenever a StateHolder needs to trigger navigation as a result of business logic (e.g., after a successful form submission or a delete confirmation).

---

BLoC never calls `Navigator` directly. It emits a typed `navAction` in state. `BlocListener` in the widget reads it and calls `context.go/push`. Clear the action after handling.

### Code Pattern

```dart
// In BLoC state — add a navigation action field
@freezed
class EmployeeState with _$EmployeeState {
  const factory EmployeeState({
    required ViewDataState<EmployeeEntity> employeeState,
    @Default(null) EmployeeNavAction? navAction,
  }) = _EmployeeState;
}

sealed class EmployeeNavAction {
  const factory EmployeeNavAction.goToEdit(String employeeId) = GoToEditAction;
  const factory EmployeeNavAction.popAfterDelete() = PopAfterDeleteAction;
}
```

```dart
// In Screen
BlocListener<EmployeeBloc, EmployeeState>(
  listenWhen: (prev, curr) => prev.navAction != curr.navAction,
  listener: (context, state) {
    final action = state.navAction;
    if (action == null) return;
    switch (action) {
      case GoToEditAction(:final employeeId):
        context.push(Routes.employeeEditPath(employeeId));
      case PopAfterDeleteAction():
        context.pop();
    }
    context.read<EmployeeBloc>().add(const EmployeeEvent.clearNavAction());
  },
  child: ...,
)
```

## Nested Navigation

### Theory

**Nested Navigation** preserves a persistent shell (tab bar, side nav, bottom nav) while navigating between child destinations.

**Invariants:**
- Persistent shell defined at the router/coordinator level — not duplicated in each child screen
- Child screens within the shell navigate without destroying the shell (push within the shell, not replace the root)
- Tab selection state owned by the shell — child screens do not manage tab state
- Deep links into a nested route restore the shell correctly — not just the leaf screen

**When to create:** When the app has a persistent navigation structure (tabs, sidebar) with independent navigation stacks per tab.

---

Use `ShellRoute` for persistent navigation bars (bottom nav, tab bars). The shell widget persists across tab changes.

### Code Pattern

```dart
GoRouter(
  routes: [
    ShellRoute(
      builder: (_, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeTab()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileTab()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsTab()),
      ],
    ),
  ],
)
```

# Error Handling

## App Exception

### Theory

Repository implementations own the mapping from transport errors to domain errors:

- HTTP 404 → `DomainError.notFound`
- HTTP 401/403 → `DomainError.unauthorized`
- HTTP 422 / validation response → `DomainError.validationFailed`
- Network timeout / no connection → `DomainError.networkUnavailable`
- HTTP 5xx / unexpected → `DomainError.serverError`
- Parse failure → `DomainError.serverError` (malformed response is a server problem)

Mappers never throw — they handle null/missing fields defensively and return safe defaults.

---

Typed exceptions thrown inside datasources. Lives in `data/exceptions/app_exception.dart`. DataSources only throw — they never return `Either`. The repository catches and converts to `Failure`.

**Boundary rule:**
- HTTP → DataSource: `ErrorInterceptor` catches `DioException`, attaches `AppException`
- DataSource → Repository: `catch (e on AppException)` → `Left(e.toFailure())`

### Code Pattern

```dart
// Throwing in a datasource
Future<EmployeeModel> getEmployee(String id) async {
  final response = await dio.get('/api/v1/employees/$id');
  final data = response.data as Map<String, dynamic>?;
  if (data == null || data['data'] == null) {
    throw AppException.server(
      message: 'Employee not found',
      statusCode: 404,
    );
  }
  return EmployeeModel.fromJson(data['data'] as Map<String, dynamic>);
}
```

```dart
// Catching in a repository
try {
  final model = await remoteDataSource.getEmployee(id);
  return Right(mapper.toEntity(model));
} on AppException catch (e) {
  return Left(e.toFailure());   // typed conversion
} catch (e, stackTrace) {
  debugPrint('Unexpected: $e\n$stackTrace');
  return Left(Failure.unknownFailure(message: e.toString()));
}
```

```dart
// HTTP 422 validation in the error interceptor
if (statusCode == 422) {
  final errors = (responseData?['errors'] as Map<String, dynamic>?);
  throw AppException.validation(
    message: responseData?['message'] as String? ?? 'Validation failed',
    errors: errors,
    statusCode: 422,
  );
}
```

Register `ErrorInterceptor` when creating Dio:

```dart
Dio(BaseOptions(baseUrl: '...'))
  ..interceptors.add(ErrorInterceptor());
```

## Error UI

### Theory

The StateHolder maps `DomainError` to an error State that the screen renders:

- **`notFound`** — show empty state with a descriptive message; offer navigation back
- **`validationFailed`** — show inline field errors; keep the form open for correction
- **`unauthorized`** — redirect to login or show a permission denied screen
- **`networkUnavailable`** — show offline banner with retry action
- **`serverError`** — show generic error with retry; log for observability

**Never show raw error messages or stack traces to users.** The StateHolder decides the user-facing copy; the Screen renders it.

---

Two patterns: inline error in `BlocBuilder` for blocking errors (full-screen), `BlocListener` toast/snackbar for non-blocking errors.

### Code Pattern

```dart
// Inline error in BlocBuilder
builder: (context, state) {
  if (state.dataState.hasError) {
    return ErrorView(
      message: state.dataState.message ?? 'Something went wrong',
      onRetry: () => context.read<EmployeeBloc>().add(const EmployeeEvent.refreshEmployee()),
    );
  }
  // ...
}
```

```dart
// Non-blocking toast via BlocListener
BlocListener<EmployeeBloc, EmployeeState>(
  listenWhen: (prev, curr) =>
      prev.submitState != curr.submitState && curr.submitState.hasError,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.submitState.message ?? 'Failed'),
        backgroundColor: Colors.red,
      ),
    );
  },
  child: ...,
)
```

## Failure Types

### Theory

Errors travel inward-to-outward, mapped at each layer boundary:

```
DataSource throws transport error (NetworkError, HTTP 4xx/5xx, DB exception)
    ↓ caught and mapped by
Repository Implementation → DomainError
    ↓ returned to
Use Case → propagates DomainError unchanged
    ↓ received by
StateHolder → maps to UI error State
    ↓ observed by
Screen → renders error UI
```

**Rule:** Each layer catches the error type from the layer below it and converts it to the type its consumers expect. No raw transport errors escape the Data layer. No domain errors escape the Presentation layer uncaught.

---

Error flow: HTTP → `AppException` → `Failure` → `ViewDataState.error`. Each layer converts, never forwards raw exceptions.

```
HTTP / Storage / Parse error
        ↓
Data layer throws AppException
        ↓
Repository catches → returns Left(Failure)
        ↓
UseCase passes through Either
        ↓
BLoC calls result.fold() → emits ViewDataState.error
        ↓
Widget reads state.hasError → shows UI
```

**Rules:**
1. DataSources throw, Repositories return Either — never mix
2. Never throw in domain or presentation
3. Always handle both fold arms
4. Keep user messages short — technical details in `developerMessage`
5. Field validation errors use `ValidationFailure`

### Code Pattern

```dart
// Accessing failure in a BLoC
result.fold(
  (failure) {
    final message = failure.when(
      serverFailure: (msg, _, __, ___) => msg,
      validationFailure: (msg, __, ___) => msg,
      networkFailure: (msg) => msg,
      unknownFailure: (msg) => msg,
      localFailure: (msg) => msg,
    );
    emit(state.copyWith(
      dataState: ViewDataState.error(message: message, failure: failure),
    ));
  },
  (data) => emit(state.copyWith(dataState: ViewDataState.loaded(data: data))),
);
```

## Validation Errors

### Theory

| Layer | Error type owned | Purpose |
|---|---|---|
| Data (transport) | Platform HTTP/network error | Represents wire failures — HTTP status, timeout, parse failure |
| Domain | `DomainError` | Business-meaningful error codes (`notFound`, `validationFailed`, `unauthorized`) |
| Presentation | UI error State | What the screen renders — message, retry action, recovery path |

**Domain error codes are business vocabulary** — `notFound`, `validationFailed`, `unauthorized`, `networkUnavailable`, `serverError`. Never use HTTP status codes as domain error codes.

---

API validation errors (HTTP 422) carry structured field errors keyed by field name. Handled as `ValidationFailure` — never encoded in the generic `message` string.

### Code Pattern

```dart
// In error interceptor — detect 422
if (statusCode == 422) {
  final errors = (responseData?['errors'] as Map<String, dynamic>?);
  throw AppException.validation(
    message: responseData?['message'] as String? ?? 'Validation failed',
    errors: errors,
    statusCode: 422,
  );
}
```

```dart
// In BLoC — read field-level errors
result.fold(
  (failure) {
    if (failure is ValidationFailure) {
      final fieldErrors = failure.errors as Map<String, dynamic>?;
      emit(state.copyWith(
        submitState: ViewDataState.error(message: failure.message, failure: failure),
        fieldErrors: fieldErrors,
      ));
    } else {
      emit(state.copyWith(
        submitState: ViewDataState.error(message: failure.message ?? 'Failed', failure: failure),
      ));
    }
  },
  (_) => emit(state.copyWith(submitState: ViewDataState.loaded())),
);
```

# Testing

## Mock Generation

### Theory

Mapper tests are pure input → output assertions — the simplest tests to write:

- Provide a fully-populated DTO → assert every field maps to the correct entity field
- Provide a DTO with missing/null optional fields → assert safe defaults or null handling
- No mocks needed — mappers have no dependencies

---

Declare all mocks for a feature in one file using `@GenerateNiceMocks`. Never mock Mappers — they are pure functions, instantiate directly.

Use `@GenerateNiceMocks` for interfaces. Pass mocks directly via constructor injection — avoid `getIt` in tests.

### Code Pattern

```dart
// test/helpers/mocks/employee_mocks.dart
@GenerateNiceMocks([
  MockSpec<EmployeeRepository>(),
  MockSpec<GetEmployeeUseCase>(),
  MockSpec<UpdateEmployeeUseCase>(),
  MockSpec<EmployeeRemoteDataSource>(),
])
void main() {}
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```dart
// test/helpers/fixtures/employee_fixtures.dart
const tEmployeeModel = EmployeeModel(id: '1', name: 'Alice', email: 'alice@example.com');
final tEmployeeEntity = EmployeeEntity(id: '1', name: 'Alice', email: 'alice@example.com');
final tServerFailure = Failure.serverFailure(message: 'Server error', developerMessage: 'HTTP 500');
```

## Naming Convention

### Theory

`[unit under test]_[scenario]_[expected outcome]`

Examples:
- `getEmployeeUseCase_whenRepositoryReturnsEmployee_emitsEmployee`
- `employeeMapper_whenDtoHasNullDepartment_mapsToDefaultDepartment`
- `employeeViewModel_whenFetchFails_emitsErrorState`

---

Test names describe intent in plain English. Use `given/when/then` or `returns X when Y` style for plain `test()`. Use full sentence for `blocTest`.

**Best practices:**
1. AAA — Arrange, Act, Assert — one concept per test
2. Use `blocTest` — never test BLoC by reading `.state` after `act`
3. Use `predicate<T>` when you care about shape, not exact value
4. Mock at the boundary — datasource for repository tests, repository for use case tests
5. Test both paths — success and failure for every method

### Code Pattern

```
// Plain test naming (returns X when Y)
'returns entity when repository succeeds'
'returns failure when repository fails'
'maps all fields correctly'
'handles null fields with defaults'

// blocTest naming (emits [...] when ...)
'emits [loading, loaded] when use case succeeds'
'emits [loading, error] when use case fails'
```

```
test/
  features/
    employee/
      data/
        mappers/employee_mapper_test.dart
        repositories/employee_repository_impl_test.dart
      domain/
        usecases/get_employee_usecase_test.dart
      presentation/
        blocs/employee_bloc_test.dart
  helpers/
    mocks/employee_mocks.dart
    fixtures/employee_fixtures.dart
```

## Presenter Test

### Theory

| Use a mock/stub when… | Use a real implementation when… |
|---|---|
| The dependency has I/O (network, DB, file) | The dependency is pure (mappers, domain services) |
| The test must control exact return values | The test verifies the full integration path |
| Speed matters — unit test suite | Correctness of wiring matters — integration test |

**Never mock domain services or mappers in unit tests** — they are pure functions; test them with real inputs and outputs.

---

Use `bloc_test` — never test BLoC state by calling `act` and inspecting `.state` manually. Always `setUp` mock return values, assert state sequence, verify use case call count.

### Code Pattern

```dart
// test/features/employee/presentation/blocs/employee_bloc_test.dart
void main() {
  late MockGetEmployeeUseCase mockGetUseCase;
  late MockUpdateEmployeeUseCase mockUpdateUseCase;
  late EmployeeBloc bloc;

  setUp(() {
    mockGetUseCase = MockGetEmployeeUseCase();
    mockUpdateUseCase = MockUpdateEmployeeUseCase();
    bloc = EmployeeBloc(
      getEmployeeUseCase: mockGetUseCase,
      updateEmployeeUseCase: mockUpdateUseCase,
    );
  });

  tearDown(() => bloc.close());

  group('LoadEmployee', () {
    blocTest<EmployeeBloc, EmployeeState>(
      'emits [loading, loaded] when use case succeeds',
      setUp: () {
        when(mockGetUseCase.call(any)).thenAnswer((_) async => Right(tEmployeeEntity));
      },
      build: () => bloc,
      act: (b) => b.add(const EmployeeEvent.loadEmployee(employeeId: '1')),
      expect: () => [
        isA<EmployeeState>().having((s) => s.employeeState.isLoading, 'isLoading', isTrue),
        isA<EmployeeState>().having((s) => s.employeeState.isLoaded, 'isLoaded', isTrue),
      ],
      verify: (_) => verify(mockGetUseCase.call('1')).called(1),
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'emits [loading, error] when use case fails',
      setUp: () {
        when(mockGetUseCase.call(any)).thenAnswer((_) async => Left(tServerFailure));
      },
      build: () => bloc,
      act: (b) => b.add(const EmployeeEvent.loadEmployee(employeeId: '1')),
      expect: () => [
        predicate<EmployeeState>((s) => s.employeeState.isLoading),
        predicate<EmployeeState>((s) => s.employeeState.hasError),
      ],
    );
  });
}
```

## Repository Test

### Theory

Repository implementation tests verify the bridge between DataSource and Domain:

- Use a test double (mock/stub) for the DataSource — not a real network or DB
- Assert that the repository maps DataSource output to the correct domain entity
- Assert that DataSource errors are caught and mapped to the correct domain error type
- One test per operation (get, create, update, delete)

---

Mock datasource and mapper. Test three paths: datasource succeeds, datasource throws `AppException`, datasource throws unexpected exception.

### Code Pattern

```dart
void main() {
  late MockEmployeeRemoteDataSource mockDataSource;
  late MockEmployeeMapper mockMapper;
  late EmployeeRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockEmployeeRemoteDataSource();
    mockMapper = MockEmployeeMapper();
    repository = EmployeeRepositoryImpl(remoteDataSource: mockDataSource, mapper: mockMapper);
  });

  group('getEmployee', () {
    test('returns entity when datasource succeeds', () async {
      when(mockDataSource.getEmployee(any)).thenAnswer((_) async => tEmployeeModel);
      when(mockMapper.toEntity(any)).thenReturn(tEmployeeEntity);
      final result = await repository.getEmployee('1');
      expect(result, Right(tEmployeeEntity));
    });

    test('returns failure when datasource throws AppException', () async {
      when(mockDataSource.getEmployee(any))
          .thenThrow(AppException.server(message: 'Not found', statusCode: 404));
      final result = await repository.getEmployee('1');
      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<ServerFailure>()), (_) => fail('Expected Left'));
    });

    test('returns unknownFailure for unexpected exceptions', () async {
      when(mockDataSource.getEmployee(any)).thenThrow(Exception('Crash'));
      final result = await repository.getEmployee('1');
      expect(result.isLeft(), isTrue);
    });
  });
}
```

## Test Pyramid

### Theory

```
         ┌──────────────────┐
         │   E2E Tests      │  few — critical user journeys only
         └────────┬─────────┘
         ┌────────┴─────────┐
         │ Integration Tests│  moderate — repository + datasource wiring
         └────────┬─────────┘
         ┌────────┴─────────┐
         │   Unit Tests     │  many — use cases, mappers, domain services
         └──────────────────┘
```

**Distribution target:** unit-heavy, integration-light, e2e-minimal. A test suite with more e2e than unit tests is inverted — slow, brittle, and expensive to maintain.

| Layer | Test targets | What to assert |
|---|---|---|
| Domain | Use cases, domain services | Business rules, edge cases, error conditions |
| Data | Mappers, repository implementations | DTO → entity mapping correctness; error mapping from transport to domain |
| Presentation | StateHolder (ViewModel/BLoC) | State transitions for each event; correct use case calls; action emissions |
| UI | Screen rendering | Correct state → UI binding; event dispatch on user interaction |

---

Tests mirror the feature's layer structure. Each layer has a dedicated subdirectory under `test/features/{feature}/`. Mocks live in `test/helpers/mocks/` as generated files; fixtures live in `test/helpers/fixtures/`.

### Code Pattern

```
test/
├── features/
│   └── employee/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── employee_remote_data_source_test.dart
│       │   ├── mappers/
│       │   │   └── employee_mapper_test.dart
│       │   └── repositories/
│       │       └── employee_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       └── get_employee_usecase_test.dart
│       └── presentation/
│           └── blocs/
│               └── employee_bloc_test.dart
├── helpers/
│   ├── mocks/
│   │   └── employee_mocks.dart     ← @GenerateNiceMocks declarations
│   └── fixtures/
│       └── employee_fixture.json
└── test_helper.dart
```

### Definition

| Layer | What to test |
|---|---|
| DataSource | Correct HTTP call, response parsing, throws `AppException` on bad response |
| Mapper | `toEntity()` and `fromJson()` field mapping |
| Repository | `Either` return, exception → `Failure` conversion |
| UseCase | Delegates to repository, passes params correctly |
| BLoC | State transitions per event, correct use case calls |

## Use Case Test

### Theory

| Layer | Test targets | What to assert |
|---|---|---|
| Domain | Use cases, domain services | Business rules, edge cases, error conditions |
| Data | Mappers, repository implementations | DTO → entity mapping correctness; error mapping from transport to domain |
| Presentation | StateHolder (ViewModel/BLoC) | State transitions for each event; correct use case calls; action emissions |

---

Mock the repository, pass directly via constructor. Verify call count and both success/failure paths.

### Code Pattern

```dart
void main() {
  late MockEmployeeRepository mockRepository;
  late GetEmployeeUseCase useCase;

  setUp(() {
    mockRepository = MockEmployeeRepository();
    useCase = GetEmployeeUseCase(repository: mockRepository);
  });

  group('GetEmployeeUseCase', () {
    test('returns entity when repository succeeds', () async {
      when(mockRepository.getEmployee(any)).thenAnswer((_) async => Right(tEmployeeEntity));
      final result = await useCase('1');
      expect(result, Right(tEmployeeEntity));
      verify(mockRepository.getEmployee('1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns failure when repository fails', () async {
      when(mockRepository.getEmployee(any)).thenAnswer((_) async => Left(tServerFailure));
      final result = await useCase('1');
      expect(result.isLeft(), isTrue);
    });
  });
}
```

# Utilities

## Date Service

### Theory

**DateService** is a centralized abstraction for all date and time operations — formatting, parsing, comparison, and timezone handling.

**Invariants:**
- All date formatting and parsing goes through `DateService` — never via inline format strings or `SimpleDateFormat`/`DateFormatter` at call sites
- Timezone handling is explicit — never assume device timezone in business logic
- The interface is injectable for testing — implementations can return fixed dates in tests

**When to use:** Any layer that formats, parses, or compares dates. Domain layer may define date-related value objects; `DateService` handles the conversion to/from display and wire formats.

---

Centralized date handling with timezone and formatting. Interface-based for testability. Uses `intl` package. Registered via `@LazySingleton(as: DateService)`.

### Code Pattern

```dart
// core/date/date_service.dart
abstract class DateService {
  DateTime get now;
  String format(DateTime date, DateFormatStyle style, {String locale});
  DateTime? parse(String value, DateFormatStyle style);
  DateTime startOfDay(DateTime date);
  DateTime endOfDay(DateTime date);
  DateTime addDays(DateTime date, int days);
  int daysBetween(DateTime start, DateTime end);
  bool isSameDay(DateTime a, DateTime b);
  bool isToday(DateTime date);
  bool isPast(DateTime date);
  bool isFuture(DateTime date);
}

enum DateFormatStyle {
  iso8601,        // "2024-01-15T14:30:00Z"
  apiDate,        // "2024-01-15"
  apiDateTime,    // "2024-01-15 14:30:00"
  displayDate,    // "Jan 15, 2024"
  displayDateTime,// "Jan 15, 2024, 2:30 PM"
  displayTime,    // "2:30 PM"
  relative,       // "2 days ago"
}
```

```dart
// core/date/date_service_impl.dart
@LazySingleton(as: DateService)
class DateServiceImpl implements DateService {
  @override
  DateTime get now => DateTime.now();

  @override
  String format(DateTime date, DateFormatStyle style, {String locale = 'en_US'}) {
    return switch (style) {
      DateFormatStyle.iso8601 => date.toIso8601String(),
      DateFormatStyle.apiDate => DateFormat('yyyy-MM-dd').format(date),
      DateFormatStyle.apiDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      DateFormatStyle.displayDate => DateFormat.yMMMd(locale).format(date),
      DateFormatStyle.displayDateTime => DateFormat.yMMMd(locale).add_jm().format(date),
      DateFormatStyle.displayTime => DateFormat.jm(locale).format(date),
      DateFormatStyle.relative => _relative(date),
    };
  }

  String _relative(DateTime date) {
    final diff = now.difference(date);
    if (diff.inDays.abs() > 0)
      return '${diff.inDays.abs()} day${diff.inDays.abs() == 1 ? '' : 's'} ${diff.isNegative ? 'from now' : 'ago'}';
    if (diff.inHours.abs() > 0)
      return '${diff.inHours.abs()} hour${diff.inHours.abs() == 1 ? '' : 's'} ${diff.isNegative ? 'from now' : 'ago'}';
    return 'just now';
  }

  @override
  DateTime? parse(String value, DateFormatStyle style) {
    try {
      return switch (style) {
        DateFormatStyle.iso8601 => DateTime.parse(value),
        DateFormatStyle.apiDate => DateFormat('yyyy-MM-dd').parse(value),
        DateFormatStyle.apiDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').parse(value),
        _ => DateTime.tryParse(value),
      };
    } catch (_) { return null; }
  }

  @override
  DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
  @override
  DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  @override
  DateTime addDays(DateTime date, int days) => date.add(Duration(days: days));
  @override
  int daysBetween(DateTime start, DateTime end) => end.difference(start).inDays;
  @override
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  @override
  bool isToday(DateTime date) => isSameDay(date, now);
  @override
  bool isPast(DateTime date) => date.isBefore(now);
  @override
  bool isFuture(DateTime date) => date.isAfter(now);
}
```

## Logger

### Theory

**Logger** is the centralized logging abstraction with severity levels. All log output goes through this interface.

**Invariants:**
- Severity levels: `debug`, `info`, `warning`, `error` — each with distinct routing (debug stripped in production)
- No `print` / `console.log` / `Log.d` calls at call sites — always use the Logger interface
- Sensitive data (tokens, PII) must never appear in log output
- The implementation routes to Crashlytics or the platform crash reporter for `error`-level events

**When to use:** Any layer that needs diagnostic output. Inject `Logger` — never call the platform logging API directly.

---

Structured logging using the `logger` package. Interface-based so implementation can be swapped per environment. Debug level in development, warning+ in release. Registered via `@LazySingleton(as: AppLogger)`.

### Code Pattern

```dart
// core/logger/app_logger.dart
abstract class AppLogger {
  void debug(String message, {Object? error, StackTrace? stackTrace});
  void info(String message, {Object? error, StackTrace? stackTrace});
  void warning(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
}

@LazySingleton(as: AppLogger)
class AppLoggerImpl implements AppLogger {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
```

```dart
// Usage via constructor injection
class EmployeeRepositoryImpl implements EmployeeRepository {
  final AppLogger _logger;
  EmployeeRepositoryImpl(this._logger);

  @override
  Future<Either<Failure, Employee>> getEmployee(String id) async {
    try {
      // ...
    } catch (e, stack) {
      _logger.error('getEmployee failed', error: e, stackTrace: stack);
      return Left(Failure.unknownFailure(message: e.toString()));
    }
  }
}
```

## Storage Service

### Theory

**StorageService** is an interface-based key-value store for persisting tokens, user preferences, and cached data across app sessions.

**Invariants:**
- The interface lives in the infrastructure layer — never in domain or data
- All keys are typed constants (enum or sealed class) — never raw strings at call sites
- Implementations are swappable per environment (e.g. in-memory for tests, secure storage for production)
- `clearAll()` is only called on logout — never on individual feature teardown

**When to use:** Any layer that needs to read or write persistent state. Inject the interface — never access the concrete implementation directly.

---

Abstracts key-value storage behind an interface. `SharedPreferences` for preferences; `FlutterSecureStorage` for tokens. Registered via `@LazySingleton(as: StorageService)`. Sensitive keys (tokens) must use the secure implementation.

### Code Pattern

```dart
// core/storage/storage_service.dart
abstract class StorageService {
  Future<void> set<T>(StorageKey key, T value);
  Future<T?> get<T>(StorageKey key);
  Future<void> remove(StorageKey key);
  Future<void> clearAll();
  Future<bool> contains(StorageKey key);
}

enum StorageKey {
  accessToken, refreshToken, tokenExpiration,
  userId, userEmail, lastSyncDate,
  onboardingCompleted, lastSelectedTab,
}
```

```dart
// core/storage/shared_preferences_storage_service.dart
@LazySingleton(as: StorageService)
class SharedPreferencesStorageService implements StorageService {
  final SharedPreferences _prefs;
  SharedPreferencesStorageService(this._prefs);

  @override
  Future<void> set<T>(StorageKey key, T value) async {
    final k = key.name;
    if (value is String) await _prefs.setString(k, value);
    else if (value is int) await _prefs.setInt(k, value);
    else if (value is bool) await _prefs.setBool(k, value);
    else await _prefs.setString(k, jsonEncode(value));
  }

  @override
  Future<T?> get<T>(StorageKey key) async {
    final k = key.name;
    if (T == String) return _prefs.getString(k) as T?;
    if (T == int) return _prefs.getInt(k) as T?;
    if (T == bool) return _prefs.getBool(k) as T?;
    final raw = _prefs.getString(k);
    return raw != null ? jsonDecode(raw) as T? : null;
  }

  @override
  Future<void> remove(StorageKey key) async => _prefs.remove(key.name);

  @override
  Future<void> clearAll() async {
    for (final key in StorageKey.values) { await remove(key); }
  }

  @override
  Future<bool> contains(StorageKey key) async => _prefs.containsKey(key.name);
}
```

```dart
// Secure storage for tokens
@Named('secure')
@LazySingleton(as: StorageService)
class SecureStorageService implements StorageService {
  final FlutterSecureStorage _storage;
  static const _sensitiveKeys = {StorageKey.accessToken, StorageKey.refreshToken};

  SecureStorageService(@Named('flutterSecureStorage') this._storage);

  @override
  Future<void> set<T>(StorageKey key, T value) async {
    if (_sensitiveKeys.contains(key)) {
      await _storage.write(key: key.name, value: value.toString());
    }
  }

  @override
  Future<T?> get<T>(StorageKey key) async => await _storage.read(key: key.name) as T?;

  @override
  Future<void> remove(StorageKey key) => _storage.delete(key: key.name);

  @override
  Future<void> clearAll() async => _storage.deleteAll();

  @override
  Future<bool> contains(StorageKey key) async =>
      (await _storage.read(key: key.name)) != null;
}
```
