from __future__ import annotations
import fnmatch
import hashlib
import re
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Iterator, Optional

import yaml

from ..entities import KnowledgeNode
from ..schema import DISCIPLINE_VALUES, PLATFORM_VALUES, SEED_EXCLUDE_PATTERNS
from .base import KnowledgeSource

_SUPPORTED_SUFFIXES = {".md", ".txt"}
_FIRST_SENTENCE_RE = re.compile(r"^[^#\n].+?(?<=[.!?])\s", re.DOTALL)
_PROJECTS_DIR = "projects"
_REPO_YAML = "repo.yaml"


@dataclass
class _RepoMeta:
    name: str
    platform: Optional[str]
    remote: Optional[str]
    local_path: Optional[str]


def _repo_name_from_remote(remote: str) -> str:
    """Extract repo name from remote URL — last path segment, strip .git suffix."""
    segment = remote.rstrip("/").split("/")[-1]
    return segment[:-4] if segment.endswith(".git") else segment


def _load_repo_meta(project_dir: Path) -> _RepoMeta:
    """Read repo.yaml from a projects/{project}/ directory.
    Project name is always derived from the remote URL — never the directory name.
    Falls back to directory name only when remote is absent.
    """
    repo_file = project_dir / _REPO_YAML
    if not repo_file.exists():
        return _RepoMeta(
            name=project_dir.name,
            platform=None,
            remote=None,
            local_path=None,
        )
    with repo_file.open() as f:
        data = yaml.safe_load(f) or {}
    remote = data.get("remote") or None
    name = _repo_name_from_remote(remote) if remote else project_dir.name
    return _RepoMeta(
        name=name,
        platform=data.get("platform") or None,
        remote=remote,
        local_path=data.get("local_path") or None,
    )


def _extract_summary(content: str) -> str:
    for line in content.splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            m = _FIRST_SENTENCE_RE.match(line + " ")
            return m.group(0).strip() if m else line[:120]
    return ""


def _parse_filename(stem: str) -> tuple[str | None, str, str]:
    """Derive (platform, topic, pattern) from filename stem.

    flutter-standard-architecture → (flutter, standard_architecture, flutter_standard_architecture)
    feature-inventory             → (None, feature_inventory, feature_inventory)
    """
    snake = stem.replace("-", "_")
    for platform in PLATFORM_VALUES:
        if snake.startswith(platform + "_"):
            topic = snake[len(platform) + 1:]
            return platform, topic, snake
    return None, snake, snake


def _derive_scope(platform: str | None, project: str | None) -> str:
    if project:
        return "project"
    if platform:
        return "platform"
    return "universal"


class DirectorySource(KnowledgeSource):
    """Reads any supported file from kms/knowledge-sources/ — no frontmatter required.

    Two path conventions:

    1. Platform/universal knowledge:
       {root}/{discipline}/{filename}.md
       discipline → subdirectory name (must match DISCIPLINE_VALUES)
       platform   → filename prefix (flutter-*, ios-*, android-*, web-*)
       scope      → platform if prefix found, universal otherwise

    2. Project-specific knowledge:
       {root}/projects/{project-name}/{filename}.md
       Project metadata (platform, remote, local_path) read from repo.yaml in the project dir.
       discipline → always "engineering" (codebase scan output)
       project    → directory name
       scope      → always "project"
       platform   → from repo.yaml
    """

    def __init__(self, name: str, path: str, owns: list[str]) -> None:
        self._name = name
        self._path = Path(path)
        self._owns = owns

    @property
    def name(self) -> str:
        return self._name

    @property
    def source_type(self) -> str:
        return "directory"

    @property
    def owns(self) -> list[str]:
        return self._owns

    def is_available(self) -> bool:
        return self._path.exists()

    def read(self) -> Iterator[KnowledgeNode]:
        yield from self._read_platform_docs()
        yield from self._read_project_docs()

    # ------------------------------------------------------------------
    # Platform / universal docs: {root}/{discipline}/{file}.md
    # ------------------------------------------------------------------

    def _read_platform_docs(self) -> Iterator[KnowledgeNode]:
        for discipline_dir in sorted(self._path.iterdir()):
            if not discipline_dir.is_dir():
                continue
            if discipline_dir.name == _PROJECTS_DIR:
                continue
            if discipline_dir.name not in DISCIPLINE_VALUES:
                continue

            discipline = discipline_dir.name

            for path in sorted(discipline_dir.rglob("*")):
                if path.is_dir() or path.name in ("README.md",):
                    continue
                if path.suffix not in _SUPPORTED_SUFFIXES:
                    continue
                if any(fnmatch.fnmatch(path.name, pat) for pat in SEED_EXCLUDE_PATTERNS):
                    print(f"  skip (excluded): {path.name}")
                    continue

                platform, topic, pattern = _parse_filename(path.stem)
                content = path.read_text(encoding="utf-8").strip()

                yield KnowledgeNode(
                    scope=_derive_scope(platform, None),
                    platform=platform,
                    project=None,
                    discipline=discipline,
                    topic=topic,
                    pattern=pattern,
                    summary=_extract_summary(content),
                    source_file=str(path),
                    updated_at=date.today().isoformat(),
                    content_hash=hashlib.sha256(content.encode()).hexdigest(),
                    content=content,
                )

    # ------------------------------------------------------------------
    # Project-specific docs: {root}/projects/{project}/{file}.md
    # ------------------------------------------------------------------

    def _read_project_docs(self) -> Iterator[KnowledgeNode]:
        projects_dir = self._path / _PROJECTS_DIR
        if not projects_dir.exists():
            return

        for project_dir in sorted(projects_dir.iterdir()):
            if not project_dir.is_dir():
                continue

            repo = _load_repo_meta(project_dir)

            for path in sorted(project_dir.rglob("*")):
                if path.is_dir():
                    continue
                if path.name in ("README.md", _REPO_YAML):
                    continue
                if path.suffix not in _SUPPORTED_SUFFIXES:
                    continue
                if any(fnmatch.fnmatch(path.name, pat) for pat in SEED_EXCLUDE_PATTERNS):
                    print(f"  skip (excluded): {path.name}")
                    continue

                stem = path.stem.replace("-", "_")
                content = path.read_text(encoding="utf-8").strip()

                yield KnowledgeNode(
                    scope="project",
                    platform=repo.platform,
                    project=repo.name,
                    discipline="engineering",
                    topic=stem,
                    pattern=stem,
                    summary=_extract_summary(content),
                    source_file=str(path),
                    updated_at=date.today().isoformat(),
                    content_hash=hashlib.sha256(content.encode()).hexdigest(),
                    content=content,
                )
