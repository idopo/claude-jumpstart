# SETUP: your guided first session with Claude

## How to use this file (for you, the human)

- **Windows:** double-click `2-START-CLAUDE-SETUP.cmd` in this folder. Claude opens and starts reading this file by itself.
- **Mac, or if the double-click did not work:** open a terminal in this folder, type `claude`, then type:
  `Read SETUP.md and walk me through it, one step at a time.`

Everything below is written for Claude. You do not need to read it; Claude will guide you.

---

## Instructions for Claude

You are guiding a lab member through their first Claude Code session, right after Ido's "Claude Jumpstart"
talk. They are a researcher (a neuroscience lab, animal behaviour and physiology), often new to the terminal
and nervous about it. Your job is to set up their workspace AND teach the habits from the talk while doing it.

### How to run this session

- Go **one step at a time**. At the start of each step say "Step N of 12: <name>". At the end, say what you did
  in one or two lines and wait for the person to say "next" (or ask a question) before moving on.
- Teach while you do. Each step has a **Teach** line: say it in your own words, in at most three short sentences,
  in plain language. No jargon without a one-line explanation.
- Ask questions **one at a time**. Use the AskUserQuestion tool with options whenever answers are predictable;
  the person can always pick "Other" and type.
- Before writing or changing ANY file that already exists, show the difference and ask: keep, replace or skip.
  Never overwrite silently. This person may already use Claude: their existing skills, rules, hooks, plugins,
  status line and CLAUDE.md always win; add next to them, never instead of them.
- Use the Read, Write, Edit and Glob tools for file work, not shell copies, so it works on Windows and Mac.
- `~` means the person's home folder (on Windows `C:\Users\<name>`). Claude's own settings live in `~/.claude/`.
- If something fails, explain it in plain words, suggest a fix, and say: "If this keeps failing, send Ido a
  screenshot - he offered to help one on one."
- Answer in the language the person writes in.

### Step 1 - Welcome and health check

Teach: "You talk to me in plain words. I can read files, run commands and edit things, but I ask permission
first. When I ask, you can say yes, no, or tell me what to do instead. Esc stops me at any time."

Check, read-only, and report in a short table (OK / missing):
- `claude --version`, `git --version`, `node --version` (Node must be 24 or newer).
- GSD: `~/.claude/gsd-core/VERSION` exists (print the version). If instead `~/.claude/get-shit-done/` exists,
  they already had GSD before the kit: that is fine, it is the same workflow; never install or update GSD here.
- The context bar: `~/.claude/settings.json` has a `statusLine` entry. If it is GSD's (`gsd-statusline`), say so.
  If it is something else, it is their own: keep it, and never replace it.
- Windows only: `~/.claude/settings.json` has `env.CLAUDE_CODE_GIT_BASH_PATH`.

If anything is missing: Windows → "close me, double-click `1-INSTALL-WINDOWS.cmd` again (it is safe to re-run,
and it never replaces anything you already have), then come back." If GSD is missing because their Node is older
than 24, do not upgrade Node: say Ido will help with that one on one, and carry on without GSD.
Mac → the three commands in README.md, "Install". Do not try to fix installs yourself.

Then point at the bottom of the screen: "That line is your status bar. It shows the model, the folder, and how
full my context (my working memory) is. Keep an eye on it - Step 11 explains why."

### Step 2 - What is in this repo

Show this table and ask if they want to look at anything before moving on:

| Thing | What it is |
|---|---|
| `skills/handoff` | `/handoff`: saves where we are into a file before you clear or stop for the day |
| `skills/continue-session` | `/continue-session`: picks up from that file in a fresh session |
| `skills/wis-slides` | optional: Weizmann-branded slide decks (needs the template from Ido) |
| `templates/rules/` | two always-on rules: honest disagreement, and keep the science yours |
| `templates/CLAUDE.global.md` | your personal instructions to me, filled in from your answers |
| `hooks/protect-folders.js` | a hook that stops me from changing your raw data |
| `docs/GSD_GUIDE.md` | the GSD planning workflow from the talk (plan, then build, then verify) |
| `deck/` | the slides from the talk, as text sources |

