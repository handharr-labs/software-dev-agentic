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
from ..schema import (
    AREA_VALUES,
    DEFAULT_LAYER,
    DISCIPLINE_VALUES,
    LAYER_VALUES,
    OWNER_VALUES,
    PLATFORM_VALUES,
    SEED_EXCLUDE_PATTERNS,
    TOPIC_LAYER_MARKERS,
)
from .base import KnowledgeSource

_SUPPORTED_SUFFIXES = {".md", ".txt"}
_FIRST_SENTENCE_RE = re.compile(r"^[^#\n].+?(?<=[.!?])\s", re.DOTALL)
_FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
_UNIVERSAL_DIR = "universal"
_PLATFORM_DIR = "platform"
_PROJECTS_DIR = "projects"
_REPO_YAML = "repo.yaml"
_OVERVIEW_SECTION = "overview"


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
        return _RepoMeta(name=project_dir.name, platform=None, remote=None, local_path=None)
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
    """Derive (topic, pattern) from filename stem. Platform is directory-derived.

    standard-architecture → (standard_architecture, standard_architecture)
    """
    snake = stem.replace("-", "_")
    return snake, snake


def _heading_to_slug(heading: str) -> str:
    """Convert a markdown heading to a snake_case slug for use as topic/section."""
    slug = re.sub(r"[^\w\s]", "", heading.lower())
    return re.sub(r"\s+", "_", slug.strip())


def _parse_frontmatter(raw: str) -> dict:
    """Return the YAML frontmatter block as a dict ({} when absent or unparseable)."""
    m = _FRONTMATTER_RE.match(raw)
    if not m:
        return {}
    try:
        data = yaml.safe_load(m.group(1))
    except yaml.YAMLError:
        return {}
    return data if isinstance(data, dict) else {}


def _strip_frontmatter(content: str) -> str:
    """Remove YAML frontmatter block (--- ... ---) if present."""
    if not content.startswith("---"):
        return content
    end = content.find("\n---\n", 3)
    if end == -1:
        return content
    return content[end + 5:].strip()


def _is_template_file(path: Path) -> bool:
    """True for _template.md files."""
    return path.name == "_template.md"


def _derive_scope(platform: str | None, project: str | None) -> str:
    if project:
        return "project"
    if platform:
        return "platform"
    return "universal"


def _is_heading(line: str) -> bool:
    return line.lstrip().startswith("#")


def _chunk_by_sections(content: str) -> list[tuple[str, str, str]]:
    """Chunk content at the `##` level — one node per concept.

    Returns [(topic_slug, section_slug, section_content), ...].

    - `# heading`   → updates topic context; NOT a node boundary.
    - `## heading`  → node boundary. The node includes everything beneath it
      (`###`, `####`, prose) up to the next `##` — theory + code pattern stay together.
    - Preamble before the first `##` is captured as an `overview` node — never
      discarded — but only when it contains real (non-heading) prose.

    Returns [] only when there is no content at all.
    """
    lines = content.splitlines()
    sections: list[tuple[str, str, str]] = []

    current_topic = ""
    current_section: Optional[str] = None
    current_lines: list[str] = []
    preamble_lines: list[str] = []
    seen_section = False

    def _flush(topic: str, section: str, buf: list[str]) -> None:
        text = "\n".join(buf).strip()
        if text:
            sections.append((topic, section, text))

    def _flush_preamble() -> None:
        # Only emit an overview node if the preamble holds non-heading prose.
        if any(ln.strip() and not _is_heading(ln) for ln in preamble_lines):
            _flush(current_topic, _OVERVIEW_SECTION, preamble_lines)

    for line in lines:
        if line.startswith("# ") and not line.startswith("## "):
            current_topic = _heading_to_slug(line[2:].strip())
            (preamble_lines if not seen_section else current_lines).append(line)
        elif line.startswith("## "):
            if not seen_section:
                _flush_preamble()
                seen_section = True
            else:
                _flush(current_topic, current_section or _OVERVIEW_SECTION, current_lines)
            current_section = _heading_to_slug(line[3:].strip())
            current_lines = [line]
        else:
            (preamble_lines if not seen_section else current_lines).append(line)

    if seen_section:
        _flush(current_topic, current_section or _OVERVIEW_SECTION, current_lines)
    else:
        # No `##` at all — whole file is one node.
        _flush(current_topic, _OVERVIEW_SECTION, preamble_lines)

    return sections


