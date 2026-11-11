+++
title = "Esc stops it, /rewind goes back, and git is the real undo"
layout = "points"
kicker = "Nothing is lost"
notes = '''
Three ways back, fastest to safest.
Esc stops it now, mid-step.
Esc twice on an empty prompt, or `/rewind`, returns code and conversation to a checkpoint.
Rewind does not track edits made through shell commands, so git is the real undo. Commit before anything big.
Example: you asked for a figure and it starts rewriting the data loader. Esc. "Only the figure; leave the loader." If it had already written files, Esc Esc, pick the checkpoint from before, and the files go back with the conversation.
Example of what rewind misses: it renamed twenty files with a shell command. Rewind does not see those. Git does, if you committed first; so before anything that touches many files, say "commit first".
For risky work, leave auto and approve each edit by hand.
Never paste passwords, tokens or keys into a session.
bypassPermissions skips every check; it is for throwaway containers only, never your own machine.
Bridge: You can now prompt, plan, loop and get back. Part three is about what the model does with that freedom, and what you must keep for yourself.
Fact: "`/rewind` or Esc Esc on an empty prompt: restore code and/or conversation to a checkpoint." (FACTS_VERIFIED, Context)
Fact: "Bash-made edits are not tracked." (FACTS_VERIFIED, Context)
Fact: "`bypassPermissions` (everything;" (FACTS_VERIFIED, Permission modes)
Fact: "containers only)." (FACTS_VERIFIED, Permission modes)
'''
+++

- Esc stops the current step
- Esc Esc restores a checkpoint
- Shell edits are not tracked: commit first
- Never paste passwords or keys
