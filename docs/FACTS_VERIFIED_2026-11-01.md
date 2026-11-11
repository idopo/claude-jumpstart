# Claude Code facts — verified 2026-11-01

Re-checked: 2026-11-02 — Windows, Permission modes, Models, Context, Cowork (4 changes)

Checked by a `claude-code-guide` subagent against code.claude.com/docs. Re-verify before the
session; the docs move fast. Each block lists the page it was checked against.

## Windows — `setup.md`, `tools-reference.md`
- Git for Windows is **optional**. With it, the Bash tool (and Monitor tool) use Git Bash.
  Without it, Claude Code runs shell commands through a PowerShell tool.
- The terminal you launch `claude` from (PowerShell, cmd, Windows Terminal, Git Bash) does not
  change which shell tool is used.
- **No documented** token or speed difference between Git Bash and PowerShell. Any such claim on
  a slide is experience, not a docs fact.
- `CLAUDE_CODE_GIT_BASH_PATH` in `settings.json` → `env` points Claude at `bash.exe` when it
  cannot find it (`C:\Program Files\Git\bin\bash.exe`).
- Native Windows: sandboxing not supported. WSL 2: supported. Docs do not recommend one over the
  other; "pick based on where your projects are".

## Permission modes — `permission-modes.md`, `best-practices.md`
- Six modes: `default` (reads only without asking), `acceptEdits` (edits + mkdir/mv/cp in the
  working dir), `plan` (explore + write a plan, no source edits), `auto` (everything, a separate
  classifier model reviews actions; after 3 consecutive or 20 total blocks it starts prompting
  again), `dontAsk` (anything that would prompt is denied; CI), `bypassPermissions` (everything;
  containers only).
- Switch: `Shift+Tab` cycles auto → default → acceptEdits → plan (`dontAsk` never in the cycle);
  `--permission-mode <mode>`; `permissions.defaultMode` in settings. `/permissions` manages
  allow/deny rules, it does **not** switch modes.
- New terminal sessions start in auto mode on Claude Code 2.1.283 or later; on earlier versions,
  auto on Pro, Max, Ultra or Team plans in sessions that fetch feature flags, and default otherwise.
  VS Code follows the extension's own list. (`permission-modes.md`, "Which mode a session starts in";
  `best-practices.md` still says it without the version condition.)
- Plan mode: `Shift+Tab`, `/plan [description]`, or `--permission-mode plan`. Approve with
  "Yes, and use auto mode" / "Yes, manually approve edits" / "No, keep planning". `Ctrl+G` opens
  the plan in your editor. `/ultraplan` was **removed**.

## Models — `model-config.md`, `fast-mode.md`, `setup.md`
- Lineup: Fable 5.1 (needs Claude Code ≥ 2.1.257), Opus 5.5, Sonnet 5.5, Haiku 5.5 (older 5 /
  4.x still selectable).
- Docs' one-liners: `fable` "hardest and longest-running tasks"; `opus` "complex reasoning";
  `sonnet` "daily coding tasks"; `haiku` "simple tasks" and subagents doing simple jobs.
- Aliases: `best` = fable if available else opus; `opusplan` = opus in plan mode, sonnet
  otherwise.
- Default on Pro/Max/Team/Enterprise is Opus 5.5. Fable is never the default; on some plans
  Fable bills to usage credits instead of the included limits.
- `/model` saves the choice as default for new sessions (`s` in the picker = this session only).
- Effort: `/effort`, `--effort`, `CLAUDE_CODE_EFFORT_LEVEL`; levels low/medium/high/xhigh/max;
  Opus/Sonnet/Haiku 5.5 default to medium.
- Fast mode (`/fast`): Opus-only, up to 2.5× faster at higher cost; on subscriptions it is
  billed to usage credits, not included limits.
- Claude Code needs Pro, Max, Ultra, Team, Enterprise or Console; free plan excluded.

## Context — `context-window.md`, `commands.md`, `best-practices.md`
- Fable 5.x, Sonnet 5+, Haiku 5.5, Opus 4.7+ run with a 1M window by default; auto-compact at
  ~967K. `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` → 200K.
- `/clear` = new conversation, empty context. `/compact [instructions]` = summarise in place.
  `/context` = coloured usage grid with suggestions (`/context all` expands).
