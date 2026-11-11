+++
title = "Context is working memory that degrades: clear it, delegate, hand off"
layout = "statement"
kicker = "Keep the science yours"
notes = '''
Three habits keep it sharp.
Clear. `/context` shows what fills it. `/clear` between unrelated tasks; it costs nothing, and from my experience it is the most underused command in this room. `/compact` summarises in place when you want to keep the thread.
Delegate. A subagent is a second Claude that Claude starts for you. It reads in its own fresh context, and only its summary comes back into yours, so the reading never fills your session. Subagents still spend tokens, but your main session stays sharp.
Hand off. When a session is nearly full and the work is not done: `/handoff`, then `/clear`, then `/continue-session`. Those two are skills from the repo, not built-ins. The new session starts from a file that names the task, what is done and the next step.
Example: the figure is done and you now want to clean up the methods text. Unrelated job: `/clear` first. The figure's code is on disk and in git; the conversation about it is noise for the next task.
Example: "summarise what these twelve session logs say about reward timing" is a subagent job: twelve files go in, one paragraph comes back, your window grows by a paragraph.
Bridge: Two of those habits get their own slide: how you get a subagent, and how a handoff works.
Fact: "`/context` = coloured usage grid with suggestions" (FACTS_VERIFIED, Context)
Fact: "`/clear` between unrelated tasks. It costs nothing." (FACTS_VERIFIED, Context)
Fact: "`/compact [instructions]` = summarise in place." (FACTS_VERIFIED, Context)
Fact: "Subagents run in their own context; only the summary returns." (FACTS_VERIFIED, Context)
Fact: "They still spend tokens" (FACTS_VERIFIED, Context)
Take-home: skills/handoff and skills/continue-session.
'''

[visual]
kind = "two-roles"
left = ["Your session", "asks, gets the summary, stays sharp"]
right = ["Subagent", "reads in its own context"]
+++

- `/context` shows what fills it; `/clear` between tasks costs nothing
- Hand big reading to a subagent; only its summary comes back
- Nearly full, not done: `/handoff`, `/clear`, `/continue-session`
