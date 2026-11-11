"""Build claude-jumpstart.pptx from deck/src/*.md on the official Weizmann template. Never writes to deck/src.

Usage: python -I deck/build.py [--src DIR] [--out FILE] [--template FILE]
"""
import argparse
import re
import sys
import tomllib
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))  # -I drops the script folder from sys.path

from pptx import Presentation  # noqa: E402

from wis_fill import FILLERS  # noqa: E402
from wis_fonts import strip_unused_template_fonts  # noqa: E402
from wis_visuals import apply_visual, check_visual  # noqa: E402
from wis_template import (PROTOTYPES, duplicate_slide, remove_sample_slides, sample_slide_ids,  # noqa: E402
                          set_slide_number, title_size)

HERE = Path(__file__).resolve().parent
FILE_PATTERN = re.compile(r"^\d\d-[a-z0-9-]+\.md$")
MAX_BODY_WORDS = {"columns": 60}
DEFAULT_MAX_BODY_WORDS = 40
MAX_ILLUSTRATION_LINES = 8
MAX_ILLUSTRATION_CHARS = 64
MAX_COLUMNS = 3
MAX_COLUMN_BULLETS = 6
MAX_FENCED_BLOCKS = 4
POINTS_RANGE = (2, 4)
BOX_COUNT = 3


class SourceError(ValueError):
    pass


@dataclass
class Group:
    heading: str
    bullets: list = field(default_factory=list)
    illustration: list | None = None


@dataclass
class Slide:
    file: str
    title: str
    layout: str
    kicker: str | None
    notes: str
    bullets: list = field(default_factory=list)
    illustration: list | None = None
    groups: list = field(default_factory=list)
    visual: dict | None = None


def plain(text):
    return text.replace("`", "")


def parse_body(text, file, layout):
    slide_part = Slide(file, "", layout, None, "")
    container = slide_part
    fence = None
    for line in text.split("\n"):
        if line.strip().startswith("```"):
            if fence is None:
                fence = []
                continue
            if container.illustration is not None:
                raise SourceError(f"{file}: more than one fenced block")
            container.illustration = fence
            fence = None
        elif fence is not None:
            fence.append(line)
        elif line.startswith("## "):
            container = Group(plain(line[3:].strip()))
            slide_part.groups.append(container)
        elif line.startswith("- "):
            container.bullets.append(plain(line[2:].strip()))
        elif line.strip():
            raise SourceError(f"{file}: unexpected body line {line.strip()!r}")
    if fence is not None:
        raise SourceError(f"{file}: unclosed fenced block")
    return slide_part


def check_caps(slide):
    file, layout = slide.file, slide.layout
    words = sum(len(b.split()) for b in slide.bullets) + sum(len(b.split()) for g in slide.groups for b in g.bullets)
    if words > MAX_BODY_WORDS.get(layout, DEFAULT_MAX_BODY_WORDS):
        raise SourceError(f"{file}: {layout} body has {words} words")
    for block in [slide.illustration] + [g.illustration for g in slide.groups]:
        if block and (len(block) > MAX_ILLUSTRATION_LINES or max(map(len, block)) > MAX_ILLUSTRATION_CHARS):
            raise SourceError(f"{file}: illustration over {MAX_ILLUSTRATION_LINES} lines or "
                              f"{MAX_ILLUSTRATION_CHARS} characters")
    if layout == "boxes" and (len(slide.bullets) != BOX_COUNT or any(" — " not in b for b in slide.bullets)):
        raise SourceError(f"{file}: boxes needs exactly {BOX_COUNT} 'Label — line' bullets")
    if layout == "columns":
        if not 2 <= len(slide.groups) <= MAX_COLUMNS:
            raise SourceError(f"{file}: columns needs 2 or {MAX_COLUMNS} groups")
        if any(len(g.bullets) > MAX_COLUMN_BULLETS for g in slide.groups):
            raise SourceError(f"{file}: more than {MAX_COLUMN_BULLETS} bullets in a column")
    if layout == "points" and not POINTS_RANGE[0] <= len(slide.bullets) <= POINTS_RANGE[1]:
        raise SourceError(f"{file}: points needs {POINTS_RANGE[0]}-{POINTS_RANGE[1]} bullets")
    if layout == "title" and len(slide.bullets) != 2:
        raise SourceError(f"{file}: title needs subtitle and presenter bullets")
    if layout == "closing" and not slide.bullets:
        raise SourceError(f"{file}: closing needs a bullet")


