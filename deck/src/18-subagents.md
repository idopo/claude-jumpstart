+++
title = "Spawn a subagent by asking for one, or let a framework do it"
layout = "statement"
kicker = "Keep the science yours"
notes = '''
A subagent, as I said, is a second Claude with its own fresh context. Here is how you get one.
Explicitly: say it. "Use a subagent to read these twelve files and report which ones compute reaction time." It reads; you get the report, not the twelve files. Claude also delegates on its own when a task matches, but asking is the reliable way.
Or let a framework spawn them. In GSD the research, every plan and the checks each run in their own subagent; you never type the word. That is part four.
Use one when the work would flood your session: big reading, long logs, a test run. Subagents still spend tokens from the same usage; what they save is your session's context.
Example, straight from the docs: "Use a subagent to run the test suite and report only the failing tests with their error messages". Four thousand lines of output stay in the subagent; three failing tests come back.
Example: "Use a subagent to read the methods sections of these five papers and list how each defines a trial." Five PDFs never enter your window.
What a subagent is not: it does not share your conversation. Tell it what it needs in the prompt, the way you would brief a new student.
Bridge: Subagents protect the session you have. A handoff carries the work into a new one.
Fact: "name the subagent in your prompt; Claude decides whether to delegate" (FACTS_VERIFIED, Subagents)
Fact: "Claude automatically delegates tasks based on the task description in your request" (FACTS_VERIFIED, Subagents)
Fact: "the subagent does that work in its own context and returns only the summary." (FACTS_VERIFIED, Subagents)
Fact: "Use a subagent to run the test suite and report only the failing tests with their" (FACTS_VERIFIED, Subagents)
Fact: "They still spend tokens" (FACTS_VERIFIED, Context)
Source: docs/GSD_GUIDE.md (the orchestrator spawns subagents, each with a fresh context window)
'''

[visual]
kind = "flow"
labels = ["you ask", "subagent reads", "summary returns"]
highlight = "summary returns"
+++

- Ask: "Use a subagent to read these files and report"
- Or a framework spawns them: GSD runs research and each plan in one
- For big reading, logs, test runs: only the summary comes back
