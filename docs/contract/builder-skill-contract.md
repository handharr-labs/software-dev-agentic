# Builder — Skill Contract

Platform-contract skills called by `developer` persona workers. Every platform must implement all **Required** skills under `lib/platforms/<platform>/skills/contract/<name>/SKILL.md`.

---

## feature-worker

| Skill | Required |
|---|---|
| `developer-domain-create-entity` | Yes |
| `developer-domain-create-repository` | Yes |
| `developer-domain-create-usecase` | Yes |
| `developer-domain-create-service` | Yes |
| `developer-data-create-mapper` | Yes |
| `developer-data-create-datasource` | Yes |
| `developer-data-create-repository-impl` | Yes |
| `developer-pres-create-stateholder` | Yes |
| `developer-pres-create-screen` | Yes |
| `developer-pres-create-component` | Optional — omit when the platform has no reusable component abstraction |

---

## test-worker

| Skill | Required |
|---|---|
| `developer-test-create-domain` | Yes |
| `developer-test-create-data` | Yes |
| `developer-test-create-presentation` | Yes |
| `developer-test-create-mock` | Yes |
