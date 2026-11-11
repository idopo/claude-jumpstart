# Claude Jumpstart — lab training + support repo

Idea document for `/gsd-new-project --auto @IDEA.md`. Everything GSD needs to write PROJECT.md,
REQUIREMENTS.md and ROADMAP.md is here. Author: Ido (lab member running the training).

## 1. Vision

Every member of the lab now has a Claude subscription. Most use it like a chatbot. The goal is a
single hands-on training session (and a repo that outlives it) that gets them from "I have a
subscription" to "I run Claude Code the way Ido runs it": planning before execution, keeping
control of large bodies of work with GSD, keeping context clean, and teaching Claude their own
environment with CLAUDE.md, knowledge bases and skills.

**Two end products:**

1. **The deck** — a `.pptx` with speaker notes, built for a presenter-only hands-on session: every
   section has a concept slide and a demo slide showing real captures from Ido's machine (Ido may
   additionally show it live; the captures are the fallback). Cut to the chase; minimum theory.
2. **This repo (`claude-jumpstart`)** — what people clone after the talk. It contains the
   templates, skills, install scripts and the demo project used on stage, so the audience can
   reproduce every demo on their own machine the same day.

The planning for this work is **Phase 48 of the MICS backend GSD project** (`~/mics-backend/.planning/`,
47 earlier phases). That project, not this repo, is the GSD exhibit for section 7: a real codebase with
dozens of phases, each a broad subject with many plans.

## 2. Audience and constraints

- Neuroscience lab (behaviour, optogenetics, imaging, electrophysiology). Mixed skill: some write
  Python/MATLAB analysis daily, some never open a terminal. Windows majority, several Macs, one
  Linux user (Ido).
- They have Claude Pro/Max subscriptions, not API keys. Everything must work on a subscription
  login.
- Format (decided 2026-11-01): **presenter-only hands-on**. Ido is the only person with a computer
  open; the audience watches. Hands-on means the content is operational (exact commands, prompts,
  real captures), not that the audience types along. No audience exercises, no pre-session install
  window. Installation happens afterwards from the repo. Target length: ~90 minutes (assumption).
- Language on slides: English. Tone: direct, "how I actually use it", no marketing.
- Scientists must stay the scientists. The training repeatedly stresses that Claude drafts and
  executes; the human decides the science, challenges the plan, and checks the result.

## 3. Existing assets to reuse (do not rewrite from scratch)

| Asset | Path on Ido's machine | Reuse plan |
|---|---|---|
| Windows installer (Git for Windows, Node LTS, Claude Code, GSD; PATH + settings fixes) | `~/claude-windows-setup/setup-claude-windows.ps1` | Copy into `install/windows/`, review, keep idempotent |
| Companion Windows + GSD guide | `~/claude-windows-setup/CLAUDE_AND_GSD_GUIDE.md` | Split into `docs/` pages (GSD mental model, waves, troubleshooting) |
| Handoff / continue-session commands | `~/.claude/commands/handoff.md`, `~/.claude/commands/continue-session.md` | Convert to skills under `skills/handoff/SKILL.md`, `skills/continue-session/SKILL.md` |
| Context-continuation rule | `~/.claude/rules/context-continuation.md` | Ship a trimmed, generic version in `templates/rules/` |
| Quality / honesty / workflow rules | `~/.claude/rules/quality-guardrails.md`, `intellectual-honesty.md`, `workflow-enforcement.md`, `coding-standards.md` | Ship generic versions; strip MICS-specific and RTK-specific lines |
| Real CLAUDE.md example | `~/mics-backend/CLAUDE.md` | Use as the "what a good project CLAUDE.md looks like" exhibit (anonymise nothing, it is lab code) |
| Real skills (scientific) | `~/.claude/commands/es-query.md`, `~/mics-backend/.claude/skills/backlog/` | `es-query` is the scientific skill example: "query the lab's Elasticsearch for behavioural events" |
| Real knowledge bases | `~/mics-backend/.claude/docs/*.md`, `~/mics-backend/POSTER_KNOWLEDGE_BASE.md` | Exhibit for the "knowledge base per topic" section |
| GSD itself | `~/.claude/get-shit-done/` v1.42.3, skills `~/.claude/skills/gsd-*` | Not vendored. Repo documents install via the installer the ps1 script already runs |
| Earlier onboarding prompt (different audience: PI, Mac, Obsidian) | `~/professor-claude-onboarding/ONBOARDING.md` | Reference only; pattern of "paste this prompt and Claude configures itself" is reused for the lab |

