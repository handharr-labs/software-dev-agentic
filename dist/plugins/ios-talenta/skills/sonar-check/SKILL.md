---
name: sonar-check
description: |
  Simulates SonarQube quality gate locally on new Swift code introduced
  in the current branch vs develop. Use when asked to run sonar check,
  validate quality gate, check code quality metrics, or analyse new code
  for sonar compliance.
user-invocable: true
---

# Sonar Check

## Purpose

Simulate SonarQube's "Sonar way" quality gate (Community v24.12) locally
on **new code** (current branch vs `develop`). Identify violations, list
them with context, get user confirmation, then fix all at once.

Project: `co.mekari:talenta-ios` — iOS HR app / Swift + UIKit
Quality profile: **Swift** (Sonar way)

---

## Quality Gate — Sonar Way

| Metric                  | Operator     | Threshold |
|-------------------------|--------------|-----------|
| Coverage                | less than    | 80%       |
| Duplicated Lines (%)    | greater than | 3%        |
| Maintainability Rating  | worse than   | A         |
| Reliability Rating      | worse than   | A         |
| Security Rating         | worse than   | A         |

> Security Hotspots Reviewed: **SKIPPED** (requires manual review in UI)

Rating A = zero new issues of that type on new code.

---

## SonarQube Rule Sources

Fetch at runtime — these are the active Sonar Way profile keys on
`next.sonarqube.com` (same rule set as SonarQube Community v24.12):

| Language | Profile Key              | Active Rules | Fetched at runtime? |
|----------|--------------------------|--------------|---------------------|
| Swift    | `AWWt7SJ4QwUgk31erFvb`   | 78 (1 page)  | YES — primary tool  |

**Fetch Swift rules (1 page, all 78 rules):**

```
https://next.sonarqube.com/sonarqube/api/rules/search?qprofile=AWWt7SJ4QwUgk31erFvb&activation=true&ps=100&p=1
```

Each rule has `key`, `type` (BUG / CODE_SMELL / VULNERABILITY /
SECURITY_HOTSPOT), `severity`, and `impacts[].softwareQuality`
(RELIABILITY / MAINTAINABILITY / SECURITY).

Build an in-memory map: `ruleKey → { type, softwareQuality }`

This map is used to enrich SwiftLint findings with the exact SonarQube rule
type when a SwiftLint rule ID matches a Swift Sonar Way key. For findings
with no direct match, fall back to the SwiftLint category table below.

---

## Local Tool → SonarQube Type Mapping

### SwiftLint (Swift — primary static analysis)

Run SwiftLint with JSON reporter to get structured output:

```bash
swiftlint lint --reporter json 2>/dev/null
```

Each finding in the JSON output:
```json
{
  "file": "/absolute/path/to/File.swift",
  "line": 42,
  "character": 5,
  "severity": "warning|error",
  "type": "RuleName Violation",
  "reason": "...",
  "rule_id": "rule_identifier"
}
```

#### SwiftLint rule_id → SonarQube key (direct matches)

When a SwiftLint `rule_id` matches one of these, use the mapped SonarQube
type — do not fall back to the category table:

| SwiftLint rule_id            | SonarQube Key   | Type       | Rating           |
|------------------------------|-----------------|------------|------------------|
| `cyclomatic_complexity`      | `swift:S3776`   | CODE_SMELL | Maintainability  |
| `function_parameter_count`   | `swift:S107`    | CODE_SMELL | Maintainability  |
| `empty_body`                 | `swift:S1186`   | CODE_SMELL | Maintainability  |
| `empty_catch_body`           | `swift:S108`    | CODE_SMELL | Maintainability  |
| `empty_else`                 | `swift:S108`    | CODE_SMELL | Maintainability  |
| `identifier_name`            | `swift:S117`    | CODE_SMELL | Maintainability  |
| `type_name`                  | `swift:S101`    | CODE_SMELL | Maintainability  |
| `todo`                       | `swift:S1134`   | CODE_SMELL | Maintainability  |
| `unused_declaration`         | `swift:S1144`   | CODE_SMELL | Maintainability  |
| `unused_import`              | `swift:S1481`   | CODE_SMELL | Maintainability  |
| `force_cast`                 | `swift:S3083`   | BUG        | Reliability      |
| `force_try`                  | `swift:S3083`   | BUG        | Reliability      |
| `force_unwrapping`           | `swift:S3083`   | BUG        | Reliability      |
| `duplicate_conditions`       | `swift:S1862`   | BUG        | Reliability      |
| `identical_operands`         | `swift:S1764`   | BUG        | Reliability      |
| `unreachable_code`           | `swift:S1763`   | CODE_SMELL | Maintainability  |
| `no_fallthrough_only`        | `swift:S3923`   | BUG        | Reliability      |
| `redundant_nil_coalescing`   | `swift:S3981`   | BUG        | Reliability      |
| `hardcoded_credential`       | `swift:S2068`   | SECURITY_HOTSPOT | Security   |
| `no_hardcoded_ip`            | `swift:S1313`   | SECURITY_HOTSPOT | Security   |

