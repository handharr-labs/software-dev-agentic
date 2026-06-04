---
platform: flutter
discipline: engineering
topic: data
pattern: creation_order
---

## Theory

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

## Code Pattern

```
1. data/models/[feature]_model.dart                          ← DTO (@freezed, fromJson, .g.dart)
   data/models/[feature]_payload.dart                        ← Write payload (if POST/PUT)
2. data/mappers/[feature]_mapper.dart                        ← Mapper (BaseMapper subclass)
3. data/datasources/[feature]_remote_data_source.dart        ← DataSource abstract class
   data/datasources/[feature]_remote_data_source_impl.dart   ← DataSource implementation (Dio)
4. data/repositories/[feature]_repository_impl.dart          ← Repository implementation
```
