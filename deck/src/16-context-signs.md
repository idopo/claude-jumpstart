+++
title = "A full context shows: it forgets, repeats itself and re-reads files"
layout = "statement"
kicker = "Keep the science yours"
notes = '''
Degradation has signs, and you learn to read them. It forgets a constraint you gave at the start: the outlier rule you banned comes back. It re-reads a file it already read. It repeats a fix it already made, or contradicts something it said an hour ago. Answers get longer and vaguer. From my experience, not a docs fact; the docs only say the window is finite.
Look before you guess: `/context` shows a coloured grid of what is in the window, by category, with suggestions; `/context all` expands it. I check it whenever an answer surprises me.
Near the top, Claude Code compacts automatically: it summarises the conversation in place. From my experience: the summary keeps the decisions and loses the detail: exact values, which file had the bug, what you tried that failed. `/compact` does the same when you choose, and you can say what to keep: "/compact keep the outlier decision and the file list".
My rule of thumb, not a docs rule: at about three quarters full, finish the current step and hand off rather than push on. A session that is already full writes a worse handoff, and the last quarter is where the mistakes happen.
Example: late in a long session it "fixed" the session ordering for the third time, the same way each time. `/context` showed the window nearly full; the first two fixes had been compacted into "ordering fixed". Hand off, new session, fixed once.
Example of the cheap check: before any big step, `/context`. Two seconds. If it is past three quarters, do the step in a new session.
Bridge: So what do you do about it? Three habits.
Fact: "`/context` = coloured usage grid with suggestions" (FACTS_VERIFIED, Context)
Fact: "(`/context all` expands)" (FACTS_VERIFIED, Context)
Fact: "auto-compact at" (FACTS_VERIFIED, Context)
Fact: "`/compact [instructions]` = summarise in place." (FACTS_VERIFIED, Context)
'''

[visual]
kind = "meter"
caption = "what /context shows"
markers = [
  { label = "fresh", at = 0.0 },
  { label = "hand off here", at = 0.75 },
  { label = "auto-compact", at = 0.9 },
]
+++

- Signs: a forgotten constraint, a file read twice, the same fix again
- /context shows what fills the window; compaction keeps decisions, loses detail
- My rule: at about three quarters full, finish the step and hand off
