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
_UNIVERSAL_DIR = "universal"
_PLATFORM_DIR = "platform"
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
    name = data.get("name") or (_repo_name_from_remote(remote) if remote else project_dir.name)
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


def _parse_filename(stem: str) -> tuple[str, str]:
    """Derive (topic, pattern) from filename stem. Platform is directory-derived, not filename-derived.

    standard-architecture → (standard_architecture, standard_architecture)
    feature-inventory     → (feature_inventory, feature_inventory)
    """
    snake = stem.replace("-", "_")
    return snake, snake


def _heading_to_slug(heading: str) -> str:
    """Convert a markdown heading to a snake_case slug for use as topic/pattern."""
    slug = re.sub(r"[^\w\s]", "", heading.lower())
    return re.sub(r"\s+", "_", slug.strip())


def _strip_frontmatter(content: str) -> str:
    """Remove YAML frontmatter block (--- ... ---) if present."""
    if not content.startswith("---"):
        return content
    end = content.find("\n---\n", 3)
    if end == -1:
        return content
    return content[end + 5:].strip()


def _chunk_by_sections(content: str) -> list[tuple[str, str, str]]:
    """Split content by ## headings. Returns [(topic_slug, pattern_slug, section_content), ...].

    # heading  → updates topic context; not a chunk boundary
    ## heading → chunk boundary; pattern derived from this heading
    ### +      → content within the ## chunk; not split further

    Returns [] when no ## headings found — caller yields file as a single node.
    topic_slug is "" when no # heading precedes the ## — caller uses artifact name as fallback.
    Lines before the first ## (preamble) are discarded.
    """
    lines = content.splitlines()
    sections: list[tuple[str, str, str]] = []
    current_topic: str = ""
    current_pattern: str | None = None
    current_lines: list[str] = []

    for line in lines:
        if line.startswith("# ") and not line.startswith("## "):
            if current_pattern is not None:
                sections.append((current_topic, current_pattern, "\n".join(current_lines).strip()))
                current_pattern = None
                current_lines = []
            current_topic = _heading_to_slug(line[2:].strip())
        elif line.startswith("## "):
            if current_pattern is not None:
                sections.append((current_topic, current_pattern, "\n".join(current_lines).strip()))
            current_pattern = _heading_to_slug(line[3:].strip())
            current_lines = [line]
        elif current_pattern is not None:
            current_lines.append(line)
        # else: preamble before first ## — discard

    if current_pattern is not None:
        sections.append((current_topic, current_pattern, "\n".join(current_lines).strip()))

    return [(t, p, c) for t, p, c in sections if c.strip()]


def _is_template_file(path: Path) -> bool:
    """True for _template.md files."""
    return path.name == "_template.md"


def _derive_scope(platform: str | None, project: str | None) -> str:
    if project:
        return "project"
    if platform:
        return "platform"
    return "universal"


