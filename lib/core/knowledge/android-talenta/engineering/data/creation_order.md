---
platform: android
project: android-talenta
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

## Definition

When building a new feature's data layer, create files in this sequence.

## Code Pattern

```
1. data/response/[Feature]Response.kt               ← DTO (*Response suffix, all nullable, @SerializedName)
2. data/mapper/[Feature]Mapper.kt                   ← Mapper (extends BaseMapper<Response, Entity>)
3. service/[Feature]Api.kt                          ← DataSource (Retrofit interface, *Api suffix)
4. data/repoimpl/[Feature]RepositoryImpl.kt         ← Repository implementation
```

Never create a repository implementation before the Retrofit API interface it depends on.