#### SwiftLint category fallback (no direct SonarQube key match)

Map SwiftLint rule category to SonarQube type when no direct key match:

| SwiftLint Category  | SwiftLint Severity | SonarQube Type | Rating           |
|---------------------|-------------------|----------------|------------------|
| `lint`              | error             | BUG            | Reliability      |
| `lint`              | warning           | CODE_SMELL     | Maintainability  |
| `style`             | any               | CODE_SMELL     | Maintainability  |
| `metrics`           | any               | CODE_SMELL     | Maintainability  |
| `idiomatic`         | any               | CODE_SMELL     | Maintainability  |
| `performance`       | any               | CODE_SMELL     | Maintainability  |

To determine a rule's category at runtime, use:
```bash
swiftlint rules --output json 2>/dev/null | jq '.[] | select(.identifier == "<rule_id>") | .categories'
```

Or fall back to `warning` severity → CODE_SMELL, `error` severity → BUG.

---

## Execution Workflow

### Step 1 — Identify New Code

```bash
git diff develop...HEAD --name-only --diff-filter=ACM
```

Filter results — keep only `.swift` files.

Exclude generated and build artefacts:
- Any path containing `/Pods/`
- Any path containing `/.build/`
- Any path containing `/build/`
- `Talenta/NeedleGenerated.swift`
- Any path containing `/BrickWrap/`
- `**/R.generated.swift`
- `*AppDelegate.swift` (unless it contains domain logic)

These are your **new files** for all subsequent steps.

If no new `.swift` files found, report "No new source files detected" and stop.

---

### Step 2 — Fetch SonarQube Swift Rules

Use WebFetch to retrieve all 78 Swift Sonar Way rules (fits in 1 page):

```
https://next.sonarqube.com/sonarqube/api/rules/search?qprofile=AWWt7SJ4QwUgk31erFvb&activation=true&ps=100&p=1
```

Parse the `rules` array. Build a map: `key → { type, softwareQuality }`
where `softwareQuality` comes from `impacts[0].softwareQuality`.

Example entry:
```json
{
  "key": "swift:S3776",
  "type": "CODE_SMELL",
  "impacts": [{ "softwareQuality": "MAINTAINABILITY", "severity": "HIGH" }]
}
```

> If WebFetch fails, use the embedded mapping table in Step 2's
> "SwiftLint rule_id → SonarQube key" section above.

---

### Step 3 — Run SwiftLint

```bash
swiftlint lint --reporter json 2>/dev/null
```

Parse the JSON array. For every finding:
1. Extract `rule_id`, `file`, `line`, `character`, `severity`, `reason`
2. Check if `file` is in the new files list (absolute path matching)
3. If yes → classify via direct key map, then category fallback
4. Record: `{ file, line, column, ruleId, sonarKey, message, type, softwareQuality }`

Skip findings with `severity` = `"info"` — these are informational only.

---

### Step 4 — Coverage Computation

#### 4a. Run tests with coverage enabled

