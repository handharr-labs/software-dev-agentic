---
name: aegis-kms-lookup
description: Look up KMS nodes from free-text names. One kms_list scan builds the slug map; exact match is tried first per name; kms_query handles ambiguous or non-canonical names. Returns resolved content + unresolved flags. Call once per batch.
user-invocable: false
allowed-tools: mcp__cp8__kms_list, mcp__cp8__kms_fetch, mcp__cp8__kms_query
---

## Input

| Parameter | Required | Description |
|---|---|---|
| `names` | Yes | Comma-separated names to resolve — as they appear in the source (e.g. Figma component names, feature names) |
| `platform` | Yes | `flutter` \| `ios` \| `web` |
| `discipline` | Yes | KMS discipline to search — e.g. `design`, `engineering` |
| `area` | No | KMS area to narrow the search — e.g. `design-system`, `core`. Omit to search all areas. |

## Steps

### 1 — Scan vocabulary

```
kms_list(discipline="{discipline}", platform="{platform}"[, area="{area}"])
```

Hold the full row list as `<toc>`. Build a **slug map** — for each row, derive a normalized key:
- lowercase the `pattern` value
- strip a leading library prefix if present (`mp`, `mds`, `px`, etc.)
- strip common suffixes: `widget`, `view`, `component`

Map: `normalized_key → row` (artifact, topic, subtopic, pattern).

### 2 — Resolve each name

For each name in `{names}`:

**Normalize:** lowercase, strip spaces and punctuation, strip known suffixes (`widget`, `view`, `component`) only if the remainder still matches a slug.

**Exact match:** look up normalized name in the slug map.
- **Hit** → `kms_fetch(discipline="{discipline}", area="{area}", artifact={row.artifact}, topic={row.topic}, subtopic={row.subtopic}, pattern={row.pattern}, platform="{platform}")` → record as `resolved`.

**No hit** → semantic fallback:
```
kms_query(text="{name}", platform="{platform}", discipline="{discipline}"[, area="{area}"], n_results=3)
```
Take the top result **only if** the returned `pattern` or `content` plausibly matches the input name. If plausible → record as `resolved (via query)`. If not → record as `unresolved`.

### 3 — Collect results

For each resolved name, include fetched `content` inline — caller does not need a second fetch.

## Output

```
## KMS Lookup Result

platform: {platform}
discipline: {discipline}
area: {area | all}
total: {N}
resolved: {N}
unresolved: {N}

### Resolved

#### {OriginalName} → {canonical_pattern}
source: exact | query
{full content of the fetched node}

---

### Unresolved

- {OriginalName} — {reason}
```

Omit `### Unresolved` section entirely if all names resolved.
