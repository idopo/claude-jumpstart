"""Illustrations drawn with python-pptx autoshapes (brand colours only, no image files).

Each slide source may carry a `[visual]` TOML table (layout metadata): `kind` plus the labels to draw. Every label
reuses words already on the slide or in its notes. Palette: template black, template cream, one orange accent.
"""
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.oxml.ns import qn
from pptx.util import Emu, Pt

from wis_template import BODY_FONT, BODY_TOP, CONTENT_LEFT, CONTENT_WIDTH, CREAM_HEX, MONO_FONT

BLACK = RGBColor(0, 0, 0)
ORANGE = RGBColor.from_string("F26B43")
CREAM = RGBColor.from_string(CREAM_HEX)
LINE_PT = 1.5
ACCENT_LINE_PT = 3
LABEL_PT = 24  # minimum text size inside a visual is 18 pt; 24 reads from the back of the room
SMALL_PT = 20
PICTOGRAM_IN = 1.2
BOX_GAP_IN = 0.7
TWO_ROLES_HEIGHT_IN = 1.9
TWO_ROLES_BODY_TOP_IN = BODY_TOP + TWO_ROLES_HEIGHT_IN + 0.5


def body_top(slide_source):
    """Where the body text starts: below the visual when the visual sits above the body."""
    visual = slide_source.visual
    return TWO_ROLES_BODY_TOP_IN if visual and visual["kind"] == "two-roles" else BODY_TOP


def inch(value):
    return Emu(int(value * 914400))


def shape(slide, kind, x, y, w, h, line=BLACK, fill=None, weight=LINE_PT):
    item = slide.shapes.add_shape(kind, inch(x), inch(y), inch(w), inch(h))
    style = item._element.find(qn("p:style"))
    if style is not None:
        item._element.remove(style)  # theme style adds shadow and white text
    item.shadow.inherit = False
    if fill is None:
        item.fill.background()
    else:
        item.fill.solid()
        item.fill.fore_color.rgb = fill
    if line is None:
        item.line.fill.background()
    else:
        item.line.color.rgb = line
        item.line.width = Pt(weight)
    return item


def write(item, lines, align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE):
    """lines: (text, size, font, color) tuples, one paragraph each."""
    frame = item.text_frame
    frame.word_wrap = True
    frame.vertical_anchor = anchor
    frame.margin_left = frame.margin_right = inch(0.15)
    frame.margin_top = frame.margin_bottom = inch(0.05)
    for index, (text, size, font, color) in enumerate(lines):
        paragraph = frame.paragraphs[0] if index == 0 else frame.add_paragraph()
        paragraph.alignment = align
        run = paragraph.add_run()
        run.text = text
        run.font.size = Pt(size)
        run.font.name = font
        run.font.color.rgb = color


def label(slide, x, y, w, h, text, size=LABEL_PT, font=BODY_FONT, color=BLACK, align=PP_ALIGN.CENTER):
    item = shape(slide, MSO_SHAPE.RECTANGLE, x, y, w, h, line=None)
    write(item, [(text, size, font, color)], align)
    return item


def column_centres(count, width_in):
    step = (CONTENT_WIDTH - width_in) / (count - 1)
    return [CONTENT_LEFT + width_in / 2 + i * step for i in range(count)]


def pictograms(slide, s):
    """Three boxes (Label — line) with a drawn pictogram above each; the Code box carries the accent."""
    count = len(s.bullets)
    width = (CONTENT_WIDTH - BOX_GAP_IN * (count - 1)) / count
    top, box_top, box_height = 4.5, 6.0, 3.4
    for index, (centre, bullet) in enumerate(zip(column_centres(count, width), s.bullets)):
        name, _, line = bullet.partition(" — ")
        active = index == count - 1
        box = shape(slide, MSO_SHAPE.RECTANGLE, centre - width / 2, box_top, width, box_height,
                    line=ORANGE if active else BLACK, weight=ACCENT_LINE_PT if active else LINE_PT)
        write(box, [(name, 36, BODY_FONT, BLACK), (line, LABEL_PT, BODY_FONT, BLACK)])
        PICTOGRAMS[index](slide, centre, top)