## 4. Curriculum — the timeline

Ordering principle: each section produces the problem the next one solves. GSD comes last because
it is the composition of everything before it (plans, subagents, fresh context, docs as memory,
challenging the model).

| # | Section (time) | What they learn | Demo (captures; live optional) | Take-home (in the repo) | Leads to |
|---|---|---|---|---|---|
| 0 | **Get running** (5 min) | What to install and how: Windows = run the ps1 (installs Git for Windows, Node, Claude Code, GSD Core); Mac = the sh script; login with subscription; `claude` inside a project folder | Screenshot sequence of the installer and first launch | Run the installer from the repo | "OK it's open. What is it?" |
| 1 | **What you are talking to** (15 min) | The ladder, with the 2026 reality: **chat** (claude.ai: you paste, it answers; files come back as downloads; nothing persists on your machine) → **Claude with Cowork capabilities** (since 2026-09-16 Cowork is no longer a separate mode, it *is* Claude on paid plans: connected folders, docx/xlsx/pptx creation, code in a cloud sandbox, connectors, scheduled tasks — but no terminal for you, no git, no `~/.claude`/CLAUDE.md, no plan mode, no hooks or local skills, no headless/SSH, sessions cannot be shared) → **Code** (the Code tab / CLI: a shell, files, git, subagents, CLAUDE.md and memory, plan mode, skills on disk, hooks, `claude -p` scripting, SSH to the rig). Conclusion: **Code is not just for coding** — Anthropic's own usage research shows ~20% of Code sessions are writing or data analysis and that domain expertise, not coding skill, predicts effective use. Pick the rung by how much control and repeatability the task needs. Then the models and what each is for; `/model`; effort; fast mode. Subscription limits are one shared pool across chat, Cowork and Code | Same task ("turn these 3 CSVs into a summary table and a figure") in chat and in Code; show what persists, what you can rerun, what you can version; `/model` switch; same prompt on Haiku vs Opus | Worksheet in CHECKLIST.md: place three weekly tasks on the ladder | "How do I phrase the ask?" |
| 2 | **How to talk to it** (10 min) | Goal + constraints + definition of done; give it files, not descriptions; ask it to ask questions; one task per message; don't say "fix it", say what "fixed" means | Bad prompt vs good prompt on a real analysis script | Prompt template in `templates/` | "Even a good prompt on a big task goes wrong — plan first" |
| 3 | **Plan before you execute** (15 min) | The six permission modes and `Shift+Tab` (sessions start in auto); `/plan`; plan mode as the default for anything over ~3 files; read the plan, then *challenge* it ("why X and not Y", "what will break", "what did you add that I did not ask for") — challenges push the model into reasoning and it corrects itself. **Git without learning git:** once git is set up in the terminal, Claude does the git work — every step is a commit, everything is traceable; ask in your own words to undo, go back, or see what changed | Plan mode on "add bootstrap CI to this figure"; challenge the plan twice, watch it change | Challenge-question list in `docs/challenge-the-plan.md` | "The model wanted to do more than I asked" |
| 4 | **Keep the science yours** (10 min) | Models over-deliver: extra analyses, extra claims, silent assumptions. Explicit scope, "do not do X", "stop and ask before", ask for the evidence, never accept a p-value you did not watch computed. The model is the postdoc, you are the PI | Show Claude adding an unrequested statistical test; show the prompt that prevents it | "Do not" list template in `templates/CLAUDE.project.md` | "Long sessions get worse — why?" |
| 5 | **Context: the thing that rots** (15 min) | Context window = working memory; everything you paste or it reads stays there; quality drops as it fills (context rot). `/context`, `/clear`, `/compact`, when to clear (task boundary, after a wrong turn, after a big read). Subagents: delegate reads and side-quests so the main context stays short. Handoff: `/handoff` writes a continuation file, `/clear`, `/continue-session` | `/context` before and after a big file read; delegate the read to a subagent and compare; `/handoff` → `/clear` → `/continue-session` | `skills/handoff`, `skills/continue-session` | "If context is memory, what is long-term memory?" |
| 6 | **Teach Claude your lab** (20 min) | (a) CLAUDE.md: global vs project vs rules; what belongs (commands, conventions, gotchas) and what does not (prose, history); size convention — short, scannable, link out; build it *with* the agent (`/init`, then iterate, then prune). (b) Knowledge base: one `docs/<topic>.md` per topic the agent keeps re-learning (data format, rig, ES schema), referenced from CLAUDE.md. (c) Skills: a SKILL.md = a procedure Claude runs on demand or when it recognises the situation; scientific example: `es-query` / "load-session" skill that knows the lab's data layout and QC steps. (d) Memory | `/init` on the demo repo; prune it live; create one skill from a repeated prompt | `templates/CLAUDE.*.md`, `skills/example-scientific-skill` | "Now put it together for something big" |
| 7 | **GSD — big things with control** (25 min) | Why: a phase is a broad subject (a whole feature, a whole pipeline), not a bug fix; many plans inside; waves run plans in parallel subagents; `.planning/` is durable project memory and context for the next feature. The loop: `/gsd-new-project` → `/gsd-discuss-phase` → `/gsd-plan-phase` → *review the plan* → `/gsd-execute-phase` → `/gsd-verify-work`. Reviewing the plan: summary (weak) → ask for an artifact (better) → challenge statements (best). Explicit plans are the scope fence against over-delivery. `/gsd-pause-work` / `/gsd-resume-work`, `/gsd-quick` for small things | Walk this repo's own `.planning/`; run `/gsd-plan-phase` on the demo project; challenge the plan; execute one wave | `docs/gsd-mental-model.md` + this repo's `.planning/` | "Go do it — here is the repo" |
| 8 | **Take it home** (5 min) | Callback to section 1: Code is not just for coding — one slide of lab tasks that are not software (analysis, figures, writing, docs) done in Code this month. Clone `claude-jumpstart`; the checklist; where to ask for help | — | — | — |

