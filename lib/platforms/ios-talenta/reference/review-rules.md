# iOS PR Review Rules

Conventions checked during PR review for the Talenta iOS project.

---

## 10 Convention Checks <!-- 174 -->

### 1. Safe Unwrapping (HIGH)

Use extensions — never `??` operator.

```swift
// ❌
let text = someString ?? ""
let count = someInt ?? 0

// ✅
let text = someString.orEmpty()
let count = someInt.orZero()
let flag = someBool.orFalse()
```

**Parentheses rule for optional chaining:**
```swift
// ❌ wrong — applies .orEmpty() to non-optional result
model.data?.title.orEmpty()

// ✅ correct — wraps the optional chain
(model.data?.title).orEmpty()
```

Extensions: `Extension+String?.swift` (`.orEmpty()`), `Extension+Int?.swift` (`.orZero()`), `Extension+Bool?.swift` (`.orFalse()`).

---

### 2. `weak self` in Closures (HIGH)

Required in all closures that reference `self` (RxSwift, completion handlers).

```swift
// ❌
.drive(onNext: { data in self.label.text = data.title })

// ✅
.drive(onNext: { [weak self] data in self?.label.text = data.title })
```

Not needed: pure functions with no `self`, value-type closures.

---

### 3. `distinctUntilChanged()` on Bindings

Prevents redundant UI updates on every state emission.

```swift
// ❌
.compactMap({ $0.dataState.data }).drive(onNext: { self?.configure($0) })

// ✅ (Equatable field)
.compactMap({ $0.dataState.data?.title }).distinctUntilChanged().drive(onNext: { ... })

// ✅ (non-Equatable model)
.map({ (a: $0.fieldA, b: $0.fieldB) })
.distinctUntilChanged({ $0.a == $1.a && $0.b == $1.b })
.drive(onNext: { ... })
```

---

### 4. `.disposed(by: disposeBag)` on All Subscriptions

```swift
// ❌ subscription leak
observable.subscribe(onNext: { ... })

// ✅
observable.subscribe(onNext: { ... }).disposed(by: disposeBag)
```

Cells: reset `disposeBag` in `prepareForReuse()`.

---

### 5. No New Code in Legacy Folders (HIGH)

```
// ❌ legacy
Talenta/Models/   Talenta/Controllers/   Talenta/ViewModels/

// ✅ module structure
Talenta/Module/{Feature}/Data/Models/
Talenta/Module/{Feature}/Domain/Entities/
Talenta/Module/{Feature}/Presentation/ViewModel/
```

Module mapping: Auth → `feature_auth/`, Payroll → `TalentaPayslip/`, Attendance/TM → `TalentaTM/`, Employee → `TalentaECM/`, Dashboard → `TalentaDashboard/`, Custom Forms → `feature_integration/`, Shared → `Talenta/Shared/`.

---

### 6. `final` on Leaf Classes

```swift
// ❌ (leaf UIKit subclass)
class CustomButton: UIButton { }

// ✅
final class CustomButton: UIButton { }
```

Not for base classes designed for inheritance (e.g., `BaseViewController`).

---

### 7. Mapper Field Omissions

Swift default parameter values let mapper omissions compile silently — field always produces empty data.

```swift
// ❌ timezone silently defaults to ""
return FeatureModel(id: from.id.orZero(), name: from.name.orEmpty())

// ✅ all fields explicitly mapped
return FeatureModel(
    id: from.id.orZero(),
    name: from.name.orEmpty(),
    timezone: from.timezone.orEmpty()
)
```

Also verify: Response DTO has the field with correct `CodingKeys` (snake_case → camelCase).

---

### 8. Magic Numbers

```swift
// ❌
if query.count >= 3 { }
view.layer.cornerRadius = 8

// ✅
private let kMinSearchQueryLength = 3
if query.count >= kMinSearchQueryLength { }
view.layer.cornerRadius = MpRadius.medium  // use MekariPixel tokens for design values
```

---

### 9. Nested RxSwift Subscriptions

```swift
// ❌ nested subscribe inside drive
.drive(onNext: { [weak self] _ in
    self?.obs.subscribe(...).disposed(by: self?.disposeBag ?? DisposeBag())
})

// ✅ flatten with combineLatest or flatMap
Observable.combineLatest(obs1, obs2)
    .subscribe(onNext: { [weak self] a, b in self?.handle(a, b) })
    .disposed(by: disposeBag)
```