Already installed by the installer (unless they already had their own): **GSD** (the `/gsd-...` commands),
the **context bar**, and GSD's **context monitor** (it warns me when my memory is getting full).

### Step 3 - Getting to know you (the questionnaire)

Teach: "Everything you tell me here goes into a file called CLAUDE.md. I read it at the start of every
session, so you never have to explain yourself twice."

Ask one at a time, wait for each answer:
1. Your name and role (student, postdoc, staff scientist, ...)?
2. What is your research about, in one or two sentences?
3. What do you work with? (species / preparation, kinds of data: behaviour videos, ephys, imaging, CSVs, ...)
4. Which tools and languages do you use? (Python, MATLAB, R, Excel, Prism, ImageJ, DeepLabCut, ...)
5. How comfortable are you with code? (never written any / I edit scripts others wrote / I write my own / I'm a developer)
6. What do you most want help with? (analysis scripts, figures, understanding old code, writing, organising files, learning to code, ...)
7. Which folders hold raw data that must never be changed? (folder names like `raw`, `data/raw`, `recordings`, or "none")
8. What must I never do? (for example: delete files, change raw data, run statistics you did not ask for, email anyone)
9. How should I explain things? (short and direct / step by step with reasons / teach me as we go)
10. Which language do you want me to answer in?

Repeat the answers back as a short summary and ask "anything to change?".

### Step 4 - Git, your undo button

Teach: "Git takes snapshots of your project. With it, 'undo that' or 'go back to this morning' always works.
You never need git commands: say it in your own words and I tell you what I'm about to run."

Run `git config --global user.name` and `git config --global user.email`. If either is empty, ask for name and
email once and set them. Then explain `/commit` (comes in Step 7) and the phrases "undo that", "what did you
change?", "go back to yesterday's version".

### Step 5 - GitHub (optional): a copy of your work off this computer

Ask first (AskUserQuestion): "Do you want to connect your GitHub account? Then your projects can be backed up to
GitHub. You can also skip this and do it later." Options: connect now / later / I don't use GitHub. On "later",
tell them: "Any time, open me in the claude-jumpstart folder and say 'connect my GitHub'." Then move on.
On "I don't use GitHub", say local git is enough for undo, and move on.

Teach: "Git keeps snapshots on this computer. GitHub keeps a copy online, so a dead laptop is not a lost project.
Pushing (uploading) only ever happens when you ask; I never push or create anything on GitHub by myself."

If they connect:
1. **Install the GitHub CLI (`gh`)** if `gh --version` fails. Windows: `winget install --id GitHub.cli -e
   --accept-package-agreements --accept-source-agreements` (warn first: Windows may ask "allow this app to make
   changes?" - click Yes). Mac: `brew install gh`. My session does not see newly installed programs on PATH, so on
   Windows call it by full path afterwards: `C:\Program Files\GitHub CLI\gh.exe` (check it exists).
2. **Log in, in a separate window** - the login is interactive and cannot run inside this chat. Tell them exactly
   what will happen, then open it:
   - Windows: `Start-Process powershell -ArgumentList '-NoExit','-Command',"& 'C:\Program Files\GitHub CLI\gh.exe' auth login --web --hostname github.com --git-protocol https"`
     (with the PowerShell tool, or wrapped in `powershell.exe -NoProfile -Command "..."` from Bash).
   - Mac: `osascript -e 'tell application "Terminal" to do script "gh auth login --web --hostname github.com --git-protocol https"'`
   What they will see: a question "Authenticate Git with your GitHub credentials?" (press Enter for Yes), then a
   one-time code like `ABCD-1234` and "Press Enter to open github.com". They press Enter, sign in to GitHub in the
   browser, paste the code, click **Authorize**, then close that window and come back here and say "done".
3. **Check:** run `gh auth status` (full path on Windows) and `gh auth setup-git`, so git uses this login when
   pushing. Report the GitHub username it shows. If it failed, offer to try once more, otherwise skip:
   "Ido can do this with you one on one."
4. **Raw data stays off GitHub.** Explain in one line: GitHub is for code, notes and small results, not raw
   recordings or videos (size, and some data must not leave the lab). Step 10 sets this up per project.

### Step 6 - Skills and rules

Teach: "A skill is a recipe I follow when you type its name. A rule is a standing instruction I follow always."

- Install `skills/handoff/SKILL.md` to `~/.claude/skills/handoff/SKILL.md`.
- Install `skills/continue-session/SKILL.md` to `~/.claude/skills/continue-session/SKILL.md`.
- Install every file in `templates/rules/` to `~/.claude/rules/<file>`. Read each rule out in one line.
- Ask whether they make Weizmann-branded decks; only on yes, install `skills/wis-slides/` to
  `~/.claude/skills/wis-slides/` and tell them the template file comes from Ido.

Skills appear after a restart of Claude; say so, and that Step 12 tells them how.

### Step 7 - The official git commands plugin

Run `claude plugin list`. If `commit-commands` is installed, say so and skip. Otherwise, explain in one line that
it adds `/commit`, `/commit-push-pr` and `/clean_gone` from Anthropic's official plugins, ask, and on yes ask them
to type this into the chat box:
```
/plugin install commit-commands@claude-plugins-official
```

### Step 8 - Hooks: rules that always fire

Teach: "CLAUDE.md asks me to behave; I can forget. A hook is a small command Claude Code runs at a fixed moment,
every single time. It is how you make a rule certain."

Offer these one at a time. For each: explain in one line, ask yes/no. Before the first change, copy
`~/.claude/settings.json` to `~/.claude/settings.json.bak-<YYYYMMDD-HHMM>` (a new name, so no earlier backup is
overwritten) and say where the backup is. If the file does not parse as JSON, stop this step and say so; never
rewrite a file you cannot read. Merge into the existing
`hooks` object: keep every existing entry (GSD already has several), add only the new one, show the diff, write
only after yes. After writing, Read the file back and check it is valid JSON.

1. **Already on: the context monitor** (from GSD). Nothing to install; just show them the GSD entries under
   `PostToolUse` and say what it does.
2. **A sound when Claude needs you** - for when you switch windows while I work. Add under `hooks.Notification`:
   - Windows: `{"hooks":[{"type":"command","command":"powershell.exe -NoProfile -Command \"[System.Media.SystemSounds]::Exclamation.Play(); Start-Sleep -Milliseconds 700\""}]}`
   - Mac: `{"hooks":[{"type":"command","command":"osascript -e 'display notification \"Claude needs you\" with title \"Claude Code\" sound name \"Glass\"'"}]}`
3. **Protect raw data** - only if they named folders in Step 3, question 7. Copy `hooks/protect-folders.js` to
   `~/.claude/hooks/protect-folders.js`, then add under `hooks.PreToolUse`:
   `{"matcher":"Write|Edit|MultiEdit|NotebookEdit|Bash|PowerShell","hooks":[{"type":"command","command":"node \"<HOOK>\" <folder1> <folder2>"}]}`
   where `<HOOK>` is the full path of the copied file with forward slashes (e.g.
   `C:/Users/dana/.claude/hooks/protect-folders.js`; no `~` or `$HOME`), and the folder names use forward
   slashes, quoted if they contain spaces. Then test it: ask me to create a file inside one protected folder and
   show that the hook blocks it (the test only works after a restart, so offer it at Step 12 instead if needed). Explain: reading is always allowed;
   writing, moving or deleting inside those folders is blocked, and I'm told to write results elsewhere.
   It is a seatbelt against accidents, not a lock - backups still matter.

Tell them: "Hooks load when Claude restarts. Type /hooks any time to see what is installed. Want another one
later? Just describe it to me: 'write a hook that ...'."

### Step 9 - Your global CLAUDE.md

Fill `templates/CLAUDE.global.md` with the Step 3 answers: name/role, research, data, tools, coding comfort,
how to explain, language, and the "Never" list (question 8, plus "never change files in <raw folders>" if any).
If `~/.claude/CLAUDE.md` exists, propose a merged version (existing lines kept, new blocks appended). Show it,
write `~/.claude/CLAUDE.md` only after yes. Teach: "Keep it short. Every line costs me attention every session.
When I get something wrong twice, add one line here."

### Step 10 - A CLAUDE.md for one real project

Ask for the path of one project folder they actually work in (tip on Windows: in Explorer, Shift+right-click
the folder → "Copy as path", then paste). Read its top-level listing and README if any. Draft a project
CLAUDE.md the way `/init` would (what the project is, how to run things, conventions, gotchas), prune it with the
questions in `templates/CLAUDE.project.CHECKLIST.md`, and add a "Do not" block from Step 3 and
`templates/rules/keep-the-science-yours.md`. Show it, write `<project>/CLAUDE.md` only after yes. If one exists,
propose additions instead. Ask whether the project is already a git folder; if not, offer to run `git init` there
and make a first commit, explaining it is the undo button from Step 4.
Before that first commit, add a `.gitignore` that excludes their raw-data folders (Step 3, question 7) and large
data files (videos, recordings), and show it. If GitHub was connected in Step 5, ask whether to back this project
up to a NEW **private** GitHub repository; only on yes, run `gh repo create <name> --private --source . --push`
and show them the link. Never make a repository public.

### Step 11 - How to work with me day to day (the talk in two minutes)

Teach these, one short paragraph each, and pause for questions after the list:
1. **Open me where you work.** Windows: right-click your project folder → "Open Claude here" (Windows 11:
   "Show more options" first). I only see the folder I was opened in.
2. **A good ask has three parts:** what you want, the context (which files, which data), and what "done" looks
   like. Vague asks get confident guesses.
3. **Plan first for anything bigger than a small fix:** press Shift+Tab to switch to plan mode; I propose, you
   challenge, then I build.
4. **You are the PI, I am the postdoc.** I propose analyses; you decide the science. Ask me to show the code and
   numbers behind any result.
5. **Watch the context bar.** My memory fills as we work, and I get worse as it fills. One task per session;
   `/clear` between unrelated tasks. When it is getting full (or when the context monitor warns me), type
   `/handoff`, then `/clear`, then `/continue-session` - you lose nothing.
6. **Commit after each step that works** (`/commit`), so "undo that" is always safe.
7. **For a real piece of work, use GSD:** `/gsd-new-project`, then for each phase `/gsd-discuss-phase 1`,
   `/gsd-plan-phase 1` (read the plan and challenge it), `/gsd-execute-phase 1`, `/gsd-verify-work 1`.
   `/gsd-quick` for small things. Details: `docs/GSD_GUIDE.md`.
8. **Never paste passwords, tokens or keys** into a session.

### Step 12 - Finish

1. List every file you wrote or changed, and which optional items were skipped.
2. Cheat sheet: Esc stop · Shift+Tab plan mode · `/rewind` go back · `/clear` fresh start · `/context` see memory
   use · `/handoff` + `/continue-session` · `/hooks` · `/commit` · `/gsd-quick` · `/gsd-progress`.
3. Tell them: "Type /exit, then right-click your project folder → 'Open Claude here'. Your new skills and hooks
   load in that fresh session. A good first task: something you did by hand last week. Small is fine."
4. End with: "Stuck, or want to go through this together? Ido offered to help one on one - just message him."
