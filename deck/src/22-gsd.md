+++
title = "GSD writes big work as plans on disk; you review them before they run"
layout = "points"
kicker = "Big work, with control"
notes = '''
GSD is a planning layer on Claude Code. A phase is one broad topic, divided into plans small enough to execute; plans that touch different files can run in parallel.
Discuss: say what you want and what you do not. Planning starts from those decisions and from research: an agent reads the codebase and docs. Plans go into `.planning/`. You read and challenge each one; GSD replans, and a plan checker verifies it before anything runs.
Execute: each plan runs in a subagent with fresh context. Verify-work checks what was built.
Every plan ends in a SUMMARY on disk, which pays off: it answers questions about what was done, gives the next session context, keeps you in control of what changed, and is where you start to extend a finished task.
Example phase: "preprocessing" of the reaction-time pipeline: load the CSVs, clean, per-session means. Three plans, each a handful of files; the third depends on the first two, so the first two run side by side and the third waits.
Why it beats one long session: a long session degrades, as part three showed. GSD never has one. Each plan starts fresh, reads the SUMMARY of what came before, and leaves its own.
The lab installs GSD Core; the /gsd-* commands shown are the same family.
This slide is never cut.
Bridge: How do you start one?
Cut 2: if 23-gsd-start is skipped, end here with "/gsd-new-project starts a project with questions and ends with a roadmap of phases."
Fact: "Subagents run in their own context; only the summary returns." (FACTS_VERIFIED, Context)
Source: docs/GSD_GUIDE.md (core loop; researcher reads codebase and docs; plan-checker loops until the plan passes; waves run plans in parallel; executor writes SUMMARY.md)
Take-home: docs/GSD_GUIDE.md.
'''

[visual]
kind = "flow"
labels = ["discuss", "plan", "challenge", "execute", "verify"]
highlight = "challenge"
top = 8.8
+++

- `/gsd-discuss-phase`: what you want and what you do not
- `/gsd-plan-phase`: plans in `.planning/`; you read and challenge them
- Then GSD replans and a checker verifies it
- `/gsd-execute-phase`; `/gsd-verify-work` checks it; every plan ends in a SUMMARY
