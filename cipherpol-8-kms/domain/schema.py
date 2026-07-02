from __future__ import annotations

SCOPE_VALUES = ["universal", "platform", "project"]

PLATFORM_VALUES = ["flutter", "ios", "android", "web"]

PROJECT_VALUES = ["talenta", "jurnal", "qontak-crm", "qontak-chat"]

DISCIPLINE_VALUES = [
    "engineering",
    "design",
    "qa",
    "devops",
    "security",
    "code_review",
    "product",
    "architecture",
    "agile",
]

AREA_VALUES = ["core", "design-system"]

# CLEAN-layer facet — enables per-agent retrieval scoping (domain-planner never
# gets data-layer nodes). "cross" = cross-cutting; always unioned into agent scopes.
LAYER_VALUES = ["domain", "data", "presentation", "cross"]

# Lifecycle guard — "extracted" files are regenerated wholesale by scanners;
# "curated" are hand-owned and never auto-overwritten.
OWNER_VALUES = ["curated", "extracted"]

# layer back-fill (migration step 2a): when a node has no explicit frontmatter
# `layer`, derive it from the enclosing `#` topic heading. Architecture docs already
# use `# Domain` / `# Data` / `# Presentation` / `# UI` as CLEAN-layer markers.
TOPIC_LAYER_MARKERS = {
    "domain": "domain",
    "data": "data",
    "presentation": "presentation",
    "ui": "presentation",
}

# Floor for anything not otherwise classified. "cross" is always unioned into an
# agent's scope, so an unmarked node is never invisible to scoped retrieval.
DEFAULT_LAYER = "cross"

MANDATORY_FIELDS = ["scope", "discipline", "area", "artifact", "topic", "subtopic", "pattern", "schema_version"]

OPTIONAL_FIELDS = ["platform", "project", "layer", "owner", "tags", "source_file", "updated_at", "content_hash"]

SCHEMA_VERSION = "3"

# Default section ownership per source type — enforced by UpsertKnowledge use case.
SOURCE_TYPE_OWNS: dict[str, list[str]] = {
    "markdown":   ["theory", "definition"],
    "codebase":   ["code_pattern", "source_file"],
    "confluence": ["theory", "rationale"],
}

# Files matching any of these patterns are never seeded regardless of source type.
# Applied by all KnowledgeSource adapters before yielding nodes.
SEED_EXCLUDE_PATTERNS: list[str] = [
    ".env",
    ".env.*",
    "*.pem",
    "*.key",
    "*.p12",
    "*.pfx",
    "*.keystore",
    "credentials.json",
    "secrets.yaml",
    "secrets.yml",
    "*secret*",
    "*credential*",
    "*password*",
    "*.token",
]
