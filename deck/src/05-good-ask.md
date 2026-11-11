+++
title = "A good prompt names goal, files, limits and what done means"
layout = "points"
kicker = "Prompt well, plan first"
notes = '''
Most bad results come from bad prompts, not a bad model.
Start with the goal in one sentence. Then point it at the files by path instead of describing them.
Say what it must not touch.
Say what done looks like: something you can see or check. Never just "fix it"; say what fixed means: the figure has error bars, the number matches the spreadsheet.
Tell it to ask you questions before it starts; it finds the gaps you missed. And one task per message.
Example, said aloud, the running example: "Goal: a figure of mean reaction time per session for mouse 361. Data: data/sessions/*.csv, one file per session, column rt_ms. Do not touch the raw files or anything under analysis/old. Done means figures/rt_361.png with error bars, and the per-session means printed so I can check them against my spreadsheet. Ask me anything unclear before you start." Five sentences; each one closes a door the model would otherwise walk through.
Example of the opposite: "plot the reaction times". Which file, which mouse, what on the x axis, what counts as done? It will guess all four.
When it drifts, press Esc. After two failed corrections, do not try a third: `/clear` and write a better prompt.
Bridge: A good prompt is enough for a small job. For a big one it is not: make it plan first.
Fact: "Press Esc the moment it" (FACTS_VERIFIED, Context)
Fact: "after two failed corrections, `/clear` and write a better prompt instead of a third." (FACTS_VERIFIED, Context)
'''
+++

- Point at files by path, not description
- Say what it must not touch
- Say how you will check it worked
- Tell it to ask you questions first
