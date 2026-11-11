+++
title = "For anything big, make Claude plan first, then challenge the plan"
layout = "statement"
kicker = "Prompt well, plan first"
notes = '''
Even a good prompt goes wrong on a big task. For anything big, make it plan first.
Shift+Tab cycles the permission modes: auto, default, acceptEdits, plan. New terminal sessions start in auto on a current Claude Code.
Plan mode reads and proposes; it edits nothing until you approve. `/plan` with a description does the same.
My rule of thumb, not a docs rule: more than about three files gets a plan.
Then read the plan and challenge it. A challenge makes it reason again, and the plan usually changes. "What did you add that I did not ask for?" pays the most.
Example: for the reaction-time pipeline the plan included a step that drops trials over two seconds as outliers. I never asked for that. One question, "what did you add that I did not ask for?", and it named the step itself; the plan lost it. Had it run, that rule would have been in every figure.
Example of challenges that work: "why this order?", "what breaks if step 3 fails?", "which of these steps could you skip?".
When you approve, "Yes, manually approve edits" lets you see each change as it happens.
Bridge: In the terminal a long plan scrolls away. I read it as a page instead.
Fact: "`Shift+Tab` cycles auto → default → acceptEdits → plan" (FACTS_VERIFIED, Permission modes)
Fact: "New terminal sessions start in auto mode on Claude Code 2.1.283 or later" (FACTS_VERIFIED, Permission modes)
Fact: "`/plan [description]`" (FACTS_VERIFIED, Permission modes)
Fact: "Yes, manually approve edits" (FACTS_VERIFIED, Permission modes)
Cut 4: if 07-plan-artifact is skipped, end here with "I ask for the plan as an artifact, a page I can read and challenge."
'''

[visual]
kind = "flow"
labels = ["Prompt", "Plan", "Challenge", "Execute"]
highlight = "Challenge"
+++

- Plan mode (Shift+Tab) reads and proposes; it edits nothing until you approve
- My rule: more than about three files gets a plan
- Challenge it: why this? What did you add that I did not ask for?
