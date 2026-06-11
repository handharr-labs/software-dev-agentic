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

MANDATORY_FIELDS = ["scope", "discipline", "artifact", "topic", "pattern", "schema_version"]

OPTIONAL_FIELDS = ["platform", "project", "tags", "source_file", "updated_at", "content_hash"]

SCHEMA_VERSION = "1"

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
