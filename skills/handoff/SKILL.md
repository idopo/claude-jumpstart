---
name: handoff
description: Use when the user says "handoff", "save where we are", "wrap up so I can clear", or context is getting full. Writes a continuation file for the next session.
disable-model-invocation: false
---

Wrap up the current session and write a continuation file the next session can pick up.

## Instructions

1. Write the file to `.claude/continuations/` in the current project. The Write tool creates the folder if it is missing.

2. Name it `<YYYY-MM-DD>_<HH-MM>_<slug>.md`.
   - The date comes from the environment's current date.
   - The time comes from `date +%H-%M` in Bash or `Get-Date -Format HH-mm` in PowerShell, whichever shell tool you have.
   - The slug is the task in lowercase-hyphens, at most 40 characters.
   - Example: `2026-02-17_14-30_fix-auth-token-refresh.md`

3. File content:

   ```markdown
   # Session Continuation

   **Task:** [What you were working on]

   ## Completed:
   - [x] [Finished items]
   - [ ] [Started but incomplete]

   ## In Progress:
   - [Exactly what was being worked on, file:line if applicable]
   - [What error or issue was being fixed]

   ## Next Steps:
   1. [First thing to do, be SPECIFIC]
   2. [Second priority]

   ## Files Changed:
   - `path/to/file` - [what changed]
   ```

   The `**Task:**` line matters: `continue-session` lists it when several files exist.

4. Tell the user: "Continuation file written. Please `/clear` then `/continue-session`."

## Important

- Review the whole conversation, not just the last few messages.
- The next session starts with zero context, so make Next Steps specific, with file paths and line numbers.
- Suggest adding `.claude/continuations/` to the project's `.gitignore` if the user does not want these files versioned.
