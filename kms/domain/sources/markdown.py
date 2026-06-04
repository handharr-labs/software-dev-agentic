from __future__ import annotations
import fnmatch
import hashlib
import re
from datetime import date
from pathlib import Path
from typing import Iterator

import yaml

from ..entities import KnowledgeNode
from ..schema import SEED_EXCLUDE_PATTERNS
from .base import KnowledgeSource

_FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
_THEORY_RE = re.compile(r"##\s+Theory\s*\n+(.*?)(?=\n##|\Z)", re.DOTALL)


def _extract_summary(content: str) -> str:
    m = _THEORY_RE.search(content)
    if not m:
        return ""
    return re.split(r"(?<=[.!?])\s", m.group(1).strip(), maxsplit=1)[0].strip()


def _derive_scope(platform: str | None, project: str | None) -> str:
    if project:
        return "project"
    if platform:
        return "platform"
    return "universal"


class MarkdownSource(KnowledgeSource):

    def __init__(self, name: str, path: str, owns: list[str]) -> None:
        self._name = name
        self._path = Path(path)
        self._owns = owns

    @property
    def name(self) -> str:
        return self._name

    @property
    def source_type(self) -> str:
        return "markdown"

    @property
    def owns(self) -> list[str]:
        return self._owns

    def is_available(self) -> bool:
        return self._path.exists()

    def read(self) -> Iterator[KnowledgeNode]:
        for path in sorted(self._path.rglob("*.md")):
            if path.name == "index.md":
                continue
            if any(fnmatch.fnmatch(path.name, pat) for pat in SEED_EXCLUDE_PATTERNS):
                print(f"  skip (excluded): {path}")
                continue

            raw = path.read_text(encoding="utf-8")
            fm_match = _FRONTMATTER_RE.match(raw)
            if not fm_match:
                continue

            try:
                meta = yaml.safe_load(fm_match.group(1))
            except yaml.YAMLError:
                continue

            if not all(meta.get(k) for k in ("discipline", "topic", "pattern")):
                continue

            content = raw[fm_match.end():].strip()
            platform = meta.get("platform") or None
            project = meta.get("project") or None

            yield KnowledgeNode(
                scope=_derive_scope(platform, project),
                platform=platform,
                project=project,
                discipline=meta["discipline"],
                topic=meta["topic"],
                pattern=meta["pattern"],
                summary=_extract_summary(content),
                tags=meta.get("tags") or [],
                source_file=str(path),
                updated_at=date.today().isoformat(),
                content_hash=hashlib.sha256(content.encode()).hexdigest(),
                content=content,
            )
