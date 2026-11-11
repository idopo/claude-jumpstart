# Weizmann Institute brand assets (from https://wis.frontify.com/hub/2, downloaded by Ido 2026-11-01)

Contents (large binaries are gitignored; Ido keeps the originals):
- `WIS-extended-english-template.pptx` — the official "Extended English presentation template", 58 sample slides,
  16:9 (sldSz 20105688 x 11310938 EMU = 21.9 x 12.3 in; wider than pptxgenjs LAYOUT_16x9).
  - slides 01-17: title-slide variants (photo / orange-blob / cream / black / grey; logo top-left in a box)
  - slides 18-21: section dividers ("Slide Divider", Weizmann Regular 60pt)
  - slides 22-27: black or cream content pages with 1-2 body columns and "box text" rows (Benton Sans 36pt)
  - slides 28-36: "Slide Headline" content pages (Weizmann Regular 50pt headline, Benton Sans 22pt body,
    optional subheading 26pt, photo variants), page number bottom right, footer "Presentation Title" top
  - slides 37-41: "Thank you" closers; slides 42-58: decorative backgrounds (petal / leaf / starburst patterns)
- `assets-2/` — the Weizmann headline font, OTF, 4 weights (Light / Regular / Medium / Bold).
- `assets-1/logos/` — full logo pack: horizontal, square, 3 variations; black / dark / light / white; svg, png, jpg, pdf, ai.

Palette found in the template masters/layouts (sRGB): cream `F8F2E9` (background), black `000000` / `12100B` /
`1D1D1B` (text, dark backgrounds), light grey `ECEDED`, orange accent `F26B43`. Theme 29 ("Custom Design") is the
real one: lt1/lt2 `F9F5EA`, dk1/dk2 `000000`. The other 28 masters are stock Office themes carried by sample slides.

Fonts: headlines **Weizmann** (OTF supplied; 7 fonts are also embedded in the pptx as .fntdata), body **Benton Sans**
(commercial, NOT supplied; the theme falls back to Calibri — the render container needs a stand-in).
Sample slides also reference "Ezer Doo TRIAL ONLY" and "Weizmann BETA 5" — do not use.

How to build and check (from the repo root):
- `deck/qa/venv/bin/python -I deck/build.py` renders deck/src into deck/claude-jumpstart.pptx (untracked: it embeds the licensed font and brand art).
- `deck/qa/check.sh deck/claude-jumpstart.pptx` validates against this template (`--original`), reads the deck back, and renders PNGs plus grid.png in Docker with assets-2 mounted as a font dir.
- `deck/qa/venv/bin/python -I deck/qa/notes_equal.py deck/claude-jumpstart.pptx` compares slide notes with the sources.

The look lives in the template's sample slides, not its layouts, so build.py duplicates a prototype sample slide per
source layout (shapes, background, picture relationships), rewrites its text through the prototype's own runs, then
drops all 58 samples. Prototype map (1-based sample slide numbers): title 9 (black), divider 20, statement 30, points 28,
boxes 30 (drawn by deck/wis_visuals.py), columns 34, closing 37. Dark pages are only title, dividers, closing; every other page is cream with the leaf graphic removed, same strip, title and body start. Illustrations come from a `[visual]` table in the slide front matter (kinds: `pictograms`, `flow`, `cycle` = a flow with an orange return arrow carrying `back`, `two-roles`, `meter`, `cards`, `steps`);
points use one numbered column; columns use 2 wide or 3 narrow columns; the header strip shows "<deck name> · <kicker>".

Fonts: headlines keep the embedded Weizmann face (mounted in the QA render); body text is Arial, the stand-in for Benton
Sans (not supplied; fontconfig renders it as a monospace fallback); illustrations are Courier New. No new font is embedded. After the save, deck/wis_fonts.py remaps the template's two unused faces ("Ezer Doo TRIAL ONLY" → Arial, "Weizmann BETA 5" → Weizmann) and drops their embedded copies, so PowerPoint on a clean machine reports no missing fonts.
