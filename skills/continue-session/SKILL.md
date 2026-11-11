---
name: continue-session
description: Use when the user says "continue", "pick up where we left off", "continue-session", or starts a session after a handoff.
disable-model-invocation: false
---

Resume work from a continuation file written by the `handoff` skill.

## Instructions

1. Use Glob on `.claude/continuations/*.md` to list continuation files.

2. **No files:** tell the user "No continuation files found." and stop.

3. **One file:** read it with the Read tool.

4. **Several files:** use Grep with the pattern `^\*\*Task:\*\*` on each file to get its task line. Ask the user which one to continue, using the task text as the option label and the filename as its description. Read only the chosen file.

5. Summarise what was done and what is in progress, then propose the first Next Step and ask whether to start on it.

6. Once the work has been picked up, ask the user whether to delete the continuation file. Do not delete it without an answer.

## Important

- Do not read files the user did not choose; load only the selected one.
- Next Steps in the file may be stale, so check the files it names before acting on them.