Windows note for section 0 (verified against code.claude.com docs, 2026-11-01, see
`docs/FACTS_VERIFIED_2026-11-01.md`): Git for Windows is *optional* per the docs. Without it
Claude Code falls back to a PowerShell tool; with it, the Bash tool (and the Monitor tool) work.
The terminal you launch `claude` from does not matter. There is **no documented** token or speed
difference between Git Bash and PowerShell. The slide must say: "install Git for Windows so Claude
gets its real Bash tool; the model is far more fluent in bash than PowerShell, so expect fewer
failed commands" — and label that last sentence as Ido's experience, not a docs fact.

Cowork vs Code vs chat facts are verified in `docs/FACTS_VERIFIED_2026-11-01.md` §Cowork. Two traps for the presenter: Cowork is no longer a mode (merged into chat 2026-09-16), and Cowork *does* run code (cloud sandbox) — the real gaps are terminal, git, CLAUDE.md, plan mode, hooks, local skills, headless, SSH.

Other verified corrections that shape the slides: there are six permission modes (default,
acceptEdits, plan, auto, dontAsk, bypassPermissions) and new sessions start in auto mode;
`/ultraplan` was removed — teach plan mode; fast mode is Opus-only and billed to usage credits on
subscriptions; Fable can bill to usage credits depending on plan; CLAUDE.md target is under 200
lines and `@imports` do not reduce context cost; "context rot" is not an Anthropic term (use it as
our nickname, cite the docs' actual guidance: `/clear` between unrelated tasks, Esc when it drifts,
after two failed corrections `/clear` and rewrite the prompt).