- Subagents run in their own context; only the summary returns. They still spend tokens
  against the same usage.
- Docs guidance: "`/clear` between unrelated tasks. It costs nothing." Press Esc the moment it
  drifts; after two failed corrections, `/clear` and write a better prompt instead of a third.
- "Context rot" is **not** an Anthropic term. Use it as our nickname only.
- `/rewind` or Esc Esc on an empty prompt: restore code and/or conversation to a checkpoint.
  Bash-made edits are not tracked. `/resume`, `claude -c`, `claude -r <name>`.

## CLAUDE.md and memory — `memory.md`
- Load order: managed policy file → `~/.claude/CLAUDE.md` → `./CLAUDE.md` → `./CLAUDE.local.md`
  (gitignore it) → `.claude/rules/*.md` and `~/.claude/rules/` → `@path` imports; subdirectory
  CLAUDE.md files load when Claude reads a file there. All are concatenated, not overridden.
- `@imports` are expanded into context — they do **not** reduce cost, they organise.
- Size: "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce
  adherence." Specific and concise beats long.
- `/init` creates it from the codebase; if one exists it suggests improvements.
- Auto memory: on by default, machine-local, `~/.claude/projects/<project>/memory/` with a
  `MEMORY.md` index (first 200 lines / 25 KB loaded). `/memory` toggles.

## Skills — `skills.md`
- `SKILL.md` in `~/.claude/skills/<name>/` (personal), `.claude/skills/<name>/` (project),
  plugins. Frontmatter all optional; `description` drives auto-triggering and is always in
  context, the body loads on invocation.
- Useful fields: `user-invocable: false` (hide from `/` menu), `disable-model-invocation: true`
  (never auto-load), `allowed-tools`, `context: fork` (+ `agent`), `model`, `effort`.
- `.claude/commands/*.md` keep working; they were merged into skills. New work → skills.
- `skill-creator` is a plugin: `/plugin install skill-creator@claude-plugins-official`.
- `commit-commands` is Anthropic's official git plugin: `/plugin install commit-commands@claude-plugins-official`; plugin.json description: "Streamline your git workflow with simple commands for committing, pushing, and creating pull requests". Commands: `/commit`, `/commit-push-pr`, `/clean_gone` (source: claude-plugins-official, plugins/commit-commands, v1.0.1).

## Subagents — `sub-agents.md`
- `.claude/agents/*.md` (project) or `~/.claude/agents/` (user); frontmatter `name`,
  `description` required; `tools`, `model`, `permissionMode`, `maxTurns`, `skills`, `memory`,
  `background`, `isolation` optional. Body = system prompt.
- Built-ins: `Explore` (read-only search), `Plan` (read-only research in plan mode),
  `general-purpose`. Fork subagents inherit the parent conversation (`/subtask`).
- Explicit vs automatic (`https://code.claude.com/docs/en/sub-agents`, read 2026-11-01): "Use one
  when a side task would flood your main conversation with search results, logs, or file contents you
  won't reference again: the subagent does that work in its own context and returns only the summary."
  "Claude automatically delegates tasks based on the task description in your request". Explicitly:
  "**Natural language**: name the subagent in your prompt; Claude decides whether to delegate". Docs
  example prompt: "Use a subagent to run the test suite and report only the failing tests with their
  error messages".

## Artifacts — `artifacts.md` (read 2026-11-01)
Source: https://code.claude.com/docs/en/artifacts (index entry in https://code.claude.com/docs/llms.txt;
introduced in https://code.claude.com/docs/en/whats-new/2026-w25).

- "is a live, interactive web page that Claude Code publishes from your session to a private URL on
  claude.ai. You open it in a browser, and it updates in place as the session continues."
- "Use an artifact when terminal text is the wrong medium for what Claude produced". One listed use:
  "Lay out several design or implementation options side by side".
- Creating and updating: "Claude may publish an artifact on its own when the output suits a page, or you
  can ask for one directly." "Claude edits the underlying file and publishes again to the same URL."
  In plan mode Claude Code "Asks before the first publish of each artifact".
- "A new artifact is visible only to you." Sharing is from the page's **Share** control; sharing within
  the organization is Team and Enterprise; a public link is open to anyone.
