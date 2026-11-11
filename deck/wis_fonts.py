"""Drop the template's unused embedded fonts from a built deck.

The Weizmann template embeds two faces the deck never shows: "Ezer Doo TRIAL ONLY" (the masters' Hebrew text
style) and "Weizmann BETA 5" (an older headline build). PowerPoint on a machine without them reports missing fonts,
so after the build every reference is remapped and the embedded copies are removed.
"""
import re
import shutil
import tempfile
import zipfile

TEMPLATE_ONLY_FONTS = {"Ezer Doo TRIAL ONLY": "Arial", "Weizmann BETA 5": "Weizmann"}
PRESENTATION = "ppt/presentation.xml"
PRESENTATION_RELS = "ppt/_rels/presentation.xml.rels"


def _embedded_font_ids(presentation_xml):
    """Relationship ids of the embedded font files that belong to the template-only faces."""
    ids = []
    for face in TEMPLATE_ONLY_FONTS:
        for block in re.findall(rf'<p:embeddedFont><p:font typeface="{re.escape(face)}".*?</p:embeddedFont>',
                                presentation_xml, flags=re.S):
            ids += re.findall(r'r:id="(rId\d+)"', block)
    return ids


def _font_targets(rels_xml, ids):
    return [m for rid in ids for m in re.findall(rf'<Relationship Id="{rid}"[^>]*Target="([^"]+)"', rels_xml)]


def strip_unused_template_fonts(pptx_path):
    """Rewrite the deck in place: remap the template-only typefaces and remove their embedded font parts."""
    with zipfile.ZipFile(pptx_path) as source:
        presentation = source.read(PRESENTATION).decode("utf8")
        ids = _embedded_font_ids(presentation)
        drop = {"ppt/" + t for t in _font_targets(source.read(PRESENTATION_RELS).decode("utf8"), ids)}
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pptx") as tmp:
            with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as target:
                for item in source.infolist():
                    if item.filename in drop:
                        continue
                    data = source.read(item.filename)
                    if item.filename.endswith((".xml", ".rels")):
                        text = data.decode("utf8")
                        for face, replacement in TEMPLATE_ONLY_FONTS.items():
                            text = re.sub(rf'<p:embeddedFont><p:font typeface="{re.escape(face)}".*?</p:embeddedFont>',
                                          "", text, flags=re.S)
                            text = text.replace(f'typeface="{face}"', f'typeface="{replacement}"')
                        for rid in ids:
                            text = re.sub(rf'<Relationship Id="{rid}"[^>]*/>', "", text)
                        data = text.encode("utf8")
                    target.writestr(item, data)
    shutil.move(tmp.name, pptx_path)