class DirectorySource(KnowledgeSource):
    """Reads any supported file from kms/knowledge-sources/ — frontmatter-authoritative.

    Facets resolve **frontmatter first, path as fallback**. The path still provides
    sensible defaults (and keeps the tree browsable), but a file is no longer silently
    mis-seeded by its folder: invalid facet values are reported and skipped.

    Three path conventions mirror the cascade tiers:

    1. Universal: {root}/universal/{discipline}/{area}/{artifact}.md
    2. Platform:  {root}/platform/{platform}/{discipline}/{area}/{artifact}.md
    3. Project:   {root}/projects/{project}/{discipline}/{area}/{artifact}.md
       (platform + canonical project name come from repo.yaml)
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
    # Facet resolution + validation (frontmatter authoritative, path fallback)
    # ------------------------------------------------------------------

    def _relpath(self, path: Path) -> str:
        """source_file relative to the knowledge-sources root — portable + drift-proof."""
        try:
            return str(path.relative_to(self._path))
        except ValueError:
            return str(path)

    @staticmethod
    def _validate(platform, project, discipline, area, layer, owner) -> list[str]:
        errs: list[str] = []
        if platform is not None and platform not in PLATFORM_VALUES:
            errs.append(f"platform '{platform}' not in {PLATFORM_VALUES}")
        if discipline not in DISCIPLINE_VALUES:
            errs.append(f"discipline '{discipline}' not in {DISCIPLINE_VALUES}")
        if area not in AREA_VALUES:
            errs.append(f"area '{area}' not in {AREA_VALUES}")
        if layer is not None and layer not in LAYER_VALUES:
            errs.append(f"layer '{layer}' not in {LAYER_VALUES}")
        if owner not in OWNER_VALUES:
            errs.append(f"owner '{owner}' not in {OWNER_VALUES}")
        return errs

    def _emit_nodes(
        self,
        path: Path,
        *,
        path_platform: Optional[str],
        path_project: Optional[str],
        path_discipline: str,
        path_area: str,
    ) -> Iterator[KnowledgeNode]:
        raw = path.read_text(encoding="utf-8").strip()
        fm = _parse_frontmatter(raw)

        # Frontmatter wins when present; path is the fallback.
        platform = fm.get("platform") or path_platform
        project = fm.get("project") or path_project
        discipline = fm.get("discipline") or path_discipline
        area = fm.get("area") or path_area
        fm_layer = fm.get("layer") or None   # explicit frontmatter layer wins over topic inference
        owner = fm.get("owner") or "curated"
        tags = fm.get("tags") or []
        artifact = (fm.get("artifact") or path.stem).replace("-", "_")

        errs = self._validate(platform, project, discipline, area, fm_layer, owner)
        if errs:
            for e in errs:
                print(f"  skip (invalid facet): {self._relpath(path)} — {e}")
            return

        scope = _derive_scope(platform, project)
        rel = self._relpath(path)
        content_type = "stub" if _is_template_file(path) else "real"
        file_topic, _ = _parse_filename(path.stem)
        content = _strip_frontmatter(raw)

        for topic_slug, section_slug, section_content in _chunk_by_sections(content):
            # layer precedence: explicit frontmatter > topic-heading marker > cross floor
            node_layer = fm_layer or TOPIC_LAYER_MARKERS.get(topic_slug) or DEFAULT_LAYER
            yield KnowledgeNode(
                scope=scope,
                platform=platform,
                project=project,
                discipline=discipline,
                area=area,
                layer=node_layer,
                owner=owner,
                artifact=artifact,
                topic=topic_slug or file_topic,
                subtopic=section_slug,
                pattern=section_slug,
                summary=_extract_summary(section_content),
                tags=tags,
                source_file=rel,
                updated_at=date.today().isoformat(),
                content_hash=hashlib.sha256(section_content.encode()).hexdigest(),
                content=section_content,
                content_type=content_type,
            )

    @staticmethod
    def _is_seedable(path: Path) -> bool:
        if path.is_dir() or path.name in ("README.md", _REPO_YAML):
            return False
        if path.suffix not in _SUPPORTED_SUFFIXES:
            return False
        if any(fnmatch.fnmatch(path.name, pat) for pat in SEED_EXCLUDE_PATTERNS):
            print(f"  skip (excluded): {path.name}")
            return False
        return True

    # ------------------------------------------------------------------
    # Universal + platform docs
    # ------------------------------------------------------------------

    def _read_universal_docs(self) -> Iterator[KnowledgeNode]:
        yield from self._read_scope_dir(self._path / _UNIVERSAL_DIR, platform=None)

    def _read_platform_docs(self) -> Iterator[KnowledgeNode]:
        platform_root = self._path / _PLATFORM_DIR
        if not platform_root.exists():
            return
        for platform_dir in sorted(platform_root.iterdir()):
            if not platform_dir.is_dir() or platform_dir.name not in PLATFORM_VALUES:
                continue
            yield from self._read_scope_dir(platform_dir, platform=platform_dir.name)

    def _read_scope_dir(self, scope_dir: Path, platform: Optional[str]) -> Iterator[KnowledgeNode]:
        if not scope_dir.exists():
            return
        for discipline_dir in sorted(scope_dir.iterdir()):
            if not discipline_dir.is_dir() or discipline_dir.name not in DISCIPLINE_VALUES:
                continue
            for area_dir in sorted(discipline_dir.iterdir()):
                if not area_dir.is_dir() or area_dir.name not in AREA_VALUES:
                    continue
                for path in sorted(area_dir.iterdir()):
                    if not self._is_seedable(path):
                        continue
                    yield from self._emit_nodes(
                        path,
                        path_platform=platform,
                        path_project=None,
                        path_discipline=discipline_dir.name,
                        path_area=area_dir.name,
                    )

    # ------------------------------------------------------------------
    # Project docs
    # ------------------------------------------------------------------

    def _read_project_docs(self) -> Iterator[KnowledgeNode]:
        projects_dir = self._path / _PROJECTS_DIR
        if not projects_dir.exists():
            return
        for project_dir in sorted(projects_dir.iterdir()):
            if not project_dir.is_dir():
                continue
            repo = _load_repo_meta(project_dir)
            for discipline_dir in sorted(project_dir.iterdir()):
                if not discipline_dir.is_dir() or discipline_dir.name not in DISCIPLINE_VALUES:
                    continue
                for area_dir in sorted(discipline_dir.iterdir()):
                    if not area_dir.is_dir() or area_dir.name not in AREA_VALUES:
                        continue
                    for path in sorted(area_dir.iterdir()):
                        if not self._is_seedable(path):
                            continue
                        yield from self._emit_nodes(
                            path,
                            path_platform=repo.platform,
                            path_project=repo.name,
                            path_discipline=discipline_dir.name,
                            path_area=area_dir.name,
                        )
