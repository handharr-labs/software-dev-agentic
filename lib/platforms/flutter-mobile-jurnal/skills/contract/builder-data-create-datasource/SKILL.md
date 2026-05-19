---
name: builder-data-create-datasource
description: Create a RemoteDatasource abstract class and its NetworkClient-based implementation for a feature.
user-invocable: false
---

Create a DataSource following `.claude/reference/code-architecture/data-impl.md ## Data Sources section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/data-impl.md` for `## Data Sources`; only **Read** the full file if the section cannot be located
2. **Verify** the Response model exists — run `builder-data-create-mapper` first if missing
3. **Check** if a Request model is needed for write operations — create in `data/models/requests/` if so
4. **Locate** path: `features/<feature>/lib/src/data/datasources/remote/`
5. **Create** `<feature>_remote_datasource.dart` (abstract + impl in same file)
6. **Export** from `remote.dart` → `datasources.dart` barrel
7. **Register** in `Jurnal<Feature>Injector.init()` under DataSources section

## DataSource Pattern

```dart
import 'package:jurnal_core/jurnal_core.dart';
import 'package:jurnal_<feature>/src/data/data.dart';

abstract class <Feature>RemoteDatasource {
  Future<<Feature>Response?> get<Feature>(int id);
  Future<<Feature>ListResponse?> get<Feature>List({
    int? page,
    int? pageSize,
    String? searchQuery,
  });
  Future<void> delete<Feature>(int id);
}

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

  @override
  Future<void> delete<Feature>(int id) =>
      client.delete(<Feature>EndPoint.delete(id));
}
```

**Rules:**
- `NetworkClient` from `jurnal_core` — never instantiate Dio directly
- Params map uses `..removeWhere((_, v) => v == null)` to strip nulls
- Use `client.postFormData` for multipart uploads
- Endpoint constants in `<Feature>EndPoint` class (static `String` methods/constants)

## Output

Confirm file path, list all declared method signatures, and injector registration line.