## 5. Deliverables (what "done" means) — REDUCED 2026-11-01 ("do less")

**Priority: the deck is the deliverable that matters; the repo is complementary.**

**A. Deck** — `deck/claude-jumpstart.pptx` with speaker notes: per section one concept slide and one
demo slide with a real capture from Ido's machine (PNG or `/export` transcript), built from
`deck/src/NN-*.md` by one `deck/build.mjs` (pptxgenjs). Cheat-sheet slide, safety/undo slide.

**B. Repo** — `claude-jumpstart/`
- `install/setup-claude-windows.ps1` — existing script; only the GSD Core install line and the Node ≥ 24
  check change. Mac: three commands in the README, no script.
- `skills/handoff/`, `skills/continue-session/`. Git: SETUP.md installs Anthropic's official
  `commit-commands` plugin (`/commit`, `/commit-push-pr`); a short Git block in the global CLAUDE.md template
  covers undo/revert in plain words. A scientific skill is shown on the skills slide as an example
  (Ido's `es-query`), not shipped.
- `templates/CLAUDE.global.md`, `templates/CLAUDE.project.md`, `templates/rules/` (three generic rules).
- `SETUP.md` — paste-into-Claude bootstrap: asks five questions, installs skills/rules/global template
  into `~/.claude` (ask before overwriting), drafts a project CLAUDE.md.
- `README.md` (install → SETUP.md → first GSD loop → repo map), `docs/GSD_GUIDE.md` (GSD Core),
  `docs/FACTS_VERIFIED_2026-11-01.md`, `docs/META_HOW_THIS_WAS_BUILT.md`. (Curriculum = planning artifact in
  mics-backend phase 48.)

**C. Verification** — deck build + timed rehearsal; facts re-checked within a week of the session; `v1`
tag. No installer run, no SETUP.md trial: the repo supports the talk, Ido installs on members' machines
later. Nothing is installed or changed on Ido's own machines.

Removed from scope: isolated Claude profile, GSD Core verification loop, Mac installer, synthetic demo
project, capture tooling/manifest, deck lint, per-topic docs pages, multi-machine dry runs.

## 6. Proposed phase shape (roadmapper may adjust)

1. **Curriculum and facts** — lock the section order, timings, learning goals, demo scripts and
   exercises; re-verify every Claude Code claim against docs (first pass already in `docs/FACTS_VERIFIED_2026-11-01.md`); decide the demo project. Output:
   `docs/CURRICULUM.md` + fact sheet. Broad phase, many plans (one per section).
2. **Jumpstart repo** — install scripts (both OS), templates, rules, skills, docs pages, README,
   checklist. Broad phase; plans group by directory.
3. **Captures** — the scripted demo steps (`demo/SCRIPT.md`), run on Ido's machine against real
   projects where possible and a small take-home seed project otherwise; `/export` transcripts and
   screenshots with a version manifest, including the "challenge the plan" and "over-reach"
   transcripts. The seed must live outside this repo when run (GSD walks up to a parent
   `.planning/`).
4. **Deck** — slides + speaker notes + captures, generated from a diffable source.
5. **Dry run and release** — replay every demo from a fresh clone, test installers, fix, tag v1.

## 7. Out of scope

- API-key workflows, Claude SDK, building agents.
- Vendoring GSD source (install via its installer; pin the version in docs).
- Teaching Python or git themselves.
- Obsidian / note-taking setup (separate onboarding).

## 8. Assumptions to confirm in discuss-phase

- ~90 min session, presenter-only (decided: no audience machines, no exercises).
- Deck in English, pptx (not Google Slides).
- Demo project is behavioural-data flavoured (synthetic lick/poke events), not imaging.
- Lab members install GSD too (not only Claude Code).
