from __future__ import annotations
import uuid
from dataclasses import dataclass, field
from typing import Optional

# Fixed namespace so uuid5 ids are stable across runs/machines.
_ID_NAMESPACE = uuid.UUID("6b6f6d73-0000-4000-8000-000000000001")


@dataclass
class KnowledgeNode:
    scope: str                 # universal | platform | project — see schema.SCOPE_VALUES
    discipline: str            # see schema.DISCIPLINE_VALUES
    topic: str
    pattern: str
    subtopic: str = ""               # ## heading slug — equals pattern when no ### children exist
    artifact: Optional[str] = None           # conventions | standard-architecture | feature-inventory | ...
    platform: Optional[str] = None          # flutter | web | ios | android — required if scope != universal
    project: Optional[str] = None           # talenta | jurnal | ... — required if scope == project
    layer: Optional[str] = None             # domain | data | presentation | cross — see schema.LAYER_VALUES
    owner: str = "curated"                  # curated | extracted — see schema.OWNER_VALUES
    summary: str = ""                # first sentence of ## Theory, populated at seed time
    tags: list[str] = field(default_factory=list)
    source_file: Optional[str] = None
    updated_at: Optional[str] = None
    content_hash: Optional[str] = None  # SHA256 of content body — used for incremental seed detection
    content: Optional[str] = None       # None in list results, populated in fetch/query results
    content_type: str = "real"          # "real" | "stub" — stubs seed schema; never overwrite real

    @property
    def id(self) -> str:
        """Opaque, deterministic uuid5. Keyed on content location (source_file#section)
        so reclassifying facets (layer/platform/…) is an UPDATE, not delete+insert.
        Falls back to the identity tuple for nodes with no source_file (manual upserts)."""
        section = self.subtopic or self.pattern
        if self.source_file:
            # topic keeps same-named ## sections under different # topics distinct
            # (e.g. "Creation Order" under # Domain vs # Data in an architecture doc).
            key = f"{self.source_file}#{self.topic}#{section}"
        else:
            p = self.platform or "null"
            pr = self.project or "null"
            a = self.artifact or "null"
            key = f"{p}:{pr}:{self.discipline}:{a}:{self.topic}:{section}"
        return str(uuid.uuid5(_ID_NAMESPACE, key))

    @property
    def specificity(self) -> int:
        """Higher = more specific. Used to pick the override in cascade resolution."""
        return (1 if self.project else 0) + (1 if self.platform else 0)
