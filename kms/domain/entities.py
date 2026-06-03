from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class KnowledgeNode:
    platform: Optional[str]    # flutter | web | ios | android | None (universal)
    project: Optional[str]     # talenta | jurnal | None (platform-base)
    discipline: str            # engineering | design | qa | devops | security | ...
    topic: str
    pattern: str
    summary: str = ""          # first sentence of ## Theory, populated at seed time
    tags: list[str] = field(default_factory=list)
    source_file: Optional[str] = None
    updated_at: Optional[str] = None
    content: Optional[str] = None  # None in list results, populated in fetch/query results

    @property
    def id(self) -> str:
        p = self.platform or "null"
        pr = self.project or "null"
        return f"{p}:{pr}:{self.discipline}:{self.topic}:{self.pattern}"

    @property
    def specificity(self) -> int:
        """Higher = more specific. Used to pick the override in cascade resolution."""
        return (1 if self.project else 0) + (1 if self.platform else 0)
