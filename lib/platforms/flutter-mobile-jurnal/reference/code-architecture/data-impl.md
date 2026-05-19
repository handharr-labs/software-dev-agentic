## DTOs

Response models (DTOs) live in `features/<feature>/lib/src/data/models/responses/` and request payloads in `features/<feature>/lib/src/data/models/requests/`. They use `freezed` + `json_serializable` (`@freezed` with `fromJson`/`toJson`). A `models.dart` barrel re-exports all.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jurnal_core/jurnal_core.dart';

part '<feature>_response.freezed.dart';
part '<feature>_response.g.dart';

@freezed
class <Feature>Response with _$<Feature>Response {
  const factory <Feature>Response({
    @JsonKey(fromJson: JsonParser.parseIntOrNull) int? id,
    String? name,
    @JsonKey(
      readValue: JsonParser.readTotalPages,
      fromJson: JsonParser.parseIntOrNull,
    ) int? totalPages,
  }) = _<Feature>Response;

  factory <Feature>Response.fromJson(Map<String, dynamic> json) =>
      _$<Feature>ResponseFromJson(json);
}
```

**Conventions:**
- Response: `<Feature>Response`, `<Feature>ListResponse`
- Request/payload: `<Verb><Feature>Request` (e.g. `GetExpenseListRequest`, `CreateProductRequest`)
- Use `JsonParser.parseIntOrNull` / `parseDoubleOrNull` for numeric fields that may arrive as String
- Use `JsonParser.readTotalPages` for pagination fields with key variance (`total_page` vs `total_pages`)
- `toCleanJson()` is used on request models to strip null values before sending

---

## Mappers

Mappers live in `features/<feature>/lib/src/data/mappers/` and are plain Dart classes (no annotations, no DI framework). Each mapper class has `const` constructor.

Two main mapper method shapes:

1. `fromJsonToResponse(Map<String, dynamic>? response) → <Feature>Response?` — wraps `fromJson` and handles null root key extraction
2. `responseToEntity(<Feature>Response response) → <Entity>` — maps DTO fields to domain entity fields

```dart
import 'package:jurnal_<feature>/src/data/data.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';

class <Feature>Mapper {
  const <Feature>Mapper();

  <Feature>Response? fromJsonToResponse(Map<String, dynamic>? response) {
    if (response == null) return null;
    return <Feature>Response.fromJson(response['<root_key>']);
  }

  <Entity> responseToEntity(<Feature>Response response) => <Entity>(
        id: response.id ?? 0,
        name: response.name ?? '',
        // map all fields; supply domain defaults for nullables
      );
}
```

**Conventions:**
- Mapper class name: `<Feature>Mapper` (e.g. `ProductStockMapper`, `ExpenseMapper`)
- File name: `<feature>_mapper.dart`
- `const` constructor — mappers are stateless
- Mappers registered as singletons in `JurnalProductInjector` / feature injector class

---

## Data Sources

DataSource interfaces and implementations live in `features/<feature>/lib/src/data/datasources/`. Remote datasources in `remote/`, local in `local/`.

```dart
// Abstract
abstract class <Feature>RemoteDatasource {
  Future<<Feature>Response?> get<Feature>(int id);
  Future<<Feature>ListResponse?> get<Feature>List({
    int? page,
    int? pageSize,
    String? searchQuery,
  });
  Future<void> delete<Feature>(int id);
}

// Implementation
class <Feature>RemoteDatasourceImpl extends <Feature>RemoteDatasource {
  final NetworkClient client;
  final <Feature>Mapper mapper;

  <Feature>RemoteDatasourceImpl(this.client, this.mapper);

  @override
  Future<<Feature>Response?> get<Feature>(int id) async {
    final result = await client.get(<Feature>EndPoint.<feature>(id));
    return mapper.fromJsonToResponse(result);
  }

  @override
  Future<<Feature>ListResponse?> get<Feature>List({
    int? page,
    int? pageSize,
    String? searchQuery,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'keyword': searchQuery,
    }..removeWhere((_, v) => v == null);
    final result = await client.get(<Feature>EndPoint.<feature>s, params: params);
    return mapper.fromJsonToResponse(result);
  }
}
```

**Conventions:**
- `<Feature>RemoteDatasource` (abstract) / `<Feature>RemoteDatasourceImpl` (concrete)
- `NetworkClient` (from `jurnal_core`) is the HTTP client — never instantiate `Dio` directly
- Params map uses `..removeWhere((_, v) => v == null)` to strip nulls before sending
- `client.get`, `client.post`, `client.put`, `client.delete`, `client.postFormData` for multipart
- Endpoint constants live in a `<Feature>EndPoint` class with static `String` constants

---

## Repository Impl

Repository implementations live in `features/<feature>/lib/src/data/repositories/remote/` and extend the domain abstract class. They use `catchError()` inherited from `BaseRemoteRepository`.

```dart
import 'package:jurnal_core/jurnal_core.dart';
import 'package:jurnal_<feature>/src/data/data.dart';
import 'package:jurnal_<feature>/src/domain/domains.dart';

class <Feature>RemoteRepositoryImpl extends <Feature>RemoteRepository {
  final <Feature>RemoteDatasource datasource;
  final <Feature>Mapper mapper;

  const <Feature>RemoteRepositoryImpl({
    required this.datasource,
    required this.mapper,
  });

  @override
  Future<Result<<Entity>?>> get<Entity>(int id) =>
      catchError(() async {
        final response = await datasource.get<Entity>(id);
        if (response == null) return Result.success(null);
        return Result.success(mapper.responseToEntity(response));
      });

  @override
  Future<Result<<Entity>List?>> get<Entity>List({int page = 1, int pageSize = 20}) =>
      catchError(() async {
        final response = await datasource.get<Entity>List(page: page, pageSize: pageSize);
        if (response == null) return Result.success(null);
        return Result.success(mapper.responseToEntityList(response));
      });
}
```

**Conventions:**
- Extends domain abstract class (not `implements`)
- `catchError(() async { ... })` wraps every method — never try/catch manually
- `Result.success(null)` when the API returns null (not a failure)
- Named constructor parameters (`required this.datasource`)
- `const` constructor when no late fields
