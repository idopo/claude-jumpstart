+++
title = "Context is everything Claude can see right now, and it fills up"
layout = "statement"
kicker = "Keep the science yours"
notes = '''
Context is everything Claude can see right now: this conversation, every file it opened, every command output, your CLAUDE.md, the descriptions of your skills. All of it is sent again with every reply. Nothing drops out until you clear or compact.
It is large but finite: current models run with a one-million-token window. A token is roughly three quarters of a word; that is a rule of thumb, not a docs figure. A million sounds infinite. The next slide shows how fast it goes.
Two things to hold on to. One: Claude does not remember between sessions. Context is the whole memory, and a new session starts empty, apart from CLAUDE.md and whatever it is told to read. Two: context is not free. Everything in it is reread for every answer, so more context means slower answers and, from my experience, worse ones. "Context rot" is our nickname for that, not an Anthropic term.
Example: ask "what did we decide about outliers?" in a fresh session and it has no idea. In the long session it answers at once. The only difference is what is in context.
Example: it read data/sessions/2026-03-04.csv in full an hour ago to check a column name. That whole file is still in the window, and will be until you clear.
Bridge: What fills it, and how fast?
Fact: "run with a 1M window by default" (FACTS_VERIFIED, Context)
Fact: "is **not** an Anthropic term. Use it as our nickname only." (FACTS_VERIFIED, Context)
'''

[visual]
kind = "meter"
caption = "context window"
markers = [
  { label = "your messages", at = 0.0 },
  { label = "files it read", at = 0.4 },
  { label = "tool output", at = 0.75 },
]
+++

- Your messages, files it read, tool output and CLAUDE.md all stay in context
- A million tokens: large, finite, and reread at every reply
- A new session starts empty: context is the whole memory
