---
name: developer-pres-resolve-design
description: Resolve UI element descriptions against the KMS design-system catalog (discipline=design, artifact=design-system). Returns a Design System Bindings table (matched) and a Custom Widgets table (unmatched). Soft-fails with empty tables if KMS has no design-system artifact for the platform.
user-invocable: false
---

## Input

| Parameter | Description |
|---|---|
| `artifact_name` | Name of the Screen or Component artifact from plan.md |
| `ui_description` | UI elements to resolve — use Figma section content when available, otherwise plan.md artifact description |
| `platform` | Platform slug (e.g. `flutter`) — passed through to KMS lookups |

## Steps

### 1 — Load the design-system TOC

`kms_list(platform="{platform}", discipline="design", artifact="design-system")` — one call, returns every `(topic, pattern)` pair (e.g. `topic=atoms, pattern=mp_button`). `pattern` slugs are derived from `## Mp<Name>` headings.

If the TOC is empty — **soft fail**: return empty tables with note `no design-system artifact in KMS for {platform} — seed kms/knowledge-sources/platform/{platform}/design/design-system/`.

### 2 — Match each UI element

Parse `ui_description` into individual keyword phrases (e.g. `"primary button, avatar, list tile"` → `["primary button", "avatar", "list tile"]`).

For each keyword, in order:
1. Name-match against the TOC `pattern` slugs from Step 1 (e.g. `"primary button"` → `mp_button`, `"avatar"` → `mp_avatar*`). For each candidate, `kms_fetch(discipline="design", artifact="design-system", topic=<topic>, pattern=<pattern>, platform="{platform}")` — exact, cascade-resolved content (description, key params, variants, Figma link). Pick the best variant by description.
2. Only if no TOC pattern name matches the keyword, fall back to `kms_query(text=<keyword>, platform="{platform}", discipline="design", artifact="design-system", n_results=3)` — semantic search.
3. If neither yields a match, mark the keyword as unmatched.

Prefer `kms_fetch` (Step 2.1) — it's deterministic and avoids repeated semantic-similarity calls against the full ~228-widget catalog for every keyword.

### 3 — Source fallback (on-demand)

If a matched entry's key params are insufficient for the creation skill (e.g., a variant is referenced but its constructor is unclear), resolve the source path:
- `Grep` for `mekari_pixel:` in `pubspec.lock` to find the pub-cache hash
- Construct path: `~/.pub-cache/git/mekari-pixel-<hash>/mekari-pixel/lib/src/<widget_file>.dart`
- `Grep` for the class name → `Read(offset=<line>, limit=60)` to capture the full constructor

Include source path in the binding row only when used.

### 4 — Output

Return exactly:

```
## Design System Bindings

| UI element | Symbol | Variants | Import |
|---|---|---|---|
| <keyword> | `Mp<Name>` | <variant list or —> | `package:mekari_pixel/mekari_pixel.dart` |

## Custom Widgets

| UI element | Reason | Action |
|---|---|---|
| <keyword> | no catalog match | create custom widget |
```

Omit a table entirely if it has no rows. If both tables are empty, add a single note:
`no UI elements resolved — check ui_description input`
