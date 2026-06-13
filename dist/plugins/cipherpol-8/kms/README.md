# KMS — Knowledge Management System

ChromaDB-backed knowledge store for the CipherPol toolkit. Agents retrieve implementation patterns and SDLC knowledge via MCP tools instead of grepping flat files.

See `docs/principles/kms/kms-design-principles.md` for design rationale, `kms-conventions.md` for path conventions and retrieval protocol, and `kms-seeding.md` for seeding strategy.

---

## Directory Structure

```
kms/
  domain/
    schema.py              # Vocabulary constants — single source of truth
    entities.py            # KnowledgeNode dataclass
    repository.py          # KnowledgeRepository abstract interface
    sources/
      base.py              # KnowledgeSource abstract interface
      directory.py         # DirectorySource adapter — primary; path-based metadata, no frontmatter
      markdown.py          # MarkdownSource adapter — legacy; requires frontmatter
      codebase.py          # CodebaseSource adapter (stub)
      confluence.py        # ConfluenceSource adapter (stub)
    use_cases/
      fetch_knowledge.py   # Cascade fetch: project → platform → universal
      list_knowledge.py    # Merged TOC — metadata only
      query_knowledge.py   # Vector search with optional metadata filter
      upsert_knowledge.py  # Section-ownership-aware upsert + merge
  data/
    chroma_repository.py   # ChromaKnowledgeRepository — implements KnowledgeRepository
  application/
    mcp_server.py          # MCP tools: kms_list, kms_fetch, kms_query, kms_upsert
  dashboard/
    server.py              # Local web UI server
    index.html             # Hierarchical nav + section editor
  scripts/
    seed_kms.py            # Unified seed runner
  sources.yaml             # Source registry
  requirements.txt
```

---

## Adding Knowledge

The simplest way — drop a file into `kms/knowledge-sources/` under the right discipline directory:

Two path conventions — both derive all metadata automatically:

**1. Platform / universal knowledge:**
```
kms/knowledge-sources/{discipline}/{filename}.md

engineering/flutter-standard-architecture.md  → platform=flutter, discipline=engineering, scope=platform
agile/sprint-retrospective-guide.md           → platform=None, discipline=agile, scope=universal
security/owasp-top10.md                       → platform=None, discipline=security, scope=universal
```

| From | Derived field |
|---|---|
| Subdirectory name | `discipline` (must match `DISCIPLINE_VALUES`) |
| Filename prefix (`flutter-*`, `ios-*`, etc.) | `platform` |
| Platform present | `scope=platform`, absent → `scope=universal` |
| Filename stem (no prefix) | `topic` + `pattern` |

**2. Project-specific knowledge:**
```
kms/knowledge-sources/projects/{project-name}/{filename}.md

projects/flutter-mobile-talenta/feature-inventory.md  → project=flutter-mobile-talenta, scope=project
projects/flutter-mobile-talenta/api-endpoints.md      → project=flutter-mobile-talenta, scope=project
```

Each project directory requires a `repo.yaml`:
```yaml
name: flutter-mobile-talenta
platform: flutter
remote: https://github.com/mekari/flutter-mobile-talenta
local_path: null        # set to absolute local clone path to enable codebase scan
last_scanned: null
```

`platform` and `project` are read from `repo.yaml` — not encoded in filenames. `discipline` defaults to `engineering` for all project docs.

Then run `/kms-seed` or:
```bash
python -m kms.scripts.seed_kms --db-path dist/.kms_seeds/.shared/chroma
```

---

## Source Adapter Contract

A knowledge source is any class that implements `KnowledgeSource` from `kms/domain/sources/base.py`.

```python
class KnowledgeSource(ABC):

    @property
    @abstractmethod
    def name(self) -> str:
        """Registered name — must match the entry in sources.yaml."""

    @property
    @abstractmethod
    def source_type(self) -> str:
        """Source type string — directory | markdown | codebase | confluence."""

    @property
    @abstractmethod
    def owns(self) -> list[str]:
        """Section keys this source is allowed to write.
        UpsertKnowledge enforces this — adapters do not need to filter themselves."""

    @abstractmethod
    def is_available(self) -> bool:
        """Return False if the source cannot be reached.
        The seed runner skips unavailable sources without aborting or touching existing nodes."""

    @abstractmethod
    def read(self) -> Iterator[KnowledgeNode]:
        """Yield KnowledgeNodes ready to upsert.
        Each node must have content and content_hash populated."""
```