def chat_pictogram(slide, centre, top):
    shape(slide, MSO_SHAPE.ROUNDED_RECTANGULAR_CALLOUT, centre - 0.75, top, 1.5, 1.0)
    for step, color in enumerate((BLACK, BLACK, ORANGE)):
        shape(slide, MSO_SHAPE.OVAL, centre - 0.4 + step * 0.34, top + 0.38, 0.2, 0.2, line=None, fill=color)


def cowork_pictogram(slide, centre, top):
    shape(slide, MSO_SHAPE.RECTANGLE, centre - 0.75, top + 0.2, 0.6, 0.25)
    shape(slide, MSO_SHAPE.RECTANGLE, centre - 0.75, top + 0.4, 1.5, 0.8, fill=CREAM)
    shape(slide, MSO_SHAPE.CLOUD, centre + 0.1, top - 0.05, 0.95, 0.6, line=ORANGE, fill=CREAM, weight=ACCENT_LINE_PT)


def code_pictogram(slide, centre, top):
    shape(slide, MSO_SHAPE.RECTANGLE, centre - 0.75, top + 0.05, 1.5, 1.1)
    shape(slide, MSO_SHAPE.RECTANGLE, centre - 0.75, top + 0.05, 1.5, 0.22, fill=BLACK)
    label(slide, centre - 0.7, top + 0.3, 0.7, 0.8, ">", 36, MONO_FONT, ORANGE, PP_ALIGN.LEFT)
    shape(slide, MSO_SHAPE.RECTANGLE, centre + 0.0, top + 0.78, 0.4, 0.07, line=None, fill=BLACK)


PICTOGRAMS = (chat_pictogram, cowork_pictogram, code_pictogram)


def chevron_row(slide, labels, highlight, top, height, size):
    count = len(labels)
    overlap = 0.15
    width = (CONTENT_WIDTH + overlap * (count - 1)) / count
    for index, text in enumerate(labels):
        marked = text == highlight
        item = shape(slide, MSO_SHAPE.CHEVRON, CONTENT_LEFT + index * (width - overlap), top, width, height,
                     line=ORANGE if marked else BLACK, fill=ORANGE if marked else None,
                     weight=ACCENT_LINE_PT if marked else LINE_PT)
        write(item, [(text, size, BODY_FONT, BLACK)])


def flow(slide, s):
    visual = s.visual
    chevron_row(slide, visual["labels"], visual["highlight"], visual.get("top", 8.6), 1.4, 28)


def cycle(slide, s):
    """A flow whose last step returns to the first: chevrons, then an orange arrow back with the loop's rule."""
    visual = s.visual
    top, height = visual.get("top", 7.9), 1.3
    chevron_row(slide, visual["labels"], visual["highlight"], top, height, 28)
    arrow = shape(slide, MSO_SHAPE.LEFT_ARROW, CONTENT_LEFT + 0.6, top + height + 0.3, CONTENT_WIDTH - 1.2, 0.9,
                  line=None, fill=ORANGE)
    write(arrow, [(visual["back"], LABEL_PT, BODY_FONT, BLACK)])


def two_roles(slide, s):
    visual = s.visual
    width, top = 8.0, BODY_TOP
    for key, x, accent in (("left", CONTENT_LEFT, True), ("right", CONTENT_LEFT + CONTENT_WIDTH - width, False)):
        name, line = visual[key]
        box = shape(slide, MSO_SHAPE.RECTANGLE, x, top, width, TWO_ROLES_HEIGHT_IN,
                    line=ORANGE if accent else BLACK, weight=ACCENT_LINE_PT if accent else LINE_PT)
        write(box, [(name, 32, BODY_FONT, BLACK), (line, LABEL_PT, BODY_FONT, BLACK)])
    gap_left = CONTENT_LEFT + width + 0.35
    gap = CONTENT_WIDTH - 2 * width - 0.7
    shape(slide, MSO_SHAPE.RIGHT_ARROW, gap_left, top + 0.3, gap, 0.55)
    shape(slide, MSO_SHAPE.LEFT_ARROW, gap_left, top + 1.05, gap, 0.55)