```bash
xcodebuild test \
  -project Talenta.xcodeproj \
  -scheme Talenta \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,arch=x86_64' \
  -enableCodeCoverage YES \
  -resultBundlePath /tmp/talenta-sonar-coverage.xcresult \
  CODE_SIGNING_ALLOWED=NO 2>&1 | grep -E "(error:|warning:|TEST SUCCEEDED|TEST FAILED)"
```

#### 4b. Extract coverage JSON

```bash
xcrun xccov view --report --json /tmp/talenta-sonar-coverage.xcresult > /tmp/talenta-coverage.json
```

The JSON structure:
```json
{
  "targets": [
    {
      "name": "Talenta",
      "files": [
        {
          "name": "FileName.swift",
          "path": "/abs/path/to/FileName.swift",
          "lineCoverage": 0.75,
          "coveredLines": 30,
          "executableLines": 40
        }
      ]
    }
  ]
}
```

#### 4c. Map new files to coverage data

For each new `.swift` file, find its entry in the coverage JSON by matching
the absolute file path against the `path` field in each target's `files`.

Extract:
- `coveredLines` = covered line count
- `executableLines` = total measurable line count

#### 4d. Files with no coverage data

If a new file has **no corresponding entry** in the coverage JSON:
- Mark as **0% coverage**
- Use physical executable line count (non-blank, non-comment lines) as total

#### 4e. Compute overall coverage

```
total_covered = sum(coveredLines for all new files)
total_lines   = sum(executableLines for all new files)

coverage_pct  = (total_covered / total_lines) * 100
```

---

### Step 5 — Duplicate Detection

Within the **new `.swift` files only**:

1. For each file, read all lines. Strip blank lines and comment-only lines
   (`//`, `/*`, `*`). Keep trimmed text with original line numbers.
2. Build a list of all 10-line sliding windows across all new files.
3. Compare windows using exact string match (trimmed).
4. A window is a **duplicate** if the same 10-line sequence appears in
   more than one location (different file OR different starting line).
5. Collect all line ranges involved in duplicate blocks, deduplicate
   overlapping ranges.

```
duplicate_lines = unique lines participating in any duplicate block
total_lines     = total non-blank, non-comment lines across all new files

dup_pct = (duplicate_lines / total_lines) * 100
```

---

### Step 6 — Evaluate Quality Gate

| Condition                      | PASS if                           |
|--------------------------------|-----------------------------------|
| Coverage ≥ 80%                 | `coverage_pct >= 80.0`            |
| Duplicated Lines ≤ 3%          | `dup_pct <= 3.0`                  |
| Maintainability Rating = A     | zero CODE_SMELLs found            |
| Reliability Rating = A         | zero BUGs found                   |
| Security Rating = A            | zero VULNERABILITYs found         |

---

### Step 7 — Report All Issues

Print the full report before asking for confirmation. Format:

```
═══════════════════════════════════════════════════════════════
  SONAR CHECK REPORT
  Branch: <current_branch> vs develop
  Project: co.mekari:talenta-ios
═══════════════════════════════════════════════════════════════

Quality Gate: ✅ PASSED  /  ❌ FAILED

─── Coverage: XX.X% (threshold: ≥ 80%) ── ✅/❌ ───

  Files with 0% coverage (no xcresult data found):
    • Talenta/Module/Foo/ViewModel/FooViewModel.swift (N lines)

  Files with partial coverage:
    • Talenta/Module/Bar/ViewModel/BarViewModel.swift
        covered: X / Y lines (ZZ%)
        uncovered lines: 12, 15, 23–27

─── Duplicated Lines: X.X% (threshold: ≤ 3%) ── ✅/❌ ───

  Duplicate block #1 (10 lines):
    • Talenta/Module/Foo/ViewModel/FooViewModel.swift  lines 10–19
    • Talenta/Module/Bar/ViewModel/BarViewModel.swift  lines 55–64

─── Reliability Rating: X (threshold: A) ── ✅/❌ ───

  BUGs found (N):
    • Talenta/Module/Foo/ViewModel/FooViewModel.swift:42 [swift:S3083 / force_cast]
      Forced cast of 'AnyObject' to 'UIView' can fail

─── Maintainability Rating: X (threshold: A) ── ✅/❌ ───

  CODE_SMELLs found (N):
    • Talenta/Module/Foo/ViewModel/FooViewModel.swift:15 [swift:S3776 / cyclomatic_complexity]
      Cyclomatic Complexity of function is 12; threshold is 10

─── Security Rating: X (threshold: A) ── ✅/❌ ───

  VULNERABILITYs found (N):
    • Talenta/Shared/Network/Config.swift:5 [swift:S4423 / weak_tls]
      Weak SSL/TLS protocol should not be used

──────────────────────────────────────────────────────────────
  Summary: N total issues across X conditions
═══════════════════════════════════════════════════════════════
```