### Adding a new source type

1. Create `kms/domain/sources/{type}.py` implementing `KnowledgeSource`
2. Add default `owns` for the new type in `kms/domain/schema.py` → `SOURCE_TYPE_OWNS`
3. Register the adapter in `seed_kms.py` → `_build_adapter()`
4. Add entries to `kms/sources.yaml`

### Section ownership

Each source declares which markdown sections it owns via `owns`. The `UpsertKnowledge` use case enforces this at write time — it fetches the existing node, keeps non-owned sections from the existing content, and only updates owned sections from the new content.

Default ownership by type:

| Source type | Default owned sections |
|---|---|
| `directory` | `theory`, `definition`, `code_pattern`, `rationale` |
| `markdown` | `theory`, `definition` |
| `codebase` | `code_pattern`, `source_file` |
| `confluence` | `theory`, `rationale` |

Override `owns` per entry in `sources.yaml` if needed.

---

## Seeding

```bash
# Seed all available sources
python -m kms.scripts.seed_kms --db-path /path/to/chroma

# Seed one registered source
python -m kms.scripts.seed_kms --db-path /path --source flutter-base-knowledge

# Seed all sources of a type
python -m kms.scripts.seed_kms --db-path /path --type markdown

# Detect, register, and seed a new source in one step
python -m kms.scripts.seed_kms --db-path /path --add /path/to/repo
python -m kms.scripts.seed_kms --db-path /path --add https://confluence.example.com/pages/123
```

Or via the agentic skill: `/kms-seed [--source <name>] [--type <type>] [--add <path|url>]`

### Incremental detection

The seed runner computes a SHA256 hash of each node's content body and stores it as `content_hash` in ChromaDB metadata. On re-seed, nodes whose hash hasn't changed are skipped — only changed nodes are upserted.

### Source registry (`sources.yaml`)

All sources are declared here. The seed runner never hardcodes sources.

```yaml
sources:
  - name: knowledge-sources         # unique identifier
    type: directory                  # directory | markdown | codebase | confluence
    path: kms/knowledge-sources      # relative to repo root
    owns:
      - theory
      - definition
      - code_pattern
      - rationale
    last_seeded: 2026-06-04         # updated automatically after each successful seed
```

---

## Metadata Schema

All vocabulary constants are in `kms/domain/schema.py`. Never hardcode allowed values elsewhere.

| Field | Mandatory | Values |
|---|---|---|
| `scope` | ✅ | `universal`, `platform`, `project` |
| `discipline` | ✅ | see `DISCIPLINE_VALUES` in `schema.py` |
| `topic` | ✅ | free string |
| `subtopic` | ✅ | free string — equals `pattern` when no `###` children exist |
| `pattern` | ✅ | free string — neutral term across all disciplines |
| `schema_version` | ✅ | `"1"` — increment on breaking changes |
| `platform` | ⬜ | `flutter`, `ios`, `android`, `web` |
| `project` | ⬜ | `talenta`, `jurnal`, `qontak-crm`, `qontak-chat` |
| `tags` | ⬜ | JSON array string |
| `source_file` | ⬜ | absolute path |
| `updated_at` | ⬜ | ISO date string |
| `content_hash` | ⬜ | SHA256 of document body |

---

## MCP Tools

| Tool | Input | Output |
|---|---|---|
| `kms_list` | `platform?, project?, discipline?, topic?, subtopic?` | Scoped TOC — metadata only |
| `kms_fetch` | `platform, project, discipline, topic, subtopic, pattern` | Full node content (cascade applied) |
| `kms_query` | `text, where?` | Top-k nodes by semantic similarity |
| `kms_upsert` | full node + content | Written/updated node |
