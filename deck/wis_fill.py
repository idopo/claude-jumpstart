"""One fill function per layout: rewrite the text of a duplicated prototype slide (shape indices from the template).

Dark pages (title, dividers, closing) are structure; every other page is cream with the same header strip, title
position and size, and body start (see the shared geometry constants in wis_template).
"""
import copy

from pptx.dml.color import RGBColor

import wis_visuals
from wis_template import (BODY_TOP, CONTENT_LEFT, CONTENT_WIDTH, CREAM_HEX, HEADLINE_FONT, MONO_FONT, TITLE_PT,
                          TITLE_TOP, Para, headline, place, remove_shape, set_paragraphs, title_size)

BODY_PT = 28
COLUMN_BODY_PT = 28
SUBTITLE_PT = 30
KICKER_PT = 26
ORG_LABEL_PT = 22
CAPTION_GAP_PT = 18
ITEM_GAP_PT = 14
ILLUSTRATION_PT = 22
COLUMN_ILLUSTRATION_PT = 18
HEADING_PT = 24
CLOSING_TITLE_PT = 60
TITLE_SLIDE_PT = 60
DIVIDER_PT = 44
COLUMN_HEADING_TOP = BODY_TOP
COLUMN_BODY_TOP = BODY_TOP + 0.8


def strip_text(deck_name, kicker):
    return f"{deck_name} · {kicker}" if kicker else deck_name


def width_of(shape):
    return shape.width / 914400


def cream_page(slide, head, title, graphic=None):
    """Same background, title position/size and no decoration on every cream page."""
    cream = RGBColor.from_string(CREAM_HEX)
    slide.background.fill.solid()
    slide.background.fill.fore_color.rgb = cream
    # Some template masters (the columns sample's) paint a light-grey full-slide shape over the background.
    page_fill = slide.slide_layout.slide_master.shapes[0]
    page_fill.fill.solid()
    page_fill.fill.fore_color.rgb = cream
    if graphic is not None:
        remove_shape(graphic)
    place(head, left=CONTENT_LEFT, top=TITLE_TOP, width=CONTENT_WIDTH)
    headline(head, title, title_size(title, CONTENT_WIDTH, (TITLE_PT,)))


def fill_title(slide, s, deck_name):
    presenter, title, subtitle, _logo = list(slide.shapes)
    headline(title, s.title, TITLE_SLIDE_PT)
    set_paragraphs(subtitle, [Para(s.bullets[0], SUBTITLE_PT)])
    set_paragraphs(presenter, [Para(s.bullets[1], SUBTITLE_PT - 4)])


def fill_divider(slide, s, deck_name):
    shapes = list(slide.shapes)
    head, kicker = shapes[2], shapes[3]
    headline(head, s.title, title_size(s.title, width_of(head), (DIVIDER_PT,)))
    set_paragraphs(kicker, [Para(s.kicker or deck_name, KICKER_PT)])


def illustration_paras(lines, size):
    return [Para(line, size, MONO_FONT) for line in lines]


def fill_statement(slide, s, deck_name):
    shapes = list(slide.shapes)
    graphic, strip, body, head = shapes[0], shapes[2], shapes[5], shapes[6]
    set_paragraphs(strip, [Para(strip_text(deck_name, s.kicker), ORG_LABEL_PT)])
    cream_page(slide, head, s.title, graphic)
    place(body, left=CONTENT_LEFT, top=wis_visuals.body_top(s), width=CONTENT_WIDTH)
    if s.illustration:
        paras = illustration_paras(s.illustration, ILLUSTRATION_PT)
        paras += [Para(b, BODY_PT, space_before=CAPTION_GAP_PT) for b in s.bullets]
    else:
        paras = [Para(b, BODY_PT, space_before=0 if i == 0 else ITEM_GAP_PT) for i, b in enumerate(s.bullets)]
    set_paragraphs(body, paras)


def fill_points(slide, s, deck_name):
    shapes = list(slide.shapes)
    strip, head, body, other_body, other_head, sub = shapes[0], shapes[1], shapes[5], shapes[6], shapes[7], shapes[8]
    for shape in (other_body, other_head, sub):
        remove_shape(shape)
    set_paragraphs(strip, [Para(strip_text(deck_name, s.kicker), ORG_LABEL_PT)])
    cream_page(slide, head, s.title)
    place(body, left=CONTENT_LEFT, top=BODY_TOP, width=CONTENT_WIDTH)
    set_paragraphs(body, [Para(b, BODY_PT, space_before=0 if i == 0 else ITEM_GAP_PT, numbered=True)
                          for i, b in enumerate(s.bullets)])


def fill_boxes(slide, s, deck_name):
    """Headline page: the three boxes are drawn by the pictograms visual, so the prototype body is dropped."""
    shapes = list(slide.shapes)
    graphic, strip, body, head = shapes[0], shapes[2], shapes[5], shapes[6]
    set_paragraphs(strip, [Para(strip_text(deck_name, s.kicker), ORG_LABEL_PT)])
    cream_page(slide, head, s.title, graphic)
    remove_shape(body)


def fill_columns(slide, s, deck_name):
    shapes = list(slide.shapes)
    graphic, head, bodies, heading, strip = shapes[0], shapes[2], shapes[5:8], shapes[8], shapes[9]
    set_paragraphs(strip, [Para(strip_text(deck_name, s.kicker), ORG_LABEL_PT)])
    cream_page(slide, head, s.title, graphic)
    count = len(s.groups)
    xs, width = ((1.4, 11.2), 8.6) if count == 2 else ((1.3, 8.4, 15.2), 5.5)
    headings = [heading] + [_clone_after(heading) for _ in range(count - 1)]
    for index, group in enumerate(s.groups):
        place(headings[index], left=xs[index], top=COLUMN_HEADING_TOP, width=width)
        set_paragraphs(headings[index], [Para(group.heading, HEADING_PT, caps=True)])
        paras = [Para(b, COLUMN_BODY_PT, space_before=0 if i == 0 else 10) for i, b in enumerate(group.bullets)]
        if group.illustration:
            paras += illustration_paras(group.illustration, COLUMN_ILLUSTRATION_PT)
            paras[len(group.bullets)].space_before = 14
        place(bodies[index], left=xs[index], top=COLUMN_BODY_TOP, width=width)
        set_paragraphs(bodies[index], paras)
    for unused in bodies[count:]:
        remove_shape(unused)


def _clone_after(shape):
    clone = copy.deepcopy(shape._element)
    shape._element.addnext(clone)
    return next(sh for sh in shape.part.slide.shapes if sh._element is clone)


def fill_closing(slide, s, deck_name):
    shapes = list(slide.shapes)
    title, strip = shapes[0], shapes[1]
    paras = [Para(s.title, CLOSING_TITLE_PT, HEADLINE_FONT)]
    if len(s.bullets) > 1:
        paras.append(Para(s.bullets[1], SUBTITLE_PT, space_before=10))
    set_paragraphs(title, paras)
    set_paragraphs(strip, [Para(s.bullets[0], ORG_LABEL_PT)])


FILLERS = {"title": fill_title, "divider": fill_divider, "statement": fill_statement, "points": fill_points,
           "boxes": fill_boxes, "columns": fill_columns, "closing": fill_closing}
