# Claude Code + GSD Core — how it all fits together

What this is: a guide to the GSD Core planning workflow, to read once before your first `claude` session.
Copied from claude-windows-setup on 2026-11-01, re-targeted to GSD Core (`@opengsd/gsd-core@1.19.0`).

---

## 1. What the script installs, and why

| Tool | Why you need it | Where it lands | PATH entry the script saves |
|---|---|---|---|
| **Git for Windows** | Gives Claude Code a real `bash` (its Bash tool). Without it Claude falls back to a weaker PowerShell tool. | `C:\Program Files\Git` | `...\Git\cmd`, `...\Git\bin` |
| **Node.js LTS (24+)** | Needed for `npx`, which downloads and runs the GSD installer. Also the fallback way to install Claude Code. | `C:\Program Files\nodejs` | `...\nodejs`, `%APPDATA%\npm` |
| **Claude Code** | The CLI agent itself. Native installer first, then winget, then npm. | `%USERPROFILE%\.local\bin\claude.exe` | `%USERPROFILE%\.local\bin` |
| **GSD Core (`@opengsd/gsd-core@1.19.0`)** | A set of skills/agents/workflows that turn Claude Code into a planner + executor. | `%USERPROFILE%\.claude\` (`gsd-core\`, `skills\gsd-*`, `agents\gsd-*`) | — |

**The PATH problem.** On a fresh machine nothing is on PATH, and installers don't always fix that.
The script writes every folder above into the *User* PATH (registry, survives reboots) **and** into the
current session, so each step can see what the previous one installed. Two rules follow from this:

1. After the script finishes, **open a new terminal**. The old one has the old PATH.
2. If `claude`, `git` or `node` is "not recognized" later, run `claude doctor` (if claude works) or re-run the
   script — it is safe to re-run; every step skips what is already installed.

GSD Core lands in `~/.claude/gsd-core` (version file: `~/.claude/gsd-core/VERSION`).

The script also writes `CLAUDE_CODE_GIT_BASH_PATH` into `%USERPROFILE%\.claude\settings.json` so Claude
Code finds Git Bash even if PATH gets wiped again.

---

## 2. First session

```powershell
cd C:\path\to\your\project
claude            # browser opens -> log in with the Claude subscription
```

Inside Claude Code:

```
/gsd-help         # full command list
/gsd-new-project  # start a new project (greenfield)
/gsd-map-codebase # run FIRST on an existing codebase, then /gsd-new-project
```

GSD Core commands use the `/gsd-<command>` form. Update any time with `/gsd-update`.

---

## 3. The GSD mental model

GSD splits work into **milestones → phases → plans → tasks**, and keeps everything as Markdown
files inside a `.planning/` folder in your repo. Claude never has to "remember" anything between
sessions; it re-reads `.planning/` each time.

```
.planning/
├── PROJECT.md            # vision, what you're building and why
├── REQUIREMENTS.md       # scoped requirements with REQ-IDs (v1 / v2 / out of scope)
├── ROADMAP.md            # phases, each mapped to requirements + success criteria
├── STATE.md              # project memory: where we are, decisions, blockers
├── config.json           # interactive vs yolo mode, parallelization, worktrees, models
├── codebase/             # (brownfield) STACK / ARCHITECTURE / STRUCTURE / CONVENTIONS /
│                         #   TESTING / INTEGRATIONS / CONCERNS .md from /gsd-map-codebase
├── todos/                # captured ideas (pending/ and done/)
├── debug/                # /gsd-debug sessions, resolved/ archive
├── milestones/           # archived roadmaps + phase dirs of finished milestones
└── phases/
    ├── 01-foundation/
    │   ├── 01-CONTEXT.md     # output of /gsd-discuss-phase (your decisions for this phase)
    │   ├── 01-RESEARCH.md    # researcher agent's findings
    │   ├── 01-01-PLAN.md     # one plan = one executor agent's job
    │   ├── 01-01-SUMMARY.md  # written by the executor when the plan is done
    │   ├── 01-02-PLAN.md
    │   ├── 01-02-SUMMARY.md
    │   └── 01-VERIFICATION.md
    └── 02-core-features/
        └── ...
```

### The core loop

```
/gsd-new-project  →  /gsd-discuss-phase N  →  /gsd-plan-phase N  →  /gsd-execute-phase N  →  /gsd-verify-work N  →  next phase
       (once)          (optional, recommended)      (writes PLAN.md files)     (runs them in waves)       (UAT)
