# claude-jumpstart

The take-home kit from the lab's Claude Code + GSD session: an installer, a prompt that
customises Claude for you, a few skills and rules, and a guide to the GSD planning workflow.

## Install

**Windows (no terminal needed).**

1. On the GitHub page click the green **Code** button → **Download ZIP**. Right-click the ZIP → **Extract All**.
2. In the extracted folder, double-click **`1-INSTALL-WINDOWS.cmd`**.
   - "Windows protected your PC"? Click **More info** → **Run anyway**.
   - "Allow this app to make changes?" Click **Yes**.
   It installs Git for Windows, Node 24+, Claude Code and GSD Core 1.19.0 (which brings the context bar and
   context monitor), saves everything on your PATH, and adds **"Open Claude here"** to the right-click menu
   of every folder. It asks where to keep your own copy of this kit (a git clone, so it can be updated)
   and puts a **"Claude setup"** shortcut on your desktop. Safe to re-run. Takes 5-10 minutes.
   After that the downloaded ZIP can be deleted.
3. Double-click **"Claude setup"** on your desktop. Log in when the browser opens. Claude then walks you
   through `SETUP.md`: a short questionnaire, your skills, rules, hooks and CLAUDE.md.

**Already use git?** `git clone https://github.com/idopo/claude-jumpstart.git`, then double-click
`1-INSTALL-WINDOWS.cmd` in the clone.

**Mac.** In Terminal (then `git clone https://github.com/idopo/claude-jumpstart.git` and `cd` into it):

```bash
brew install node
curl -fsSL https://claude.ai/install.sh | bash
npx -y --package=@opengsd/gsd-core@1.19.0 -- gsd-core --claude --global
```

Then `cd` into this folder, run `claude`, and type: `Read SETUP.md and walk me through it, one step at a time.`

**Check** (Claude does this for you in SETUP step 1): `claude --version` prints a version, and
`~/.claude/gsd-core/VERSION` says `1.19.0`.

Sources: https://code.claude.com/docs/en/setup and https://github.com/open-gsd/gsd-core

**Stuck?** Take a screenshot of the window and message Ido; he will help you set up one on one.

## What you get

| Item | Kind | What it does | Installed by |
|---|---|---|---|
| Context bar | status line (GSD) | bottom line: model, folder, how full the context is | installer |
| Context monitor | hook (GSD) | warns Claude when context is running low | installer |
| GSD Core | `/gsd-*` skills | plan → execute → verify workflow (`docs/GSD_GUIDE.md`) | installer |
| Open Claude here | right-click menu | starts Claude in any folder, no terminal | installer (Windows) |
| `handoff` | skill | `/handoff`: save the session to a continuation file before `/clear` | SETUP.md |
| `continue-session` | skill | `/continue-session`: resume from that file | SETUP.md |
| `wis-slides` | skill, optional | Weizmann-branded decks (template from Ido) | SETUP.md, on request |
| `commit-commands` | official plugin | `/commit`, `/commit-push-pr`, `/clean_gone` | SETUP.md |
| intellectual-honesty, keep-the-science-yours | rules | always-on standing instructions | SETUP.md |
| Notification sound | hook | plays a sound when Claude needs you | SETUP.md, optional |
| `protect-folders` | hook | blocks changes inside raw-data folders | SETUP.md, optional |
| Global + project CLAUDE.md | memory | built from your questionnaire answers | SETUP.md |

## Git, once

Tell Claude your name and email one time ("my name is ..., my email is ..., set up git for me")
and it sets your git identity. If you use GitHub, run `gh auth login` once in the terminal.

After that, `/commit` saves your work. Git commands come from Anthropic's official
`commit-commands` plugin, which SETUP.md installs. For everything else, ask in your own words:
"undo that", "go back to this morning's version", "what did you change?". Claude says which git
command it will run before running it.

## Make Claude yours

`2-START-CLAUDE-SETUP.cmd` (or "Read SETUP.md and walk me through it") starts a guided session: Claude
asks about your work one question at a time, teaches the habits from the talk, and sets up your skills,
rules, hooks and CLAUDE.md, asking before it touches any existing file.

## Your first GSD loop

In a project folder, start `claude` and run, one at a time:

1. `/gsd-new-project`
2. `/gsd-discuss-phase 1`
3. `/gsd-plan-phase 1`, then read the plan and challenge it
4. `/gsd-execute-phase 1`
5. `/gsd-verify-work 1`

Use `/gsd-quick` for small things. The full guide is `docs/GSD_GUIDE.md`.

## Repo map

```
1-INSTALL-WINDOWS.cmd      double-click: installs everything (runs install/setup-claude-windows.ps1)
2-START-CLAUDE-SETUP.cmd   double-click: opens Claude here and starts SETUP.md
install/    setup-claude-windows.ps1, claude-here.ps1 (the "Open Claude here" launcher)
skills/     handoff, continue-session, wis-slides (optional)
hooks/      protect-folders.js (raw-data guard; tests in tests/, run: node --test tests/protect-folders.test.mjs)
templates/  CLAUDE.global.md, CLAUDE.project.CHECKLIST.md
  rules/    intellectual-honesty.md, keep-the-science-yours.md
SETUP.md    the guided setup Claude walks you through
docs/       GSD_GUIDE.md, FACTS_VERIFIED_2026-11-01.md, META_HOW_THIS_WAS_BUILT.md
deck/       sources in src/; build.py builds the pptx (template in brand/, held by Ido)
```
