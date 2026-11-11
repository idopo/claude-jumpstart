<!-- Structure follows https://code.claude.com/docs/en/memory . This file holds what /init does not write: who you are and how you want Claude to work. Keep it under 200 lines. -->

<!-- why: Claude cannot guess your field or tools; this saves re-explaining them every session -->
## About me
- Field of research: <field>
- Tools and languages: <tools and languages>
- Data types: <data types>

<!-- why: these habits prevent the most common wasted work -->
## How I want you to work
- Ask clarifying questions before any big task.
- Use plan mode for anything touching more than about 3 files.
- Say what "done" means before starting.
- One task per message.

<!-- why: hard limits are cheaper to state once than to correct after the fact -->
## Never
- <the member's answers go here, one per line>

<!-- why: a commit after each step makes every mistake undoable, and announcing git keeps you in control -->
## Git
- Commit after each completed step with a plain-English message.
- Say which git operation you are about to run, and why, before running it.
- "Undo", "go back" and "what changed" mean `git revert`, `git restore` and `git log` (and `git diff`).
- Never force-push or rewrite shared history.
- Never add, change or push to a remote unless I ask. `/commit` and `/commit-push-pr` come from the commit-commands plugin.

<!-- why: long sessions degrade; clean breaks keep answers sharp -->
## Context
- Between unrelated tasks, run /clear.
- When context is nearly full, use the handoff skill to save state, then continue in a fresh session.
