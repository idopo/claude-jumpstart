+++
title = "Teach your lab once: CLAUDE.md for how you work, skills for routines"
layout = "columns"
kicker = "Keep the science yours"
notes = '''
If context is working memory, these are long-term memory.
CLAUDE.md: one global file for how you work, one per project for its commands, conventions and gotchas. Let `/init` draft it, then prune. Keep it under 200 lines; it loads into context every session, as we saw. For anything Claude keeps re-learning, such as your data format, write a `docs/<topic>.md` and link it by path.
Example lines from a lab CLAUDE.md: "Data: data/sessions/*.csv, one file per session, times in ms. Never modify anything under data/raw. Figures go to figures/, named by analysis and subject. Run tests with pytest -q. Ask before excluding any session." Twenty lines like these replace the same explanation in every session, and the outlier rule from part three is now enforced before you type a word.
Skills: a procedure that loads when the situation matches its description. The description is always in context; the body loads only when needed.
The excerpt is real: the wis-slides skill in the repo, and this very deck was built with it. Where the official template lives, the title rule and the build command sit in one file, so the next deck starts from the same place. It is a skill, not a prompt, because it is a repeated procedure with a trigger: say "Weizmann slides" and it loads.
Example of a lab skill: "session report": given a session CSV, produce the same six plots and a summary table, every time, in the same order. Anyone in the lab types one line and gets the lab's report.
Write your own for your lab's routines.
Bridge: Part four: everything so far, run as one system.
Fact: "target under 200 lines" (FACTS_VERIFIED, CLAUDE.md and memory)
Fact: "`/init` creates it from the codebase; if one exists it suggests improvements." (FACTS_VERIFIED, CLAUDE.md and memory)
Fact: "`description` drives auto-triggering" (FACTS_VERIFIED, Skills)
Fact: "context, the body loads on invocation." (FACTS_VERIFIED, Skills)
Source: captures/06-wis-slides-skill.txt (real excerpt of skills/wis-slides/SKILL.md, trimmed to 6 lines)
Fallback: read the trigger, the template path and the title rule aloud.
'''
+++

## CLAUDE.md
- Global: who you are, how you work
- Per project: commands, conventions, gotchas
- `/init` drafts it, you prune it; under 200 lines

## Skills
- A procedure that loads when its description matches
- A repeated procedure with a trigger; this deck used one

```
description: Use when the user says
  "Weizmann slides", "WIS template" […]
deck/brand/WIS-extended-english-template.pptx
points: a sequence of 2-4 steps, shown numbered
Every title is an assertion a listener could repeat
deck/qa/venv/bin/python -I deck/build.py […]
```
