from __future__ import annotations
from typing import Iterator
from urllib.request import urlopen
from urllib.error import URLError

from ..entities import KnowledgeNode
from .base import KnowledgeSource


class ConfluenceSource(KnowledgeSource):
    """Stub — Confluence page reader. Full implementation pending auth + parser."""

    def __init__(self, name: str, url: str, owns: list[str]) -> None:
        self._name = name
        self._url = url
        self._owns = owns

    @property
    def name(self) -> str:
        return self._name

    @property
    def source_type(self) -> str:
        return "confluence"

    @property
    def owns(self) -> list[str]:
        return self._owns

    def is_available(self) -> bool:
        try:
            urlopen(self._url, timeout=5)
            return True
        except (URLError, Exception):
            return False

    def read(self) -> Iterator[KnowledgeNode]:
        # Full Confluence reader pending API auth + HTML-to-markdown parser.
        return iter([])
