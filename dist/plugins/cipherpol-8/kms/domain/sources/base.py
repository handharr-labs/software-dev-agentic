from __future__ import annotations
from abc import ABC, abstractmethod
from typing import Iterator

from ..entities import KnowledgeNode


class KnowledgeSource(ABC):

    @property
    @abstractmethod
    def name(self) -> str:
        """Registered name in sources.yaml."""

    @property
    @abstractmethod
    def source_type(self) -> str:
        """Source type — markdown | codebase | confluence."""

    @property
    @abstractmethod
    def owns(self) -> list[str]:
        """Section keys this source is allowed to write."""

    @abstractmethod
    def is_available(self) -> bool:
        """Return False if path/url is unreachable — caller skips without aborting."""

    @abstractmethod
    def read(self) -> Iterator[KnowledgeNode]:
        """Yield KnowledgeNodes. content_hash must be populated by the adapter."""
