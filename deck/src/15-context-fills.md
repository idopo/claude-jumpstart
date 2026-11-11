+++
title = "Context fills fast: one big file can outweigh all you have typed"
layout = "statement"
kicker = "Keep the science yours"
notes = '''
Your typing is the smallest part. You might type two thousand words in an hour. One CSV read in full can be fifty thousand tokens. A verbose test run, a long log, a search that matches a thousand lines: each lands in context and stays there.
What fills it, roughly in order: files it reads whole; command output, above all tests and logs; long documents you paste in; and the fixed cost at the start of every session: CLAUDE.md, rules, skill descriptions. Imports inside CLAUDE.md are expanded into context; they organise, they do not save anything. That is why the docs say keep CLAUDE.md under 200 lines: a longer file costs context on every single session and reduces adherence.
Example: a student pasted a 300-page protocol "for background". The session was half full before the first question. Better: put the PDF in the project and ask Claude to read the two sections that matter, or send a subagent to summarise it; more on subagents in two slides.
Example: "run the tests" with a chatty test runner: four thousand lines of output, once per fix, five fixes. Ask for the failures only, and the same work costs a tenth.
Example: "look through the data folder" when the folder has two hundred CSVs. Name the two files you mean.
From my experience, not a docs fact: in an analysis session, reading data and running things fills context about ten times faster than the conversation does.
Bridge: A full context is not a crash. It is a slow slide, and you can see it coming.
Fact: "they do **not** reduce cost, they organise." (FACTS_VERIFIED, CLAUDE.md and memory)
Fact: "Longer files consume more context and reduce" (FACTS_VERIFIED, CLAUDE.md and memory)
Fact: "target under 200 lines" (FACTS_VERIFIED, CLAUDE.md and memory)
'''

[visual]
kind = "cards"
highlight = "Files"
cards = [
  { label = "Files", text = "read whole" },
  { label = "Output", text = "tests and logs" },
  { label = "Pasted", text = "long documents" },
  { label = "Every session", text = "CLAUDE.md and rules" },
]
+++

- Files read whole and test or log output are the big items
- Pasted documents stay for the whole session
- CLAUDE.md and rules load every session: keep them under 200 lines
