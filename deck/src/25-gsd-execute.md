+++
title = "Execute, verify, and keep the summaries: they are the project's memory"
layout = "points"
kicker = "Big work, with control"
notes = '''
`/gsd-execute-phase` runs the plans wave by wave. Each plan gets its own subagent with fresh context, makes one commit per task and writes a SUMMARY when it is done. Your own session stays small, so a long project does not degrade.
Some tasks are checkpoints: open the figure and confirm it looks right, or pick between two options. Execution stops and waits for you.
`/gsd-verify-work` is an acceptance test you do in conversation: does it do what the phase promised?
Execute and verify is the loop closed by evidence. Each plan carries checks it must pass; verify-work is you checking the result against what the phase promised. When something fails, the fix is one more small loop, not a restart: a quick task, a commit, a line in the SUMMARY.
Example: verify-work asked "open figures/rt_361.png; are the sessions in date order?" They were not. One `/gsd-quick` fixed the sort, and the SUMMARY records why the order was wrong, so it never comes back.
The summaries and STATE are the project's memory. After a break, `/gsd-progress` reads them and tells you the next command. Stopping mid-phase: `/gsd-pause-work`, and the next day `/gsd-resume-work`.
And when someone asks in six months how a number was made, the SUMMARY has the answer.
Bridge: That is the whole system: prompt, plan, loop, undo, fresh context, memory on disk. Now take it home.
Fact: "Subagents run in their own context; only the summary returns." (FACTS_VERIFIED, Context)
Source: docs/GSD_GUIDE.md (orchestrator stays lean, §4 execute-phase and checkpoints, /gsd-progress, pause and resume)
'''

[visual]
kind = "steps"
steps = ["execute", "verify", "SUMMARY + STATE"]
+++

- `/gsd-execute-phase`: each plan in a fresh subagent; checkpoints wait for you
- `/gsd-verify-work`: you check what was built, in conversation
- Each plan leaves a SUMMARY; `/gsd-progress` finds your place after a break
