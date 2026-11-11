+++
title = "Pick chat, Cowork or Code by how much control the task needs"
layout = "boxes"
kicker = "Three ways to work"
notes = '''
There are three ways to work with Claude, from least to most control.
Chat: you paste something in and an answer comes back. Nothing runs on your machine; files come back as downloads.
Cowork: Claude works on your folders and files, and it does run code, in its own sandbox, in the cloud by default. It is no longer a separate mode; it is part of Claude on paid plans.
Code: Claude in a terminal on your own machine, with your real files, git, plans, CLAUDE.md and your own skills. Cowork has no terminal for you, and git is not a documented feature there.
All three draw on one shared usage pool, and Code and Cowork spend it much faster than chat.
Inside Code, `/model` picks the model and remembers it. Opus is the default, for complex reasoning. Fable is for the hardest and longest-running jobs, and on some plans it bills to usage credits.
Example: chat: paste a methods paragraph, get it tightened. Cowork: point it at a folder of PDFs, get a summary table back as a spreadsheet. Code: the reaction-time figure as a script in your own folder, under git, that you rerun on next week's data.
The rest of this talk is about Code.
Bridge: So why would a scientist pick the one with a terminal? Because of what it leaves behind.
Fact: "server-side ephemeral filesystem," (FACTS_VERIFIED, Cowork vs Code vs chat)
Fact: "**Cowork is no longer a separate mode.** 2026-09-16:" (FACTS_VERIFIED, Cowork vs Code vs chat)
Fact: "**Cowork does run code**: each session gets its own sandbox" (FACTS_VERIFIED, Cowork vs Code vs chat)
Fact: "**Documented gaps vs Code**: no terminal for the user; git inside Cowork not documented" (FACTS_VERIFIED, Cowork vs Code vs chat)
Fact: "**Rate limits are one shared pool** across chat, Cowork and Code" (FACTS_VERIFIED, Cowork vs Code vs chat)
Fact: "consume tokens at a significantly higher rate than standard" (FACTS_VERIFIED, Cowork vs Code vs chat)
Fact: "`/model` saves the choice as default for new sessions" (FACTS_VERIFIED, Models)
Fact: "Default on Pro/Max/Team/Enterprise is Opus 5.5." (FACTS_VERIFIED, Models)
Fact: "complex reasoning" (FACTS_VERIFIED, Models)
Fact: "hardest and longest-running tasks" (FACTS_VERIFIED, Models)
Fact: "Fable bills to usage credits instead of the included limits" (FACTS_VERIFIED, Models)
Cut 3: if 03-not-just-code is skipped, end here with "Code is not just for coding: your expertise is what makes it useful."
'''

[visual]
kind = "pictograms"
+++

- Chat — you paste in, an answer comes back
- Cowork — works on your files in its own sandbox
- Code — your machine: files, terminal, git, plans
