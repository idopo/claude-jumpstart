+++
title = "Let it loop against a check: plan, verify, fix, at most three rounds"
layout = "statement"
kicker = "Prompt well, plan first"
notes = '''
The best results I get do not come from one prompt, however good. They come from loops where Claude checks its own work and fixes it, and the loop has a cap.
Three parts. A check it can run itself: a test, a validator, a plan reviewer, a comparison against a known number. An instruction to fix and rerun until the check passes. And a cap: at most three rounds, then stop and report. Without the cap a loop can run for an hour chasing a problem the check cannot express; with it, you get either a passing result or a short report of what is still wrong.
Why it works: each round gives the model evidence, not opinion. A failing test says exactly what is wrong; a reviewer agent says what is missing. Reacting to evidence is what it does best, and a check it runs itself is cheaper and more honest than your eye.
Your own corrections, on the last three slides, are the manual version of the same loop. This is the automated one.
Example: "Run the tests. Fix what fails and run them again. Stop after three rounds and tell me what is still failing." Three lines, and an afternoon of back and forth becomes one message.
Example: "Make the figure, then check it against this list: sessions in date order, SEM bars, the means printed. Fix and rerun until all three hold, at most three times."
Example, the one you will meet in part four: GSD plans a phase with a planner agent and a checker agent that reviews the plan against the goal; if the checker finds gaps, the planner revises, up to three times. You see only the plan that passed, or the three issues that remained.
Bridge: Loops like these only feel safe if a bad round costs nothing, and that is part two: a way back.
Source: docs/GSD_GUIDE.md (plan-checker revision loop, at most three iterations)
'''

[visual]
kind = "cycle"
labels = ["do", "check", "fix"]
highlight = "check"
back = "again, at most three times"
+++

- Give it a check it can run itself: a test, a validator, a plan reviewer
- Say: fix and rerun until it passes, at most three rounds
- GSD does this for you: planner and checker loop until the plan passes