---

### Step 8 — Ask for Confirmation

After the report, ask:

```
Found N issue(s) causing quality gate failure(s).
Proceed to fix all issues? (yes / no)
```

**Wait for user response before doing anything else.**
If the user says no, stop here.

---

### Step 9 — Fix All Issues

Fix all issues at once in this order:

#### 9a. BUGs (Reliability)

For each BUG:
- Read the file and surrounding context (10 lines before/after)
- Fix root cause:
  - `force_cast` / `swift:S3083` → use conditional cast `as?` with guard/if-let
  - `force_try` / `swift:S3083` → use `try?` or `do-catch`
  - `force_unwrapping` → use `.orEmpty()`, `.orZero()`, `.orFalse()` per project
    conventions, or guard-let unwrapping
  - `identical_operands` / `swift:S1764` → fix the duplicated expression
  - `duplicate_conditions` / `swift:S1862` → merge or reorder branches
  - `no_fallthrough_only` / `swift:S3923` → deduplicate switch branches
- Follow project conventions: RxSwift disposable lifecycle, always `weak self`
  in closures, ViewModels → UseCases → Repositories call chain

#### 9b. VULNERABILITYs (Security)

For each VULNERABILITY:
- `swift:S4423` / `swift:S4830` — do not downgrade TLS; remove insecure
  `NSAllowsArbitraryLoads` entries; never bypass SSL validation
- `swift:S5547` / `swift:S5542` / `swift:S4426` — use AES-256-GCM; replace
  ECB mode; ensure key length ≥ 2048 (RSA) or 256 (AES)
- `swift:S3329` / `swift:S2053` — use random IV/salt via
  `SecRandomCopyBytes`; never use static or hardcoded values
- `swift:S5773` — use `NSSecureCoding` instead of `NSCoding` for
  deserialization

#### 9c. CODE_SMELLs (Maintainability)

For each CODE_SMELL:
- `cyclomatic_complexity` / `swift:S3776` — extract private methods to reduce
  complexity below threshold (10)
- `function_parameter_count` / `swift:S107` — introduce a Params struct or
  builder pattern; follow the project's `UseCase.Params` nested struct pattern
- `empty_body` / `empty_catch_body` / `swift:S1186`, `swift:S108` — add a
  meaningful comment (`// intentionally empty`) or handle the case; never
  leave silent `catch {}`
- `identifier_name` / `swift:S117` — rename to camelCase; minimum 2 chars
- `type_name` / `swift:S101` — rename type to UpperCamelCase; max 64 chars
  (project rule)
- `todo` / `swift:S1134` — resolve the TODO or remove it; do not leave
  `// TODO:` in new code
- `unused_declaration` / `swift:S1144` — remove unused private symbols
- `unused_import` / `swift:S1481` — delete the import line
- `unreachable_code` / `swift:S1763` — remove the unreachable statement
- `force_cast` at CODE_SMELL severity — use conditional cast `as?`
- General style issues — follow 4-space indentation (per `.swiftlint.yml`)

Place extracted helpers in the nearest `Shared/` or feature module's own
`Utils/` following existing project conventions.

#### 9d. Duplicate Blocks

For each detected duplicate block:
- Extract the duplicated logic into a private method, extension, or
  `Shared/` utility
- Update all call sites

#### 9e. Coverage — files with 0% or partial coverage

