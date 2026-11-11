"""Compare every slide's notes in the pptx with the notes of its deck/src file.

Usage: qa/venv/bin/python -I deck/qa/notes_equal.py deck/claude-jumpstart.pptx
"""
import re
import sys
from pathlib import Path

DECK = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(DECK))

from pptx import Presentation  # noqa: E402

import build  # noqa: E402


def normalise(text):
    return re.sub(r"\s+", " ", text).strip()


def main(pptx):
    sources = sorted(p for p in (DECK / "src").glob("*.md") if build.FILE_PATTERN.match(p.name))
    slides = list(Presentation(pptx).slides)
    matching = 0
    for number, (path, slide) in enumerate(zip(sources, slides), start=1):
        expected = normalise(build.parse_slide(path).notes)
        actual = normalise(slide.notes_slide.notes_text_frame.text)
        if expected == actual:
            matching += 1
        else:
            print(f"MISMATCH slide {number}: {path.name}")
    print(f"NOTES_EQUAL {matching}/{len(slides)}")
    return 0 if matching == len(slides) == len(sources) else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