- "Artifacts are available on Pro, Max, Ultra, Team, and Enterprise plans and require a session signed in
  with" `/login`. "`/artifacts` works in a new session and after `/clear`" (the docs' sentence:
  "Claude Code reads the list from your claude.ai account, so `/artifacts` works in a new session and
  after `/clear`").

## Not documented (do not claim)
- Per-plan (Pro vs Max) model availability.
- Any Git Bash vs PowerShell token/speed difference.
- The `#` memory shortcut.

## Cowork vs Code vs chat — checked by a second subagent, 2026-11-01
Sources: support.claude.com, claude.com/docs, code.claude.com/docs, anthropic.com.

- **Cowork is no longer a separate mode.** 2026-09-16: "Claude Cowork and chat are merging into
  one Claude" (quote from `claude.com/resources/articles/cowork-is-now-claude`, which gives
  September 16, 2026 and Enterprise GA "October 23"). The support article
  `support.claude.com/.../16761823` ("Claude Cowork and chat are one Claude") gives no dates: Team
  is in beta, Enterprise only where a "Chat and Cowork unified" setting is on.
- Cowork "uses the same agentic architecture that powers Claude Code, accessible within Claude
  Desktop without opening the terminal". (`claude.com/docs/cowork/overview`)
- **Cowork does run code**: each session gets its own sandbox, created when the session starts and
  destroyed when it ends; sessions run in the cloud by default, local sessions in a dedicated Linux
  VM; the agent loop runs on the device. Do not say "Cowork can't run code".
  (`support.claude.com/.../14479288`; 2026-10-06 is the cutoff for local and scheduled tasks on
  Pro/Max/Ultra devices, not a default-change date)
- Cowork can: connect local folders, create docx/xlsx/pptx, use a browser, connectors (MCP),
  scheduled tasks, projects + memory, sub-agents, plugins (shared with Code via the account).
- **Documented gaps vs Code**: no terminal for the user; git inside Cowork not documented as a
  feature (the desktop page only says to ask Cowork to troubleshoot Git errors); does not read `~/.claude` (no CLAUDE.md, no settings hooks,
  no local skills); no plan mode (Auto/Manual only); no `/clear` `/compact` `/context`
  equivalents documented; no headless `claude -p`, CI, or SDK; no SSH to remote machines;
  sessions cannot be shared; plugin `bin/`, LSP, output styles are Code-only.
  (`claude.com/docs/plugins/platform-support`, `code.claude.com/docs/en/desktop`,
  `code.claude.com/docs/en/overview`)
- Plain chat: uploads up to 30 MB; file creation needs "code execution and file creation" on;
  server-side ephemeral filesystem, "no code runs on the local machine"; finished files come
  back as downloads. Incognito chats cannot create files or run code.
- **Rate limits are one shared pool** across chat, Cowork and Code ("shared across Claude and
  Claude Code"; 5-hour + weekly on Pro/Max; Ultra has a weekly limit only). Chat is "Lower
  intensity"; Claude Code and Cowork "consume tokens at a significantly higher rate than standard
  chat". (`support.claude.com/.../11145838`, `.../14782391`)
- **Code is not just for coding** (official evidence): Anthropic's 2026-06-16 usage research
  (~400K sessions): writing + data analysis rose from ~10% to ~20% of Code sessions; "domain
  expertise, and not coding proficiency, amplifies effective use". Terminal guide: "You don't
  need to know how to code." Claude Code can produce Claude Docs/exports; `pdf`/`xlsx` skills
  always sync into Code, docx/pptx account skills sync at ≥2.1.273; "How Anthropic teams use
  Claude Code" (legal, marketing, design); finance agents ship in both.
  (`anthropic.com/research/claude-code-expertise`, `code.claude.com/docs/en/terminal-guide`,
  `claude.com/blog/how-anthropic-teams-use-claude-code`)
- Desktop app embeds Code: "In the Claude Desktop app, Claude Code is the Code tab."
- Separate product to mention, not teach: **Claude Science** (beta desktop app, Python/R sandbox,
  SSH to Slurm). Not stated to be built on Code.
- Not documented: Cowork default model, user shell access, git, package install, file-size or
  session limits, Cowork-specific rate limits.