For each new file with coverage < 80%:
- Determine the file type: ViewModel / UseCase / Repository / Mapper / Coordinator
- Locate or create the test file:
  ```
  Talenta/Module/<Feature>/Presentation/ViewModel/<Name>ViewModel.swift
    → TalentaTests/Module/<Feature>/Presentation/ViewModel/<Name>ViewModelTests.swift

  Talenta/Shared/<Feature>/Domain/UseCase/<Name>UseCase.swift
    → TalentaTests/Module/<Feature>/Domain/<Name>UseCaseTests.swift
  ```
- Follow project test conventions:
  - **ViewModel** → XCTest + RxSwift `TestScheduler` / `TestObserver`
  - **UseCase** → XCTest with mocked Repository (`[Repo]Mock` pattern)
  - **Repository** → XCTest with mocked DataSource + Mapper
  - **Mapper** → data transformation assertions
  - Mocks: placed in `TalentaTests/Mock/Module/<Module>/`, named
    `[OriginalClassName]Mock`, with `calledCount` and `reset()`

- Run tests to verify coverage improved:
  ```bash
  xcodebuild test \
    -project Talenta.xcodeproj \
    -scheme Talenta \
    -configuration Debug \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro,arch=x86_64' \
    -enableCodeCoverage YES \
    -resultBundlePath /tmp/talenta-sonar-coverage.xcresult \
    CODE_SIGNING_ALLOWED=NO 2>&1 | grep -E "(error:|TEST SUCCEEDED|TEST FAILED)"
  ```

---

### Step 10 — Verify Quality Gate

After all fixes, re-run Steps 3–5 automatically:

```bash
swiftlint lint --reporter json 2>/dev/null
xcodebuild test -project Talenta.xcodeproj -scheme Talenta -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,arch=x86_64' \
  -enableCodeCoverage YES -resultBundlePath /tmp/talenta-sonar-coverage.xcresult \
  CODE_SIGNING_ALLOWED=NO 2>&1 | grep -E "(error:|TEST SUCCEEDED|TEST FAILED)"
xcrun xccov view --report --json /tmp/talenta-sonar-coverage.xcresult > /tmp/talenta-coverage.json
```

Re-parse and re-evaluate all conditions.

Print final summary:

```
═══════════════════════════════════════════════════════════════
  SONAR CHECK — FINAL VERIFICATION
═══════════════════════════════════════════════════════════════

  Coverage:               XX.X%   ✅/❌
  Duplicated Lines:        X.X%   ✅/❌
  Reliability Rating:         A   ✅/❌
  Maintainability Rating:     A   ✅/❌
  Security Rating:            A   ✅/❌

  Quality Gate: ✅ PASSED  /  ❌ STILL FAILING

  Remaining issues (if any): <list>
═══════════════════════════════════════════════════════════════
```

If still failing, list remaining issues and ask whether to attempt
another fix round.

---

## Important Constraints

- **Excluded from analysis**: `Pods/`, `.build/`, `build/`, `BrickWrap/`,
  `NeedleGenerated.swift`, `*.generated.swift`
- **Excluded from coverage**: UI-layer files that are impractical to unit-test:
  - `*ViewController*`, `*View.swift`, `*Cell.swift`, `*XIB.swift`
  - `*Coordinator*`, `*Router*`
  - `AppDelegate.swift`, `SceneDelegate.swift`
  - `*Module*.swift` (DI wiring files), `*DIContainer*`
  - `*Response*`, `*Model*.swift` (pure data structs)
- **Line length**: max 120 characters (per project `.swiftlint.yml`)
- **Indentation**: 4 spaces
- **Optional unwrapping**: always use `.orEmpty()`, `.orZero()`, `.orFalse()` —
  never `?? ""`, `?? 0`, or force unwrap `!`
- **Closures**: always `[weak self]` capture list
- **No business logic** in ViewControllers — keep in ViewModel
- **Call chain**: ViewModel → UseCase → Repository — never skip layers
- **SwiftLint suppressions**: do not add `// swiftlint:disable` without strong
  justification — resolve the root cause instead
- **Security Hotspots** (`swift:S2068`, `swift:S6418`, `swift:S4790`,
  `swift:S1523`, `swift:S1313`): flag and report to user but do not
  auto-fix — these require manual security review