def meter(slide, s):
    visual = s.visual
    bar_top, bar_height = 9.0, 0.7
    label(slide, CONTENT_LEFT, bar_top - 0.75, 6.0, 0.6, visual["caption"], LABEL_PT, align=PP_ALIGN.LEFT)
    ticks = [m["at"] for m in visual["markers"]]
    edges = [0.0] + ticks[1:] + [1.0]  # three segments between the marker points
    for start, end in zip(edges, edges[1:]):
        filled = end <= ticks[-1]
        shape(slide, MSO_SHAPE.RECTANGLE, CONTENT_LEFT + start * CONTENT_WIDTH, bar_top,
              (end - start) * CONTENT_WIDTH, bar_height, fill=ORANGE if filled else None)
    for marker in visual["markers"]:
        x = CONTENT_LEFT + marker["at"] * CONTENT_WIDTH
        shape(slide, MSO_SHAPE.RECTANGLE, x - 0.02, bar_top + bar_height, 0.04, 0.3, line=None, fill=BLACK)
        align = PP_ALIGN.LEFT if marker["at"] == 0 else PP_ALIGN.CENTER
        left = x if marker["at"] == 0 else x - 1.7
        label(slide, left, bar_top + bar_height + 0.3, 3.4, 0.6, marker["label"], LABEL_PT, MONO_FONT, align=align)


def cards(slide, s):
    count = len(s.visual["cards"])
    gap = 0.3
    width = (CONTENT_WIDTH - gap * (count - 1)) / count
    for index, card in enumerate(s.visual["cards"]):
        active = card["label"] == s.visual.get("highlight")
        x = CONTENT_LEFT + index * (width + gap)
        item = shape(slide, MSO_SHAPE.RECTANGLE, x, 7.6, width, 2.6, line=ORANGE if active else BLACK,
                     weight=ACCENT_LINE_PT if active else LINE_PT)
        write(item, [(card["label"].upper(), SMALL_PT, BODY_FONT, ORANGE if active else BLACK),
                     (card["text"], SMALL_PT + 2, BODY_FONT, BLACK)])


def steps(slide, s):
    count = len(s.visual["steps"])
    gap = 0.55
    width = (CONTENT_WIDTH - gap * (count - 1)) / count
    for index, text in enumerate(s.visual["steps"]):
        x = CONTENT_LEFT + index * (width + gap)
        shape(slide, MSO_SHAPE.RECTANGLE, x, 8.2, width, 1.7)
        badge = shape(slide, MSO_SHAPE.OVAL, x + 0.3, 8.65, 0.8, 0.8, line=None, fill=ORANGE)
        write(badge, [(str(index + 1), 28, BODY_FONT, BLACK)])
        label(slide, x + 1.2, 8.2, width - 1.3, 1.7, text, LABEL_PT, align=PP_ALIGN.LEFT)
        if index < count - 1:
            shape(slide, MSO_SHAPE.RIGHT_ARROW, x + width + 0.05, 8.85, gap - 0.1, 0.4, fill=BLACK, line=None)


VISUALS = {"pictograms": pictograms, "flow": flow, "cycle": cycle, "two-roles": two_roles, "meter": meter,
           "cards": cards, "steps": steps}
REQUIRED_KEYS = {"pictograms": (), "flow": ("labels", "highlight"), "cycle": ("labels", "highlight", "back"),
                 "two-roles": ("left", "right"), "meter": ("caption", "markers"), "cards": ("cards",),
                 "steps": ("steps",)}


def check_visual(visual):
    """Return an error message, or None when the [visual] table is usable."""
    kind = visual.get("kind")
    if kind not in VISUALS:
        return f"unknown visual kind {kind!r}"
    missing = [key for key in REQUIRED_KEYS[kind] if key not in visual]
    return f"visual {kind} lacks {', '.join(missing)}" if missing else None


def apply_visual(slide, slide_source):
    if slide_source.visual:
        VISUALS[slide_source.visual["kind"]](slide, slide_source)