def parse_slide(path):
    path = Path(path)
    file = path.name
    text = path.read_text(encoding="utf-8")
    parts = text.split("+++\n", 2)
    if len(parts) != 3 or parts[0] != "":
        raise SourceError(f"{file}: missing +++ front matter")
    try:
        meta = tomllib.loads(parts[1])
    except tomllib.TOMLDecodeError as error:
        raise SourceError(f"{file}: bad front matter: {error}") from error
    layout = meta.get("layout")
    if layout not in PROTOTYPES:
        raise SourceError(f"{file}: unknown layout {layout!r}")
    if not meta.get("title"):
        raise SourceError(f"{file}: missing title")
    notes = str(meta.get("notes", "")).strip()
    if not notes:
        raise SourceError(f"{file}: empty notes")
    slide = parse_body(parts[2], file, layout)
    slide.title, slide.kicker, slide.notes = plain(meta["title"]), meta.get("kicker"), notes
    check_caps(slide)
    # The boxes layout is drawn by the pictograms visual, so it needs one even when the source names none.
    slide.visual = meta.get("visual") or ({"kind": "pictograms"} if layout == "boxes" else None)
    problem = check_visual(slide.visual) if slide.visual else None
    if problem:
        raise SourceError(f"{file}: {problem}")
    return slide


def load_slides(src):
    files = sorted(p for p in Path(src).iterdir() if p.is_file())
    errors = [f"{p.name}: bad file name" for p in files if not FILE_PATTERN.match(p.name)]
    slides = []
    for path in (p for p in files if FILE_PATTERN.match(p.name)):
        try:
            slides.append(parse_slide(path))
        except SourceError as error:
            errors.append(str(error))
    if sum(1 for s in slides if s.illustration) > MAX_FENCED_BLOCKS:
        errors.append(f"more than {MAX_FENCED_BLOCKS} illustrations in the deck")
    if not slides and not errors:
        errors.append("no slides found")
    return slides, errors


def build_deck(src, out, template):
    slides, errors = load_slides(src)
    if errors:
        raise SourceError("\n".join(errors))
    prs = Presentation(str(template))
    samples = list(prs.slides)
    sample_ids = sample_slide_ids(prs)
    deck_name = slides[0].title
    for number, slide in enumerate(slides, start=1):
        try:
            new = duplicate_slide(prs, samples[PROTOTYPES[slide.layout] - 1])
            FILLERS[slide.layout](new, slide, deck_name)
            apply_visual(new, slide)
        except ValueError as error:
            errors.append(f"{slide.file}: {error}")
            continue
        set_slide_number(new, number)
        new.notes_slide.notes_text_frame.text = slide.notes
    if errors:
        raise SourceError("\n".join(errors))
    remove_sample_slides(prs, sample_ids)
    prs.save(str(out))
    strip_unused_template_fonts(out)
    return len(slides)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--src", default=HERE / "src", type=Path)
    parser.add_argument("--out", default=HERE / "claude-jumpstart.pptx", type=Path)
    parser.add_argument("--template", default=HERE / "brand" / "WIS-extended-english-template.pptx", type=Path)
    args = parser.parse_args()
    try:
        count = build_deck(args.src, args.out, args.template)
    except SourceError as error:
        print(error, file=sys.stderr)
        return 1
    print(f"built {args.out}: {count} slides")
    return 0


if __name__ == "__main__":
    sys.exit(main())
