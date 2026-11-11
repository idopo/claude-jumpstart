+++
title = "Hand off before the window is full: a continuation file, then /clear"
layout = "statement"
kicker = "Keep the science yours"
notes = '''
`/clear` loses everything you did not write down. So before the window is full, write it down.
`/handoff` writes a continuation file in the project: the task, what is done, what is in progress, the next steps with file paths, and the files changed. The excerpt is real: those are the file's headings, from the skill in the repo.
When: before `/clear`, before you stop for the day, or when `/context` shows it nearly full. From my experience, not a docs fact: a session that is already full writes a worse handoff.
Then `/clear`, then `/continue-session`. The new session reads the file, says what was done, proposes the first next step and asks before starting. With several files, it asks which task.
Example: Tuesday, six in the evening, the pipeline half done, window three quarters full. `/handoff` writes the file: task, done, in progress, next steps with paths. Wednesday morning: `/continue-session`. It reads the file and says "the loader and the per-session means are done; next is the figure; shall I start?" Five minutes, and I am back where I was, with a sharp session instead of a tired one.
Example of the loop across sessions: the handoff is how a long loop keeps going. Each session is a few rounds; the file carries the state between them.
Both are skills from the repo, not built-ins. GSD has its own pair, in part four.
Bridge: Context is working memory. The last slide of this part is long-term memory: what you teach your lab once.
Fact: "`/clear` = new conversation, empty context." (FACTS_VERIFIED, Context)
Fact: "`/context` = coloured usage grid with suggestions" (FACTS_VERIFIED, Context)
Source: captures/05-handoff-skill.txt (real excerpt of skills/handoff/SKILL.md: the file template's headings, 6 lines)
Fallback: read the six headings aloud and say "the next session starts from this file".
Take-home: skills/handoff and skills/continue-session.
'''

[visual]
kind = "steps"
steps = ["/handoff", "/clear", "/continue-session"]
+++

```
# Session Continuation
**Task:** [What you were working on]
## Completed:
## In Progress:
## Next Steps:
## Files Changed:
```

- Write it before /clear, before you stop for the day, or when /context is nearly full
