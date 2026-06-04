from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class KnowledgeNode:
    scope: str                 # universal | platform | project — see schema.SCOPE_VALUES
    discipline: str            # see schema.DISCIPLINE_VALUES
    topic: str
    pattern: str
    platform: Optional[str] = None   # flutter | web | ios | android — required if scope != universal
    project: Optional[str] = None    # talenta | jurnal | ... — required if scope == project
    summary: str = ""                # first sentence of ## Theory, populated at seed time
    tags: list[str] = field(default_factory=list)
    source_file: Optional[str] = None
    updated_at: Optional[str] = None
    content_hash: Optional[str] = None  # SHA256 of content body — used for incremental seed detection
    content: Optional[str] = None       # None in list results, populated in fetch/query results
    content_type: str = "real"          # "real" | "stub" — stubs seed schema; never overwrite real

    @property
    def id(self) -> str:
        p = self.platform or "null"
        pr = self.project or "null"
        return f"{p}:{pr}:{self.discipline}:{self.topic}:{self.pattern}"

    @property
    def specificity(self) -> int:
        """Higher = more specific. Used to pick the override in cascade resolution."""
        return (1 if self.project else 0) + (1 if self.platform else 0)
