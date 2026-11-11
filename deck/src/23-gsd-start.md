+++
title = "Start a GSD project as a conversation, not a spec, then let it roadmap"
layout = "points"
kicker = "Big work, with control"
notes = '''
You do not write a spec. `/gsd-new-project` asks you questions until it understands what you want, can research the field with parallel agents, then writes the requirements and a roadmap of phases for you to approve.
After that, `.planning/` holds the four files that carry the project: PROJECT, what and why; REQUIREMENTS, what counts as done; ROADMAP, the phases; STATE, where you are, with decisions and blockers. Claude rereads them every session, so it never has to remember.
A phase is one broad topic: the preprocessing of an analysis pipeline, or reward delivery in a rig control project. Not a single task; the plans inside it are the tasks.
Example: "I want a pipeline from the session CSVs to the figures in my paper." It asks: which figures, which subjects, where the data lives, what counts as done, what must never change. Twenty minutes of questions, then a roadmap: load and clean, per-session metrics, figures, a report. You approve the roadmap, or argue with it; that is a loop too.
If the code already exists, run `/gsd-map-codebase` first, so the roadmap knows your stack.
Bridge: Then one phase at a time, and this is where the loop from part one comes back in full.
Source: docs/GSD_GUIDE.md (§2 first session, §3 mental model and core loop, §5 existing project)
Cut 2: this slide is skipped second; its line is said at the end of 22-gsd.
'''

[visual]
kind = "cards"
cards = [
  { label = "PROJECT", text = "what and why" },
  { label = "REQUIREMENTS", text = "what counts as done" },
  { label = "ROADMAP", text = "the phases" },
  { label = "STATE", text = "where you are" },
]
+++

- `/gsd-new-project`: it asks questions, researches, then writes a roadmap
- A phase is one broad topic, like the preprocessing of a pipeline
- Code already exists? Run `/gsd-map-codebase` first