class DirectorySource(KnowledgeSource):
    """Reads any supported file from kms/knowledge-sources/ — no frontmatter required.

    Three path conventions mirror the cascade tiers:

    1. Universal knowledge: {root}/universal/{discipline}/{artifact}/{filename}.md
       scope=universal, platform=None, discipline and artifact from subdirectory names

    2. Platform knowledge: {root}/platform/{platform}/{discipline}/{artifact}/{filename}.md
       scope=platform, platform/discipline/artifact from subdirectory names

    3. Project-specific knowledge: {root}/projects/{project-name}/{artifact}/{filename}.md
       scope=project, platform and project read from repo.yaml, artifact from subdirectory name
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
        yield from self._read_universal_docs()
        yield from self._read_platform_docs()
        yield from self._read_project_docs()

    # ------------------------------------------------------------------
    # Universal docs: {root}/universal/{discipline}/{file}.md
    # ------------------------------------------------------------------

    def _read_universal_docs(self) -> Iterator[KnowledgeNode]:
        yield from self._read_scope_dir(self._path / _UNIVERSAL_DIR, platform=None)

    # ------------------------------------------------------------------
    # Platform docs: {root}/platform/{platform}/{discipline}/{file}.md
    # ------------------------------------------------------------------

    def _read_platform_docs(self) -> Iterator[KnowledgeNode]:
        platform_root = self._path / _PLATFORM_DIR
        if not platform_root.exists():
            return
        for platform_dir in sorted(platform_root.iterdir()):
            if not platform_dir.is_dir():
                continue
            if platform_dir.name not in PLATFORM_VALUES:
                continue
            yield from self._read_scope_dir(platform_dir, platform=platform_dir.name)

    # ------------------------------------------------------------------
    # Shared discipline traversal
    # ------------------------------------------------------------------

    def _read_scope_dir(self, scope_dir: Path, platform: Optional[str]) -> Iterator[KnowledgeNode]:
        if not scope_dir.exists():
            return
        scope = _derive_scope(platform, None)

        for discipline_dir in sorted(scope_dir.iterdir()):
            if not discipline_dir.is_dir():
                continue
            if discipline_dir.name not in DISCIPLINE_VALUES:
                continue
            discipline = discipline_dir.name

            for artifact_dir in sorted(discipline_dir.iterdir()):
                if not artifact_dir.is_dir():
                    continue
                artifact = artifact_dir.name

                for path in sorted(artifact_dir.rglob("*")):
                    if path.is_dir() or path.name in ("README.md",):
                        continue
                    if path.suffix not in _SUPPORTED_SUFFIXES:
                        continue
                    if any(fnmatch.fnmatch(path.name, pat) for pat in SEED_EXCLUDE_PATTERNS):
                        print(f"  skip (excluded): {path.name}")
                        continue

                    file_topic, file_pattern = _parse_filename(path.stem)
                    raw = path.read_text(encoding="utf-8").strip()
                    content = _strip_frontmatter(raw)
                    chunks = _chunk_by_sections(content)
                    node_content_type = "stub" if _is_template_file(path) else "real"

                    if chunks:
                        for topic_slug, pattern_slug, section_content in chunks:
                            yield KnowledgeNode(
                                scope=scope,
                                platform=platform,
                                project=None,
                                discipline=discipline,
                                artifact=artifact,
                                topic=topic_slug if topic_slug else file_topic,
                                pattern=pattern_slug,
                                summary=_extract_summary(section_content),
                                source_file=str(path),
                                updated_at=date.today().isoformat(),
                                content_hash=hashlib.sha256(section_content.encode()).hexdigest(),
                                content=section_content,
                                content_type=node_content_type,
                            )
                    else:
                        yield KnowledgeNode(
                            scope=scope,
                            platform=platform,
                            project=None,
                            discipline=discipline,
                            artifact=artifact,
                            topic=file_topic,
                            pattern=file_pattern,
                            summary=_extract_summary(content),
                            source_file=str(path),
                            updated_at=date.today().isoformat(),
                            content_hash=hashlib.sha256(content.encode()).hexdigest(),
                            content=content,
                            content_type=node_content_type,
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

            for artifact_dir in sorted(project_dir.iterdir()):
                if not artifact_dir.is_dir():
                    continue
                artifact = artifact_dir.name

                for path in sorted(artifact_dir.rglob("*")):
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
                    raw = path.read_text(encoding="utf-8").strip()
                    content = _strip_frontmatter(raw)
                    chunks = _chunk_by_sections(content)

                    if chunks:
                        for topic_slug, pattern_slug, section_content in chunks:
                            yield KnowledgeNode(
                                scope="project",
                                platform=repo.platform,
                                project=repo.name,
                                discipline="engineering",
                                artifact=artifact,
                                topic=topic_slug if topic_slug else stem,
                                pattern=pattern_slug,
                                summary=_extract_summary(section_content),
                                source_file=str(path),
                                updated_at=date.today().isoformat(),
                                content_hash=hashlib.sha256(section_content.encode()).hexdigest(),
                                content=section_content,
                            )
                    else:
                        yield KnowledgeNode(
                            scope="project",
                            platform=repo.platform,
                            project=repo.name,
                            discipline="engineering",
                            artifact=artifact,
                            topic=stem,
                            pattern=stem,
                            summary=_extract_summary(content),
                            source_file=str(path),
                            updated_at=date.today().isoformat(),
                            content_hash=hashlib.sha256(content.encode()).hexdigest(),
                            content=content,
                        )