---

### 10. `Result<Success, BaseErrorModel>` Pattern

```swift
// ❌
func fetchData(completion: @escaping (Data?, Error?) -> Void)

// ✅
func fetchData(completion: @escaping (Result<FeatureModel, BaseErrorModel>) -> Void)
```

All UseCase and Repository completions must use `Result<Success, BaseErrorModel>`.

---

## PR Comment Placement <!-- 16 -->

- **Line-specific**: Isolated issue on a known line → inline comment on that line
- **General/multi-location**: Fix spans multiple files → comment on problematic line + explain other locations
- **Architectural**: Pattern-level issue → file-level comment, no line numbers

Multi-location format:
```
Comment at line N (where the issue is):
"Field X is missing. Fix requires:
1. Add to Response DTO with CodingKeys
2. Add here: field: from.field.orEmpty()"
```

---

## Review Output Format <!-- 3 -->

```markdown
## PR Review: {PR_TITLE} <!-- 6 -->

### 📊 Overview
- **Branch**: {branch}
- **Overall Assessment**: [✅ APPROVE | ⚠️ CHANGES REQUESTED]

## ✅ Positive Findings <!-- 3 -->
### 1. **{Category}** — {good practice noted}

## ⚠️ Issues Found <!-- 6 -->
### N. **[HIGH/MED/LOW] {Issue Title}**
**File**: path:line
❌ Current: {code}
✅ Fix: {code}

## 📋 Summary by File <!-- 3 -->
| File | Issues | Status |

## 🎯 Action Items <!-- 3 -->
1. path:line — fix description

## 💡 Final Recommendation <!-- 6 -->
**APPROVE / CHANGES_REQUESTED**
```

---

## Checklist (15 points) <!-- 20 -->

- [ ] `.orEmpty()` / `.orZero()` / `.orFalse()` — no `?? ""`
- [ ] Parentheses rule: `(chain?.field).orEmpty()`
- [ ] `[weak self]` in all closures referencing self
- [ ] `distinctUntilChanged()` on all bindings
- [ ] `.disposed(by: disposeBag)` on all subscriptions
- [ ] `prepareForReuse()` resets `disposeBag` in cells
- [ ] No new files in `Models/`, `Controllers/`, `ViewModels/`
- [ ] Leaf UIKit classes marked `final`
- [ ] All mapper args match entity fields (no silent defaults)
- [ ] Response DTO has correct `CodingKeys`
- [ ] Magic numbers extracted to named constants or MekariPixel tokens
- [ ] No nested RxSwift subscriptions
- [ ] Completions use `Result<Success, BaseErrorModel>`
- [ ] Tests exist for new UseCases, Repositories, ViewModels
- [ ] Generated files skipped (`.generated.swift`, Needle files)

---

## Do NOT Comment On <!-- 10 -->

- Legacy code not touched in this PR
- Already-fixed issues (acknowledge as positive instead)
- V2 migration suggestions on existing code
- Generated files (`.generated.swift`, R.generated.swift, Needle)
- Intentional design decisions

---

## Quick Reference <!-- 17 -->

| Pattern | Status | Fix |
|---------|--------|-----|
| `?? ""` | ❌ | `.orEmpty()` |
| `?? 0` | ❌ | `.orZero()` |
| `?? false` | ❌ | `.orFalse()` |
| `data?.field.orEmpty()` | ❌ | `(data?.field).orEmpty()` |
| Closure without `[weak self]` | ❌ | Add `[weak self]`, use `self?.` |
| Binding without `distinctUntilChanged()` | ⚠️ | Add after `.compactMap` |
| Subscription without `.disposed(by:)` | ❌ | Add `.disposed(by: disposeBag)` |
| New file in `Models/` or `Controllers/` | ❌ | Move to `Talenta/Module/` |
| `class Foo: UILabel` (leaf) | ⚠️ | `final class Foo: UILabel` |
| Mapper missing entity field | ❌ | Add field explicitly |
| Magic literal | ⚠️ | Named constant or MekariPixel token |
| Nested `.subscribe` inside `.drive` | ❌ | Flatten with `flatMap`/`combineLatest` |
| `(Data?, Error?)` completion | ❌ | `Result<Model, BaseErrorModel>` |
