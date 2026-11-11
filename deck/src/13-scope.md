+++
title = "Say what not to do, and ask for the code behind every number"
layout = "statement"
kicker = "Keep the science yours"
notes = '''
From my experience, not a docs fact: models over-deliver. You ask for one thing and get three, and the two you did not ask for are scientific decisions: which data are in, what counts as an outlier, whether a difference is significant.
Example: I asked for one more column in the per-session table. It also excluded two sessions as outliers and added a p-value. Neither was asked for; both would have gone straight into a figure, and a reviewer would have asked me to defend a rule I never chose.
Two habits.
Scope it. Say what not to do: "do only X; change nothing else". Make it stop and ask before it changes the question, the inclusion rule, or which data are in or out. The sentence "ask me before excluding any session" belongs in your CLAUDE.md; that is slide twenty.
See the evidence. Ask for the code and the output behind every number. "Print the per-session means" costs one line and lets you check them against the spreadsheet. A number you did not see computed is not a result.
Example: "Which sessions did you drop, and why?" is the question to ask after any analysis step. If the answer surprises you, undo it; that is part two.
Take-home: templates/rules/keep-the-science-yours.md puts these rules in every session.
Bridge: Keeping the science yours also means keeping Claude's working memory in shape. That memory is called context, and the next four slides are about it, because most quiet failures start there.
'''

[visual]
kind = "cards"
highlight = "You asked"
cards = [
  { label = "You asked", text = "one more column" },
  { label = "It added", text = "two sessions dropped" },
  { label = "It added", text = "a p-value" },
]
+++

- Over-delivery looks like help: a dropped outlier, a p-value you never asked for
- Say "do only X"; make it ask before changing what is in or out
- A number you did not see computed is not a result