```

| Command | What it does |
|---|---|
| `/gsd-new-project` | Deep questioning → optional domain research (4 parallel researcher agents) → `REQUIREMENTS.md` → `ROADMAP.md`. |
| `/gsd-discuss-phase N` | Asks you the "gray area" questions for phase N before anything is planned. Writes `CONTEXT.md`. |
| `/gsd-plan-phase N` | Researcher agent → planner agent → plan-checker agent (loops until the plan passes, at most three revisions). Writes `XX-YY-PLAN.md` files with **wave numbers**. |
| `/gsd-execute-phase N` | Runs the plans wave by wave (see §4). Each plan is executed by its own subagent. |
| `/gsd-verify-work N` | Conversational user-acceptance test of what was built. |
| `/gsd-progress` | "Where am I, what's next?" — routes you to the right command. |
| `/gsd-quick "do X"` | Small task with GSD guarantees (atomic commit, state update) but no research/plan-check agents. |
| `/gsd-fast "do X"` | Trivial task, inline, no subagents at all. |
| `/gsd-debug` | Structured debugging that survives context resets. |
| `/gsd-pause-work` / `/gsd-resume-work` | Save and restore a handoff when you stop mid-phase. |

### Design principle: the orchestrator stays lean

The main Claude session (the one you type into) is the **orchestrator**. It never does the heavy
lifting itself; it spawns specialised **subagents**, each with a fresh context window:

| Agent | Role |
|---|---|
| `gsd-phase-researcher` | reads the codebase + docs, writes `RESEARCH.md` |
| `gsd-planner` | turns requirements + research into `PLAN.md` files, computes waves |
| `gsd-plan-checker` | adversarially checks the plans will actually hit the phase goal |
| `gsd-executor` | executes **one** plan: one atomic git commit per task, writes `SUMMARY.md` |
| `gsd-verifier` | goal-backward check that the codebase delivers what the phase promised |
| `gsd-code-reviewer` / `gsd-security-auditor` / `gsd-ui-auditor` | optional retroactive reviews |

Why this matters: your main session's context stays small, so a long project doesn't degrade.
Subagents hand results back as files on disk (`PLAN.md`, `SUMMARY.md`), not as chat.

---

## 4. Waves — what runs concurrently

This is the part people ask about most.

### How the planner assigns waves

Every `PLAN.md` has frontmatter like:

```yaml
phase: 03
plan: 02
wave: 2
depends_on: ["03-01"]
files_modified: ["src/api/users.ts", "src/types/user.ts"]
autonomous: true
```

The planner computes `wave` with this rule:

```
wave = 1                                        if the plan depends on nothing
wave = max(wave of each dependency) + 1         otherwise

# then: any two plans that touch the same file can never share a wave.
# the later one gets bumped to (other.wave + 1) until no wave has a file overlap.
```

So **same wave ⇒ no shared dependencies and zero overlapping files**, which is exactly the condition
for running them at the same time safely.

Example for a phase with four plans:

```
Wave 1:  03-01 DB schema + migration          03-03 shared UI components
         (no deps, disjoint files)            (no deps, disjoint files)
                   │                                      │
Wave 2:  03-02 API endpoints (needs 03-01)                │
                   │                                      │
Wave 3:  03-04 page that calls the API (needs 03-02 and 03-03)
```

`/gsd-plan-phase` prints this table before you execute, so you can see the shape.

### How execute-phase runs them

```
for each wave in order:
    check that no two plans in the wave share a file  (safety net; if they do → run this wave sequentially)
    spawn one executor agent per plan   → in parallel when parallelization=true
    wait for ALL plans in the wave to finish
    collect their SUMMARY.md files
    (next wave's executors receive the previous waves' SUMMARYs as context)
after the last wave:
    spawn the verifier agent → VERIFICATION.md
```

- Waves are **strictly sequential**: wave 2 never starts until every plan in wave 1 is done.
- Plans **inside** a wave run **concurrently**, each executor in its **own git worktree** (an isolated
  checkout on its own branch), then merged back. This is what makes parallel edits safe.
- Useful flags: `/gsd-execute-phase 3 --wave 2` runs only wave 2 (refuses if wave 1 is incomplete),
  `--gaps-only` runs only gap-closure plans after a failed verification.

### Checkpoints — when a wave pauses for you

Some tasks are marked `checkpoint:human-verify` (e.g. "open the page and confirm it looks right") or
`checkpoint:decision`. The executor stops, the orchestrator shows you the question, you answer, and the
same agent continues. In **yolo** mode most checkpoints auto-approve; in **interactive** mode they all
wait for you.

### Settings

GSD Core settings are documented at https://github.com/open-gsd/gsd-core.

---

## 5. A typical day

**New project**
```
/gsd-new-project            # answer the questions; you end up with a ROADMAP
/gsd-discuss-phase 1
/gsd-plan-phase 1
/gsd-execute-phase 1        # watch the waves go by, answer checkpoints
/gsd-verify-work 1
/gsd-progress               # tells you "phase 2 next"
```

**Existing project (brownfield)**
```
/gsd-map-codebase           # 7 docs in .planning/codebase/
/gsd-new-project            # now the roadmap knows your stack
...same as above
```

**Small change, no ceremony**
```
/gsd-quick "add a --dry-run flag to the export command"
```

**Something broke**
```
/gsd-debug "login returns 500 after the migration"
```

**Stopping for the day mid-phase**
```
/gsd-pause-work             # writes .planning/HANDOFF.json + .continue-here.md
# next day, new session:
/gsd-resume-work
```

---

## 6. Things that trip people up

- **"claude is not recognized"** right after setup → you're in the old terminal. Open a new one.
- **Claude says it has no Bash tool** → Git Bash wasn't found. Check `%USERPROFILE%\.claude\settings.json`
  has `env.CLAUDE_CODE_GIT_BASH_PATH` pointing at `C:\Program Files\Git\bin\bash.exe`.
- **A GSD command does nothing** → use the hyphen form, e.g. `/gsd-plan-phase`.
- **Two plans in one wave edit the same file** → the planner should have split them. Execute-phase will
  still run them sequentially (safety net), but re-run `/gsd-plan-phase N` to fix the plan.
- **Commits you didn't expect** → every executor task is an atomic commit, and `.planning/` docs are
  committed too (`planning.commit_docs`, default true). This is by design: the git log *is* the audit trail.
- **`npm.ps1 cannot be loaded because running scripts is disabled`** → Windows' default execution policy
  blocks Node's PowerShell shims. Fix once, then rerun whatever failed:
  `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force` (the setup script now does this for you).
- **winget "installed" but the script fell back to downloads** → normal on a fresh Windows; winget's App
  Installer is often out of date. The fallback path does the same thing.
