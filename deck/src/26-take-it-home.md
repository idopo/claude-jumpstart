+++
title = "Take it home: install, paste SETUP.md, run one GSD loop this week"
layout = "points"
kicker = "Take it home"
notes = '''
Clone claude-jumpstart. On Windows one script installs Git for Windows, Node, Claude Code and GSD Core; on a Mac, the three commands in the README. Node 24 or newer.
Git for Windows: optional for Claude Code, required for GSD; the terminal you launch from does not matter.
From my experience, not a docs fact: the model is more fluent in bash than PowerShell.
Log in with your Claude subscription; the free plan does not include Claude Code. Tell Claude your name and email once, for git.
Then open Claude in the repo folder and paste SETUP.md. It asks five questions, installs the skills and rules, and drafts a CLAUDE.md, asking before it touches any file you have.
This week, run one GSD loop on one real piece of work. Small is fine.
Example of a first loop: the thing you did by hand last week: a figure, a table, a cleanup script. One phase, two or three plans. Challenge the plan once before it runs, and look at `/context` once while it does.
The installer has not been run on a lab PC yet: report problems to Ido.
Bridge: The controls you heard about today, on one slide.
Fact: "Git for Windows is **optional**. With it, the Bash tool (and Monitor tool) use Git Bash." (FACTS_VERIFIED, Windows)
Fact: "The terminal you launch `claude` from (PowerShell, cmd, Windows Terminal, Git Bash)" (FACTS_VERIFIED, Windows)
Fact: "Claude Code needs Pro, Max, Ultra, Team, Enterprise or Console; free plan excluded." (FACTS_VERIFIED, Models)
Cut 1: if 27-cheatsheet is skipped, say "the cheat sheet is the last slide of the deck in the repo."
'''

[visual]
kind = "steps"
steps = ["clone + install", "paste SETUP.md", "one GSD loop"]
+++

- Clone claude-jumpstart and run the installer
- Open Claude in the repo and paste SETUP.md
- Pick one real piece of work and run a GSD loop
