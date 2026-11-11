+++
title = "Claude does the git: every step is a commit, and undo is a sentence"
layout = "statement"
kicker = "Nothing is lost"
notes = '''
Why it matters for science: when every step is a commit, every state of an analysis is recoverable and dated. "Which version made Figure 3?" has an answer.
Set git up once, and tell Claude your name and email once. After that, Claude does the git.
`/commit` comes from Anthropic's commit-commands plugin and commits with a message it writes. For everything else, use your own words: undo, go back to this morning, what did you change. Claude maps them to revert, restore and log, and says what it will run first.
Here: I asked it to undo the last change. It offered revert, which keeps history, over reset, which erases. The reply is real; in this scratch repo I ran the revert it proposed by hand. Nothing is lost, so the undo can itself be undone.
Example: "What did you change since this morning?" gives you the log in plain words, file by file. "Go back to the version that made Figure 3" brings that version back as a new commit; the versions in between stay in the history.
Example: in the reaction-time work, a round of fixes made the figure worse. "Undo the last change" and we are back at pass one, and pass two is still there if we want a piece of it.
Bridge: Git is the safest way back. There are two faster ones.
Fact: "Streamline your git workflow with simple commands for committing, pushing, and creating pull requests" (FACTS_VERIFIED, Skills)
Source: captures/03-git-undo.txt (trimmed: Claude's reply shortened to its recommended command)
Fallback: read the request, the revert line and the log after it aloud.
'''
+++

```
> undo the last change and tell me what you did
Claude: git revert HEAD keeps history, adds a new commit
$ git revert --no-edit HEAD
[master 785be83] Revert "Drop slow trials"
$ git log --oneline
785be83 Revert "Drop slow trials"
5003286 Drop slow trials
ed50b45 Add mean reaction time
```

- It reverted instead of erasing, so the undo can be undone
