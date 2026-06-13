---
name: developer-pres-resolve-design
description: Resolve UI element descriptions against the KMS design-system catalogs (discipline=design, area=design-system). Returns a Design System Bindings table (matched) and a Custom Widgets table (unmatched). Soft-fails with empty tables if KMS has no design-system area for the platform.
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

`kms_list(platform="{platform}", discipline="design", area="design-system")` — one call, returns every `(artifact, topic, pattern)` row across all design systems for the platform (e.g. `artifact=mekari-pixel, topic=atoms, pattern=mp_button`). `pattern` slugs are derived from `## Mp<Name>` headings.

If the TOC is empty — **soft fail**: return empty tables with note `no design-system area in KMS for {platform} — seed kms/knowledge-sources/platform/{platform}/design/design-system/`.

Otherwise, for each distinct `artifact` (library name) found in the TOC, fetch its package metadata once:

`kms_fetch(discipline="design", area="design-system", artifact=<library>, topic="metadata", subtopic="package_info", pattern="package_info", platform="{platform}")` — returns that library's Import path and component-name Prefix (e.g. for `mekari-pixel`: Import=`package:mekari_pixel/mekari_pixel.dart`, Prefix=`Mp`).

Cache these per-library (Import, Prefix) for use in Step 4's output table.

### 2 — Match each UI element

Parse `ui_description` into individual keyword phrases (e.g. `"primary button, avatar, list tile"` → `["primary button", "avatar", "list tile"]`).

For each keyword, in order:
1. Name-match against the TOC `pattern` slugs from Step 1 (e.g. `"primary button"` → `mp_button`, `"avatar"` → `mp_avatar*`). For each candidate, `kms_fetch(discipline="design", area="design-system", artifact=<matched library>, topic=<topic>, pattern=<pattern>, platform="{platform}")` — exact, cascade-resolved content (description, key params, variants, Figma link). Pick the best variant by description.
2. Only if no TOC pattern name matches the keyword, fall back to `kms_query(text=<keyword>, platform="{platform}", discipline="design", area="design-system", n_results=3)` — semantic search. Use the matched result's `artifact` field as the library for this element.
3. If neither yields a match, mark the keyword as unmatched.

Prefer `kms_fetch` (Step 2.1) — it's deterministic and avoids repeated semantic-similarity calls against the full ~228-widget catalog for every keyword.

### 3 — Source fallback (on-demand)

If a matched entry's key params are insufficient for the creation skill (e.g., a variant is referenced but its constructor is unclear), resolve the source path:
- `Grep` for `mekari_pixel:` in `pubspec.lock` to find the pub-cache hash
- Construct path: `~/.pub-cache/git/mekari-pixel-<hash>/mekari-pixel/lib/src/<widget_file>.dart`
- `Grep` for the class name → `Read(offset=<line>, limit=60)` to capture the full constructor

Include source path in the binding row only when used.

### 4 — Output

For each matched row, use the Prefix and Import cached in Step 1 for that element's matched library — rows matched against different libraries use their own library's Prefix/Import.

Return exactly:

```
## Design System Bindings

| UI element | Symbol | Variants | Import |
|---|---|---|---|
| <keyword> | `<Prefix><Name>` | <variant list or —> | `<Import>` |

## Custom Widgets

| UI element | Reason | Action |
|---|---|---|
| <keyword> | no catalog match | create custom widget |
```

Omit a table entirely if it has no rows. If both tables are empty, add a single note:
`no UI elements resolved — check ui_description input`
