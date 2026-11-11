"""Weizmann template mechanics: duplicate sample slides, rewrite their text, drop the samples.

The template's look lives in its 58 sample slides (their own text boxes and pictures), not in layouts, so each
output slide is a deep copy of a prototype sample slide whose text is replaced.
"""
import copy
from dataclasses import dataclass

from lxml import etree
from pptx.oxml.ns import qn

HEADLINE_FONT = "Weizmann"
BODY_FONT = "Arial"  # stand-in: Benton Sans is commercial, not supplied, and renders as a monospace fallback
MONO_FONT = "Courier New"
EMU_PER_INCH = 914400
CHAR_WIDTH_EM = 0.5  # average glyph width / font size, used for the title-fit estimate
TITLE_LINES = 2
TEXT_INSET_IN = 0.2

# layout -> 1-based sample slide number in the template
PROTOTYPES = {"title": 9, "divider": 20, "statement": 30, "points": 28, "boxes": 30, "columns": 34,
              "closing": 37}

# Shared geometry (inches) so every cream page has the same title, body and content area.
CONTENT_LEFT = 1.46  # aligns with the header strip edges
CONTENT_WIDTH = 19.05
TITLE_TOP = 2.5
TITLE_PT = 44
BODY_TOP = 4.5
CONTENT_BOTTOM = 10.8  # the footer line sits just below
CREAM_HEX = "F8F2E9"


@dataclass
class Para:
    text: str
    size: float | None = None  # pt; None keeps the prototype run size
    font: str = BODY_FONT
    space_before: float | None = None  # pt
    numbered: bool = False
    caps: bool = False


def title_lines(title, width_in, size):
    per_line = max(1, int((width_in - TEXT_INSET_IN) * 72 / (size * CHAR_WIDTH_EM)))
    lines, used = 1, 0
    for word in title.split():
        need = len(word) + (1 if used else 0)
        if used + need > per_line and used:
            lines, used = lines + 1, len(word)
        else:
            used += need
    return lines


def title_size(title, box_width_in, sizes=(50, 44, 40)):
    for size in sizes:
        if title_lines(title, box_width_in, size) <= TITLE_LINES:
            return size
    raise ValueError(f"title needs more than {TITLE_LINES} lines at {sizes[-1]} pt: {title!r}")


def _a(tag):
    return qn(f"a:{tag}")


def _set_typeface(rpr, font):
    for tag in ("latin", "ea", "cs"):
        for old in rpr.findall(_a(tag)):
            rpr.remove(old)
    for tag in ("latin", "cs"):
        etree.SubElement(rpr, _a(tag)).set("typeface", font)


def _style_ppr(ppr, para):
    if ppr.find(_a("lnSpc")) is not None and para.size:
        spacing = ppr.find(_a("lnSpc"))[0]
        if spacing.tag == _a("spcPts"):
            spacing.set("val", str(int(para.size * 100)))
    if para.font == MONO_FONT:
        for old in ppr.findall(_a("lnSpc")):
            ppr.remove(old)
        spacing = etree.Element(_a("lnSpc"))
        etree.SubElement(spacing, _a("spcPct")).set("val", "100000")
        ppr.insert(0, spacing)
    if para.space_before is not None:
        for old in ppr.findall(_a("spcBef")):
            ppr.remove(old)
        before = etree.Element(_a("spcBef"))
        etree.SubElement(before, _a("spcPts")).set("val", str(int(para.space_before * 100)))
        anchor = ppr.find(_a("lnSpc"))
        ppr.insert(0 if anchor is None else list(ppr).index(anchor) + 1, before)
    if para.numbered:
        ppr.set("marL", "571500")
        ppr.set("indent", "-571500")
        etree.SubElement(ppr, _a("buFont")).set("typeface", BODY_FONT)
        etree.SubElement(ppr, _a("buAutoNum")).set("type", "arabicPeriod")


def set_paragraphs(shape, paras):
    """Replace a text box's paragraphs; each new run clones the prototype's first run so colour/spacing survive."""
    body = shape._element.txBody
    first_p = body.findall(_a("p"))[0]
    base_ppr = first_p.find(_a("pPr"))
    base_rpr = first_p.find(f"{_a('r')}/{_a('rPr')}")
    if base_rpr is None:
        base_rpr = etree.Element(_a("rPr"))
    for old in body.findall(_a("p")):
        body.remove(old)
    for para in paras:
        p = etree.SubElement(body, _a("p"))
        ppr = copy.deepcopy(base_ppr) if base_ppr is not None else etree.Element(_a("pPr"))
        p.append(ppr)
        _style_ppr(ppr, para)
        run = etree.SubElement(p, _a("r"))
        rpr = copy.deepcopy(base_rpr)
        for attr in ("spc", "dirty", "b", "i"):
            rpr.attrib.pop(attr, None)
        if para.size:
            rpr.set("sz", str(int(para.size * 100)))
        _set_typeface(rpr, para.font)
        run.append(rpr)
        etree.SubElement(run, _a("t")).text = para.text.upper() if para.caps else para.text


def headline(shape, text, size):
    set_paragraphs(shape, [Para(text, size, HEADLINE_FONT)])


def remove_shape(shape):
    shape._element.getparent().remove(shape._element)


def place(shape, left=None, top=None, width=None):
    if left is not None:
        shape.left = int(left * EMU_PER_INCH)
    if top is not None:
        shape.top = int(top * EMU_PER_INCH)
    if width is not None:
        shape.width = int(width * EMU_PER_INCH)


_REL_NS = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}"


def _remap_rids(element, rid_map):
    for node in element.iter():
        for name, value in list(node.attrib.items()):
            if name.startswith(_REL_NS) and value in rid_map:
                node.set(name, rid_map[value])


def duplicate_slide(prs, source):
    """Append a copy of `source` (shapes, background, picture/hyperlink relationships) to the presentation."""
    new = prs.slides.add_slide(source.slide_layout)
    tree = new.shapes._spTree
    for child in list(tree)[2:]:  # keep nvGrpSpPr and grpSpPr
        tree.remove(child)
    rid_map = {}
    for rid, rel in source.part.rels.items():
        if rel.reltype.endswith(("/slideLayout", "/notesSlide")):
            continue
        if rel.is_external:
            rid_map[rid] = new.part.relate_to(rel.target_ref, rel.reltype, is_external=True)
        else:
            rid_map[rid] = new.part.relate_to(rel.target_part, rel.reltype)
    for child in list(source.shapes._spTree)[2:]:
        clone = copy.deepcopy(child)
        _remap_rids(clone, rid_map)
        tree.append(clone)
    src_bg = source._element.cSld.find(qn("p:bg"))
    if src_bg is not None:
        bg = copy.deepcopy(src_bg)
        _remap_rids(bg, rid_map)
        new._element.cSld.insert(0, bg)
    return new


def set_slide_number(slide, number):
    for field in slide._element.iter(_a("fld")):
        if field.get("type") == "slidenum":
            text = field.find(_a("t"))
            if text is not None:
                text.text = str(number)


def sample_slide_ids(prs):
    return list(prs.slides._sldIdLst)


def remove_sample_slides(prs, sample_ids):
    for slide_id in sample_ids:
        prs.part.drop_rel(slide_id.rId)
        prs.slides._sldIdLst.remove(slide_id)
