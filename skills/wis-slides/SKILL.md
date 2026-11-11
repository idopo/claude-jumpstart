---
name: wis-slides
description: Use when the user says "Weizmann slides", "WIS template", "make a deck for the institute" or asks for a presentation in the Weizmann look. Builds a branded .pptx from the official template with assertion titles.
---

Build a Weizmann-branded .pptx from the institute's official template, using the build in this repo (`deck/`).

## 1. Get the template

The official "Extended English presentation template", the Weizmann headline font and the logos come from the brand hub
https://wis.frontify.com/hub/2 (Weizmann login). Put them in `deck/brand/`:

- `deck/brand/WIS-extended-english-template.pptx`
- `deck/brand/assets-2/` (the Weizmann font, OTF)
- `deck/brand/assets-1/` (logos)

The folder is gitignored because the files are licensed. Never commit them, and never push a built deck to a public
remote: it embeds the font and brand art.

## 2. The one rule: titles are the bottom line

- Every title is an assertion a listener could repeat, not a topic label ("Get running", "Context").
- Read in order, the titles alone tell the talk.
- Titles are 5-16 words and at most 70 characters. The headline box holds two lines; the build stops with an error if a
  title needs more, so shorten the title.
- The body supports the title in 40 words or fewer (columns: 60). It never restates the title.
- Add a short illustration (a fenced block, 8 lines of 64 characters at most, 4 per deck) only when it teaches.

## 3. Which slide for what

The look lives in the template's 58 sample slides, not its layouts. The build duplicates one prototype sample slide per
layout, rewrites its text, then deletes all the samples.

| layout | template sample slide | use for |
|---|---|---|
| `title` | 3 (cream) | first slide; two bullets: subtitle, presenter |
| `divider` | 20 (black) | start of a part; no body |
| `statement` | 30 (cream) | one claim with 1-2 supporting bullets; with an illustration the leaf graphic goes and the text widens |
| `points` | 28 | a sequence of 2-4 steps, shown numbered |
| `boxes` | 25 | exactly three parallel options, bullets written `Label — line` |
| `columns` | 34 (light grey) | 2 or 3 `## Heading` groups, up to 6 bullets each |
| `closing` | 37 (black) | last slide; at least one bullet |

The first slide's title becomes the deck name in the header strip ("deck name · kicker").

## 4. Look

- Palette: cream `F8F2E9`, black `000000`, light grey `ECEDED`, orange accent `F26B43` used sparingly.
- Headlines: Weizmann, embedded in the template. Install the OTFs from `deck/brand/assets-2/` to see them locally.
- Body: Arial, as the stand-in for Benton Sans. Benton Sans is commercial and not supplied; in LibreOffice it falls back
  to a monospace font.
- Illustrations and code: Courier New.

## 5. Source format

One file per slide in a source folder, named `NN-slug.md` (two digits, lowercase, e.g. `02-three-ways.md`). Each file is
TOML front matter between two lines that are exactly `+++`, then the body:

```
+++
title = "Pick chat, Cowork or Code by how much control the task needs"
layout = "boxes"
kicker = "Three ways to work"
notes = '''
What you will say. Notes are required and may not be empty.
'''
+++

- Chat — you paste in, an answer comes back
- Cowork — works on your files in a cloud sandbox
- Code — your machine: files, terminal, git, plans
```

- `title`, `layout` and `notes` are required; `kicker` is optional (the part name in the header strip).
- Body lines are `- ` bullets, `## Heading` group lines (columns) and one fenced block per group (the illustration).
  Any other text line is an error. Backticks are stripped.
- Slides appear in file-name order. Any file in the folder with a bad name is an error.

## 6. Build and check

One-time setup, from the repo root:

```
docker build -t jumpstart-qa deck/qa
python3 -m venv deck/qa/venv && deck/qa/venv/bin/pip install "markitdown[pptx]==0.1.9" python-pptx==1.0.2 lxml defusedxml
```

The check also needs the Anthropic `pptx` skill (its `validate.py`); point `PPTX_SKILL` at it if it is not under
`~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/pptx`.

Build and check:

```
deck/qa/venv/bin/python -I deck/build.py --src my-deck/src --out my-deck/talk.pptx
deck/qa/check.sh my-deck/talk.pptx
deck/qa/venv/bin/python -I deck/qa/notes_equal.py my-deck/talk.pptx   # only for the repo's own deck/src
```

`--src` and `--out` default to `deck/src` and `deck/claude-jumpstart.pptx`; `--template` defaults to the file in
`deck/brand/`. The build prints `built <out>: N slides`.

A pass looks like: `All validations PASSED!` (checked against the template with `--original`), equal counts in
`readback: N slides, N notes blocks`, no placeholder text, and PNGs plus `grid.png` in `deck/qa/out/`. Open the PNGs and
look at every slide: text that is too small or runs into the footer only shows in the render.

## 7. Do and don't

- Do duplicate a sample slide (the build does) rather than draw the look.
- Do remove every unused sample text box; keep the logo, header strip and page number.
- Do validate with `--original` set to the template (check.sh does).
- Do look at every rendered slide.
- Don't use the fonts "Ezer Doo TRIAL ONLY" or "Weizmann BETA 5"; they appear in the samples.
- Don't leave Benton Sans on runs.
- Don't add accent bars or lines under titles.
- Don't put a wall of prompts or code on a slide.
- Don't let a title run past two lines; shorten it.

## 8. Where the code lives

`deck/build.py` (CLI and source parsing), `deck/wis_template.py` (prototype map, slide duplication) and
`deck/wis_fill.py` (per-layout fill). Copy the `deck/` folder without `brand/` binaries into a new project and fill
`deck/brand/` from the hub, or run from this clone with `--src` pointing at your own folder.
