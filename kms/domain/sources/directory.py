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
from ..schema import AREA_VALUES, DISCIPLINE_VALUES, PLATFORM_VALUES, SEED_EXCLUDE_PATTERNS
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


def _chunk_by_sections(content: str) -> list[tuple[str, str, str, str]]:
    """Split content by ## and ### headings. Returns [(topic_slug, subtopic_slug, pattern_slug, section_content), ...].

    # heading   → updates topic context; not a chunk boundary
    ## heading  → subtopic boundary; becomes the pattern node UNLESS it has ### children
    ### heading → when present under a ##, becomes its own pattern node (subtopic = ## slug)
    #### +      → content within the enclosing node; not split further

    Returns [] when no ## headings found — caller yields file as a single node.
    topic_slug is "" when no # heading precedes the ## — caller uses artifact name as fallback.
    Lines before the first ## (preamble), and lines between a ## heading and its first
    ### child (if any), are discarded.
    """
    lines = content.splitlines()

    # Pass 1: split into ##-sections — (topic_slug, subtopic_slug, lines)
    raw_sections: list[tuple[str, str, list[str]]] = []
    current_topic: str = ""
    current_subtopic: str | None = None
    current_lines: list[str] = []

    for line in lines:
        if line.startswith("# ") and not line.startswith("## "):
            if current_subtopic is not None:
                raw_sections.append((current_topic, current_subtopic, current_lines))
                current_subtopic = None
                current_lines = []
            current_topic = _heading_to_slug(line[2:].strip())
        elif line.startswith("## "):
            if current_subtopic is not None:
                raw_sections.append((current_topic, current_subtopic, current_lines))
            current_subtopic = _heading_to_slug(line[3:].strip())
            current_lines = [line]
        elif current_subtopic is not None:
            current_lines.append(line)
        # else: preamble before first ## — discard

    if current_subtopic is not None:
        raw_sections.append((current_topic, current_subtopic, current_lines))

    # Pass 2: split each ##-section further by ### if present
    sections: list[tuple[str, str, str, str]] = []
    for topic_slug, subtopic_slug, sec_lines in raw_sections:
        sub_sections: list[tuple[str, list[str]]] = []
        current_pattern: str | None = None
        current_sub_lines: list[str] = []

        for line in sec_lines:
            if line.startswith("### "):
                if current_pattern is not None:
                    sub_sections.append((current_pattern, current_sub_lines))
                current_pattern = _heading_to_slug(line[4:].strip())
                current_sub_lines = [line]
            elif current_pattern is not None:
                current_sub_lines.append(line)
            # else: lines before first ### (incl. the ## heading line) — discard

        if current_pattern is not None:
            sub_sections.append((current_pattern, current_sub_lines))

        if sub_sections:
            for pattern_slug, sub_lines in sub_sections:
                section_content = "\n".join(sub_lines).strip()
                if section_content:
                    sections.append((topic_slug, subtopic_slug, pattern_slug, section_content))
        else:
            section_content = "\n".join(sec_lines).strip()
            if section_content:
                sections.append((topic_slug, subtopic_slug, subtopic_slug, section_content))

    return sections


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

    1. Universal knowledge: {root}/universal/{discipline}/{area}/{artifact}.md
       scope=universal, platform=None, discipline/area from directory names, artifact from filename stem

    2. Platform knowledge: {root}/platform/{platform}/{discipline}/{area}/{artifact}.md
       scope=platform, platform/discipline/area from directory names, artifact from filename stem

    3. Project-specific knowledge: {root}/projects/{project-name}/{area}/{artifact}.md
       scope=project, platform and project read from repo.yaml, area from directory name, artifact from filename stem
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

            for area_dir in sorted(discipline_dir.iterdir()):
                if not area_dir.is_dir():
                    continue
                if area_dir.name not in AREA_VALUES:
                    continue
                area = area_dir.name

                for path in sorted(area_dir.iterdir()):
                    if path.is_dir() or path.name in ("README.md",):
                        continue
                    if path.suffix not in _SUPPORTED_SUFFIXES:
                        continue
                    if any(fnmatch.fnmatch(path.name, pat) for pat in SEED_EXCLUDE_PATTERNS):
                        print(f"  skip (excluded): {path.name}")
                        continue

                    artifact = path.stem.replace("-", "_")
                    file_topic, file_pattern = _parse_filename(path.stem)
                    raw = path.read_text(encoding="utf-8").strip()
                    content = _strip_frontmatter(raw)
                    chunks = _chunk_by_sections(content)
                    node_content_type = "stub" if _is_template_file(path) else "real"

                    if chunks:
                        for topic_slug, subtopic_slug, pattern_slug, section_content in chunks:
                            yield KnowledgeNode(
                                scope=scope,
                                platform=platform,
                                project=None,
                                discipline=discipline,
                                area=area,
                                artifact=artifact,
                                topic=topic_slug if topic_slug else file_topic,
                                subtopic=subtopic_slug,
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
                            area=area,
                            artifact=artifact,
                            topic=file_topic,
                            subtopic=file_pattern,
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

            for area_dir in sorted(project_dir.iterdir()):
                if not area_dir.is_dir():
                    continue
                if area_dir.name not in AREA_VALUES:
                    continue
                area = area_dir.name

                for path in sorted(area_dir.iterdir()):
                    if path.is_dir():
                        continue
                    if path.name in ("README.md", _REPO_YAML):
                        continue
                    if path.suffix not in _SUPPORTED_SUFFIXES:
                        continue
                    if any(fnmatch.fnmatch(path.name, pat) for pat in SEED_EXCLUDE_PATTERNS):
                        print(f"  skip (excluded): {path.name}")
                        continue

                    artifact = path.stem.replace("-", "_")
                    stem = artifact
                    raw = path.read_text(encoding="utf-8").strip()
                    content = _strip_frontmatter(raw)
                    chunks = _chunk_by_sections(content)

                    if chunks:
                        for topic_slug, subtopic_slug, pattern_slug, section_content in chunks:
                            yield KnowledgeNode(
                                scope="project",
                                platform=repo.platform,
                                project=repo.name,
                                discipline="engineering",
                                area=area,
                                artifact=artifact,
                                topic=topic_slug if topic_slug else stem,
                                subtopic=subtopic_slug,
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
                            area=area,
                            artifact=artifact,
                            topic=stem,
                            subtopic=stem,
                            pattern=stem,
                            summary=_extract_summary(content),
                            source_file=str(path),
                            updated_at=date.today().isoformat(),
                            content_hash=hashlib.sha256(content.encode()).hexdigest(),
                            content=content,
                        )
