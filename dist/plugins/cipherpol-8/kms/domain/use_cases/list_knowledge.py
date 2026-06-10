from __future__ import annotations
from typing import Optional
from ..entities import KnowledgeNode
from ..repository import KnowledgeRepository


class ListKnowledge:
    """
    Returns a merged, deduplicated TOC for a given scope.
    When project + platform + universal nodes exist for the same (discipline, topic, pattern),
    only the most specific one is returned — mirrors cascade resolution in FetchKnowledge.
    """

    def __init__(self, repo: KnowledgeRepository) -> None:
        self._repo = repo

    def execute(
        self,
        platform: Optional[str] = None,
        project: Optional[str] = None,
        discipline: Optional[str] = None,
        topic: Optional[str] = None,
    ) -> list[KnowledgeNode]:
        from ..repository import NULL_SENTINEL

        # No scope filters — return everything (e.g. kms-status overview).
        if platform is None and project is None and discipline is None and topic is None:
            nodes = self._repo.list()
            return sorted(nodes, key=lambda n: (n.discipline, n.topic, n.pattern))

        # Collect nodes at every applicable tier so callers get a complete picture.
        tiers: list[list[KnowledgeNode]] = []

        # Universal tier: nodes where platform stored as "null".
        tiers.append(self._repo.list(platform=NULL_SENTINEL, project=NULL_SENTINEL, discipline=discipline, topic=topic))

        if platform:
            # Platform-base (project=None → stored as "null").
            tiers.append(self._repo.list(platform=platform, project=NULL_SENTINEL, discipline=discipline, topic=topic))

        if project:
            # Project-specific overrides — platform already stored in the node from repo.yaml.
            # Pass platform if known for a stricter match; None means no platform filter.
            tiers.append(self._repo.list(platform=platform, project=project, discipline=discipline, topic=topic))

        # Merge: later tiers (more specific) win on (discipline, topic, pattern) key.
        seen: dict[tuple[str, str, str], KnowledgeNode] = {}
        for tier in tiers:
            for node in tier:
                key = (node.discipline, node.topic, node.pattern)
                if key not in seen or node.specificity > seen[key].specificity:
                    seen[key] = node

        return sorted(seen.values(), key=lambda n: (n.discipline, n.topic, n.pattern))
