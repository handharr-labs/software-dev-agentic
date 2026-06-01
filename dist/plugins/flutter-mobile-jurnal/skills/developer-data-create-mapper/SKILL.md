---
name: developer-data-create-mapper
description: Create a Mapper class that converts a DTO response to a domain entity.
user-invocable: false
---

Create a Mapper following `.claude/reference/code-architecture/data-impl.md ## Mappers section`.

## Steps

1. **Grep** `.claude/reference/code-architecture/data-impl.md` for `## Mappers`; only **Read** the full file if the section cannot be located
2. **Read** the Response model and the Entity to map all fields
3. **Locate** path: `features/<feature>/lib/src/data/mappers/`
4. **Create** `<feature>_mapper.dart`
5. **Export** from `mappers.dart` barrel
6. **Register** as singleton in `Jurnal<Feature>Injector.init()` under Mappers section

## Mapper Pattern

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
        // map every field; supply domain defaults for nullables
      );

  // For list responses:
  List<<Entity>> responseToEntityList(<Feature>ListResponse response) =>
      response.items?.map(responseToEntity).toList() ?? [];
}
```

**Rules:**
- `const` constructor — mappers are stateless value objects
- `fromJsonToResponse` extracts root key (e.g. `response['product']`, `response['data']`)
- `responseToEntity` provides domain-safe defaults for all nullable response fields
- Registered as `registerSingletonIfAbsent` in the injector (mappers section, before datasources)

## Output

Confirm file path, list all field mappings (response field → entity field), and injector line.
