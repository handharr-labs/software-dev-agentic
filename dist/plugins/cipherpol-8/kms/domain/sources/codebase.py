from __future__ import annotations
from pathlib import Path
from typing import Iterator

from ..entities import KnowledgeNode
from .base import KnowledgeSource


class CodebaseSource(KnowledgeSource):
    """Stub — reads code_pattern sections extracted by agent-kms-scan-worker.
    Full implementation in Phase 2 scan agent integration."""

    def __init__(self, name: str, path: str, owns: list[str]) -> None:
        self._name = name
        self._path = Path(path)
        self._owns = owns

    @property
    def name(self) -> str:
        return self._name

    @property
    def source_type(self) -> str:
        return "codebase"

    @property
    def owns(self) -> list[str]:
        return self._owns

    def is_available(self) -> bool:
        return self._path.exists()

    def read(self) -> Iterator[KnowledgeNode]:
        # Scan agent writes extracted nodes via kms_upsert MCP tool directly.
        # This adapter is a placeholder for future direct codebase reading.
        #
        # REQUIRED when implementing: filter all file paths against
        # schema.SEED_EXCLUDE_PATTERNS before reading — never seed .env,
        # credentials, keys, or secret files.
        return iter([])
