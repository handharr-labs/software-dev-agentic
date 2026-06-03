---
platform: android
project: android-talenta
discipline: engineering
topic: domain
pattern: dependency_rule
---

## Theory

Domain is the innermost layer. It imports nothing from outer layers.

```
UI  →  Presentation  →  Data  →  Domain
```

Allowed imports: language primitives and pure functional utilities only.
Forbidden: any framework, UI library, HTTP client, database driver, or data-layer type.

---

## Definition

Domain is the innermost layer — it imports nothing from outer layers.

**Allowed:** Kotlin standard library (`kotlin.*`), `java.io.Serializable`, `RxJava3` schedulers used only in the base `UseCase` infrastructure.

**Forbidden:**
- `import retrofit2.*` — networking belongs in data
- `import androidx.*` — any AndroidX import signals a framework dependency
- Room annotations (`@Entity`, `@ColumnInfo`) — database concerns belong in data
- OkHttp types — HTTP client belongs in data
- Any `*Response`, `*Api`, or `*RepositoryImpl` type from the data layer

## Code Pattern

```kotlin
// domain/entity/TimeOffRequest.kt
// ✅ Pure Kotlin — no framework imports
data class TimeOffRequest(
    val id: String,
    val employeeId: String,
    val startDate: String,
    val endDate: String,
    val reason: String,
    val status: String,
    val totalDays: Int
)

// ❌ Never inside domain:
// import retrofit2.*
// import androidx.room.*
// import okhttp3.*
```
