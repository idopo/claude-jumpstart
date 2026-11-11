"""Tests for build.py: source parsing, layout caps, the title-fit rule and a 3-slide smoke build."""
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import build  # noqa: E402

TEMPLATE = HERE / "brand" / "WIS-extended-english-template.pptx"
SAMPLE_TEXT = ["Lorem", "Slide Headline", "Presentation Title", "Body copy", "Box text", "Name Surname",
               "January 1, 2023"]


def source(title, layout, body="", kicker=None, notes="narration"):
    kicker_line = f'kicker = "{kicker}"\n' if kicker else ""
    return f"+++\ntitle = \"{title}\"\nlayout = \"{layout}\"\n{kicker_line}notes = '''\n{notes}\n'''\n+++\n{body}"


def write(tmp, name, text):
    path = Path(tmp) / name
    path.write_text(text, encoding="utf-8")
    return path


class ParseTests(unittest.TestCase):
    def parse(self, text, name="02-x.md"):
        with tempfile.TemporaryDirectory() as tmp:
            return build.parse_slide(write(tmp, name, text))

    def test_fields_and_illustration(self):
        body = "- a `b`\n```\nline one\n  line two\n```\n- caption\n"
        slide = self.parse(source("A title here for all", "statement", body, kicker="K"))
        self.assertEqual(slide.title, "A title here for all")
        self.assertEqual(slide.layout, "statement")
        self.assertEqual(slide.kicker, "K")
        self.assertEqual(slide.notes, "narration")
        self.assertEqual(slide.bullets, ["a b", "caption"])
        self.assertEqual(slide.illustration, ["line one", "  line two"])

    def test_columns_groups(self):
        body = "## One\n- a\n- b\n## Two\n- c\n"
        slide = self.parse(source("Columns title is long enough", "columns", body))
        self.assertEqual([g.heading for g in slide.groups], ["One", "Two"])
        self.assertEqual(slide.groups[0].bullets, ["a", "b"])

    def test_errors_name_the_file(self):
        cases = {
            "no front matter": "no plus lines\n",
            "unknown layout": source("T", "nonsense"),
            "second fence": source("T", "statement", "```\na\n```\n```\nb\n```\n"),
            "long statement": source("T", "statement", "- " + " ".join(["w"] * (build.DEFAULT_MAX_BODY_WORDS + 1)) + "\n"),
            "tall illustration": source("T", "statement", "```\n" + "x\n" * 9 + "```\n"),
            "wide illustration": source("T", "statement", "```\n" + "x" * 65 + "\n```\n"),
            "boxes not three": source("T", "boxes", "- A — one\n- B — two\n"),
            "four groups": source("T", "columns", "".join(f"## G{i}\n- a\n" for i in range(4))),
            "seven bullets": source("T", "columns", "## G\n" + "- a\n" * 7 + "## H\n- b\n"),
        }
        for label, text in cases.items():
            with self.subTest(label):
                with self.assertRaises(build.SourceError) as ctx:
                    self.parse(text, name="07-bad.md")
                self.assertIn("07-bad.md", str(ctx.exception))


class VisualTests(unittest.TestCase):
    def test_cycle_needs_labels_highlight_and_back(self):
        from wis_visuals import check_visual
        self.assertIsNone(check_visual({"kind": "cycle", "labels": ["a", "b"], "highlight": "b", "back": "again"}))
        self.assertIn("back", check_visual({"kind": "cycle", "labels": ["a", "b"], "highlight": "b"}))

    def test_cycle_draws_a_return_arrow(self):
        from pptx import Presentation
        from pptx.enum.shapes import MSO_SHAPE, MSO_SHAPE_TYPE
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "src"
            src.mkdir()
            write(src, "01-title.md", source("Smoke deck", "title", "- Sub\n- Me\n", notes="n1"))
            cycle = ('[visual]\nkind = "cycle"\nlabels = ["look", "correct", "run"]\nhighlight = "run"\n'
                     'back = "until it is right"\n')
            text = source("One pass is a draft; loop until it is right", "statement", "- caption\n", kicker="P",
                          notes="n2").replace("'''\n+++", "'''\n\n" + cycle + "+++")
            write(src, "02-loop.md", text)
            out = Path(tmp) / "out.pptx"
            build.build_deck(src, out, TEMPLATE)
            slide = list(Presentation(str(out)).slides)[1]
            arrows = [sh for sh in slide.shapes
                      if sh.shape_type == MSO_SHAPE_TYPE.AUTO_SHAPE and sh.auto_shape_type == MSO_SHAPE.LEFT_ARROW]
            self.assertEqual(len(arrows), 1)
            texts = " ".join(sh.text_frame.text for sh in slide.shapes if sh.has_text_frame)
            self.assertIn("until it is right", texts)


class TitleFitTests(unittest.TestCase):
    def test_sizes_step_down(self):
        self.assertEqual(build.title_size("Short title", 11.1), 50)
        self.assertEqual(build.title_size("x " * 35, 11.1), 44)
        self.assertEqual(build.title_size("x " * 40, 11.1), 40)

    def test_too_long_names_title(self):
        title = "word " * 60
        with self.assertRaises(ValueError) as ctx:
            build.title_size(title, 11.1)
        self.assertIn("word word", str(ctx.exception))


class SmokeBuildTests(unittest.TestCase):
    def test_three_slide_deck(self):
        from pptx import Presentation
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "src"
            src.mkdir()
            write(src, "01-title.md", source("Smoke deck", "title", "- Sub\n- Me\n", notes="n1"))
            write(src, "02-s.md", source("Claude reads the files you point it at", "statement",
                                         "```\nA\n B\n```\n- caption\n", kicker="Part", notes="n2"))
            write(src, "03-closing.md", source("Thank you", "closing", "- repo\n- Questions\n", notes="n3"))
            out = Path(tmp) / "out.pptx"
            build.build_deck(src, out, TEMPLATE)
            prs = Presentation(str(out))
            self.assertEqual(len(prs.slides), 3)
            self.assertEqual([s.notes_slide.notes_text_frame.text for s in prs.slides], ["n1", "n2", "n3"])
            text = " ".join(sh.text_frame.text for s in prs.slides for sh in s.shapes if sh.has_text_frame)
            for sample in SAMPLE_TEXT:
                self.assertNotIn(sample, text)
            names = zipfile.ZipFile(out).namelist()
            self.assertEqual(sum(n.endswith(".fntdata") for n in names), 4)  # Benton Sans x3 + Weizmann

    def test_template_only_fonts_are_stripped(self):
        from wis_fonts import TEMPLATE_ONLY_FONTS
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "src"
            src.mkdir()
            write(src, "01-title.md", source("Smoke deck", "title", "- Sub\n- Me\n", notes="n1"))
            write(src, "02-closing.md", source("Thank you", "closing", "- repo\n", notes="n2"))
            out = Path(tmp) / "out.pptx"
            build.build_deck(src, out, TEMPLATE)
            with zipfile.ZipFile(out) as z:
                xml = "".join(z.read(n).decode("utf8") for n in z.namelist() if n.endswith((".xml", ".rels")))
            for face in TEMPLATE_ONLY_FONTS:
                self.assertNotIn(f'typeface="{face}"', xml)
            self.assertNotIn("fonts/font5.fntdata", xml)


if __name__ == "__main__":
    unittest.main()
