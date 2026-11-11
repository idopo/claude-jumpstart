# How this repo and deck were built — a running log

This file is a teaching exhibit. It records, session by session, how Claude Code and GSD were
actually used to produce the presentation about Claude Code and GSD. Every entry names the
technique, what it bought us, and what it would have cost to skip it. Keep appending; do not
polish into a narrative.

Format per entry: **date — session — what happened — technique — why it matters on stage**.

---

## 2026-11-01 — Session 1: from a brain-dump to a GSD idea document

**Starting point.** One long, unstructured message from Ido listing ~15 topics (models,
prompting, plan mode, GSD, challenging plans, context rot, knowledge bases, handoff, skills,
CLAUDE.md, Windows/Git Bash) plus the end products (pptx + support repo + PowerShell installer).
Claude was running inside the `mics-backend` project, in auto permission mode.

**1. Inventory before inventing (3 shell calls).** Before writing anything, Claude searched the
machine for assets the message hinted at ("there is a PowerShell script here somewhere"):

- found `~/claude-windows-setup/setup-claude-windows.ps1` (14.7 KB, already installs Git for
  Windows, Node, Claude Code, GSD) and its companion `CLAUDE_AND_GSD_GUIDE.md`;
- found the handoff / continue-session commands in `~/.claude/commands/`;
- found the GSD install (v1.42.3) and read its `new-project` workflow to learn it has an `--auto`
  flag that consumes an idea document;
- found an unrelated earlier onboarding prompt (`professor-claude-onboarding/`) and marked it
  "reference only".

*Technique:* grep the environment before planning. *On stage:* the difference between "write me
an installer" (rewrites 14 KB that already exists) and "find the installer and reuse it".

**2. Fact-check delegated to a subagent — main context stayed light.** The talk makes ~40
factual claims about Claude Code (modes, models, CLAUDE.md limits, Windows behaviour). Checking
them means fetching a dozen doc pages (~170 K tokens of reading). Claude spawned one
`claude-code-guide` subagent with a numbered list of claims and kept working on the curriculum
while it ran. The subagent returned a ~2-page report; only that report entered the main context.

| | Tokens that would have entered the main context |
|---|---|
| Doing the fact-check inline | ~170 K (every fetched docs page) |
| Delegating it | ~4 K (the report) |

*Technique:* delegate reads, keep conclusions. *On stage:* this is section 5 (context) made
concrete — the main session's context after a 2-hour planning session was still small enough to
keep reasoning well.

**3. The fact-check corrected the presenter, not just the slides.** Ido's brief said "Windows
users should work from Git Bash, it uses fewer tokens and is faster". The docs say: Git for
Windows is optional, without it Claude falls back to a PowerShell tool, the hosting terminal is
irrelevant, and no token/speed difference is documented. The slide now says what is documented
and labels the rest as experience. The subagent also surfaced that `/ultraplan` was removed, that
there are six permission modes (not five), and that sessions start in auto mode.

*Technique:* never put a belief on a slide without a URL. *On stage:* section 4 ("keep the science
yours") — the same discipline applied to the model's own claims applies to ours.

**4. Working-directory constraint → the honest answer was "run GSD from a new session".**
Claude's shell was pinned to `mics-backend`; GSD writes `.planning/` into the current directory
and spawns subagents that do the same. Running `/gsd-new-project` from inside `mics-backend`
would have polluted that project's planning folder. Instead Claude created `~/claude-jumpstart/`,
wrote `IDEA.md` there, and handed Ido the exact command to run in a fresh session in that
directory.

*Technique:* know the tool's cwd assumptions; do not fight them. *On stage:* GSD section — one
project, one directory, one `.planning/`.

**5. The idea document is the plan's input, not the plan.** `IDEA.md` holds vision, audience,
reusable assets with paths, the ordered curriculum, deliverables, out-of-scope and assumptions.
GSD's `--auto` flow turns it into PROJECT.md → research → REQUIREMENTS.md → ROADMAP.md. The
curriculum order was chosen so that each section ends with the problem the next one solves, and
GSD comes last because it composes everything before it.

*On stage:* section 7 — "a phase is a broad subject". The whole deck is one project with five
phases; one phase is "the jumpstart repo", not "write README.md".

**6. Next step (to be logged by the next session).** Run, in a new terminal:

```
cd ~/claude-jumpstart
claude
/gsd-new-project --auto @IDEA.md
```

Then review ROADMAP.md the way the talk teaches: read it, ask for an artifact, challenge it
("what did you add that IDEA.md did not ask for?").

**7. Scope addition handled as a plan edit, not a rewrite.** Ido added a topic mid-session
(Cowork vs Code, conclusion "Code is not just for coding"). Claude did not reopen the whole
curriculum: it found the one section where the topic belongs (section 1, "what you are talking
to", as a three-rung ladder chat → Cowork → Code), added a callback in the closing section, and
spawned a second subagent to verify Cowork facts from official sources while editing continued.
The main context again received only the report.

*Technique:* additive edits to the idea document; verification delegated. *On stage:* section 7 —
adding a feature to an existing GSD project is an edit to `.planning/`, not a new project.

**8. The second fact-check changed the slide's premise.** The brief assumed "Cowork vs Code" are
two products. The subagent found Cowork was merged into chat on 2026-09-16 and that Cowork does
run code (cloud sandbox). The section-1 ladder was rewritten before a single slide existed:
chat → Claude-with-Cowork-capabilities → Code, with the Code-only list limited to documented
gaps (terminal, git, CLAUDE.md, plan mode, hooks, local skills, headless, SSH). The "not just
for coding" conclusion got official evidence (Anthropic's own usage research) instead of
anecdote.

*Technique:* verify the premise, not only the details. *On stage:* section 4 — the model will
happily build on a wrong premise if you do not check it; so will we.

**9. GSD initialisation run from the "wrong" directory, deliberately.** Ido asked for the GSD
project to be created in this session rather than a new one. Claude's shell is pinned to
`mics-backend`, so every GSD command was prefixed with `cd /home/ido/claude-jumpstart &&` and
every subagent prompt carried a "your cwd is a different project, use absolute paths" note. The
SDK's init check confirmed `project_root` before anything was written.

The config questions GSD asks were answered once and saved to Claude's auto-memory ("Opus for
planning, Sonnet for execution, interactive, recommended agents, one broad phase with many
plans — don't ask again"). The SDK rejected `model_overrides` through its CLI, so it was written
into `config.json` directly and the init query re-run to prove the resolver now returns Opus for
researchers and roadmapper.

Four `gsd-project-researcher` agents (stack, features, architecture, pitfalls) were spawned in
one message, each told to write to an absolute path and not to commit.

*Technique:* verify the tool's view of the world (init JSON) before trusting your own; save
standing answers to memory so the next session does not re-ask. *On stage:* section 6 (memory)
and section 7 (GSD config, what `.planning/config.json` holds).

**10. A format change arrived mid-research and was absorbed in the planning docs, not the
roadmap.** While the four researchers were still running, Ido said the audience will not have
computers; only the presenter does. That deletes audience exercises and the install window and
makes captures the demo medium. Claude edited `IDEA.md` and `PROJECT.md` (requirements,
constraints, a key decision) before the roadmapper ran, so the roadmap is derived from the
corrected inputs instead of being patched afterwards. The researchers' reports stay valid; the
ones that assumed exercises are simply read with that column dropped.

*Technique:* change the inputs upstream of the next agent, not its output. *On stage:* section 7
— `.planning/PROJECT.md` is where scope changes go first.

**11. Four researchers, one synthesizer, one roadmapper — and what came back.** The four
`gsd-project-researcher` agents (stack, features, architecture, pitfalls) wrote ~1,300 lines
of research directly to disk; only their ~1-page reports entered the main context. Between them
they overturned three assumptions in the brief: the GSD package the installer uses is deprecated
(successor: GSD Core, Node ≥ 24, different install path), the demo must run *outside* this repo
(GSD walks up to a parent `.planning/`), and the "models over-deliver" slide must be shown with a
capture because the docs say the opposite about code scope. The synthesizer's file write was
blocked by the harness ("subagents return findings as text"), so it returned SUMMARY.md as text
and the orchestrator wrote it — the fallback cost one copy of the summary in context, nothing
else. The roadmapper then ran on Opus with PROJECT.md, REQUIREMENTS.md and SUMMARY.md as inputs.

| Agent | Tokens it spent | What entered the main context |
|---|---|---|
| Stack researcher | ~139 K | ~1 page |
| Features researcher | ~113 K | ~1 page |
| Architecture researcher | ~103 K | ~1 page |
| Pitfalls researcher | ~161 K | ~1 page |
| Synthesizer | ~111 K | the summary itself (~3 K) |

*Technique:* parallel researchers on independent dimensions; the orchestrator only ever reads
summaries. *On stage:* section 5 (why the main session stays sharp) and section 7 (what
`/gsd-new-project` actually does behind the banner).

**12. Roadmap approval and discuss-phase in two answers.** GSD proposed five phases; Ido
answered "one phase for all of it, separate plans", the roadmapper was re-run with that note and
produced one phase with five dependency-ordered plan groups. Discuss-phase then offered four
gray areas; Ido's single reply ("we're building this for other Windows users; nothing changes on
my machine") locked two decisions and delegated the rest, so CONTEXT.md records 13 decisions, 11
of them as Claude's discretion derived from the research, with the delegation noted.

*Technique:* the presenter answers only what only the presenter can answer; everything else is
decided from evidence and written down as a decision, not left implicit. *On stage:* section 7
— reviewing a plan is cheaper when the model has already written its own decisions out.

**13. Wrong altitude, caught by the presenter.** The first sessions set this up as its own GSD
project with its own `.planning/`, "phase 1 of 1". Ido's objection: the lab's GSD project is
`mics-backend` with 47 phases; this is phase 48 of that project, nothing special because it is
"meta". He was right on two counts: one `.planning/` per team, phases per subject, is the model
the talk teaches; and mics-backend's 47 real phases are a far better section-7 exhibit than a
one-phase toy. The fix took one GSD command (`phase.add` → Phase 48), copying the research,
requirements and context into the phase folder from the jumpstart repo's git history, and
deleting `.planning/` from the deliverables repo. Nothing of the research was lost.

*Technique:* the human checks the shape of the plan, not only its contents. *On stage:* section 7
— "where does this live?" is the first challenge statement to make about any plan.

**14. "Do less" — the plan was cut in half before a single line of it ran.** The first planner
pass produced 25 plans in 14 waves: an isolated Claude profile to verify GSD Core, a package audit,
a Mac installer tested with stubs, a synthetic demo dataset, tmux-based capture tooling, a capture
manifest, a lint script for the deck, ten docs pages, fresh-profile tests. Ido read the plan
summary and answered in two lines: no isolated profile, the repo is just skills + the PowerShell
script + a bootstrap markdown, no Mac installer, do less. CONTEXT.md, the requirements (38 → 16)
and the roadmap entry were rewritten, the 25 plans deleted unexecuted, and the planner re-run.

*Technique:* read the plan summary and cut; a plan that was never executed costs only the tokens
that wrote it. *On stage:* section 7 — "what did you add that I did not ask for?" is the
challenge that removed two thirds of this phase.

**15. Planning closed at 8 plans after five rounds of cutting.** The second planner run came
back at 8 plans; Ido then cut three more things from the plan summary alone (the curriculum file
out of the repo, the scientific skill shown instead of shipped, no installer run on any PC) and
added two (a git skill, a git slide) plus one structural change: the slide content is written as
a complete script, on Opus, before any build tooling, and he reviews it before a single slide is
built. The plan checker ran twice (0 blockers both times); its warnings were applied by a
targeted revision, not a replan. Final shape: wave 1 repo + content script, wave 2 build tool +
captures, wave 3 assembly, wave 4 rehearsal and tag. Two stops for Ido.

*Technique:* review the plan summary, not the plans; cut from the summary; add scope only as
named requirements with IDs so the checker can hold the planner to them. *On stage:* section 7 —
this is the whole "summary → challenge → smaller plan" loop in one phase.

**16. "Use the well-known one."** The plan had a hand-written `git-in-plain-words` skill. Ido:
"best to have a proper, well-known git skill". One fetch of the official plugin marketplace
showed Anthropic ships `commit-commands` (`/commit`, `/commit-push-pr`, `/clean_gone`); the
"undo in your own words" behaviour needs no skill at all, so it became six lines in the global
CLAUDE.md template. Less to maintain, and the slide can point at something the audience can
find by name.

*Technique:* before writing a skill, check the marketplace. *On stage:* section 6 (skills: what
exists already vs what you write yourself).

**17. "Make it look nice" — delegated, then overridden on two points.** Ido delegated the deck's
look. The decision: follow the installed Anthropic pptx skill's design rules (palette with one
accent, safe fonts, five layouts, a terminal box as the repeated motif, no accent bars, no
text-only slides) and make visual QA mandatory — LibreOffice in a small Docker image renders
every slide to PNG, the executor looks and fixes. The planner's first pass alternated dark and
light on nearly every slide and allowed captures wider than the box; both were overridden from
the plan summary before execution (dark only on the title, the GSD divider and the closing;
captures capped to what the box holds).

*Technique:* delegate taste to a documented design system, then read the plan for the two or
three choices a system cannot make for you. *On stage:* section 4 — delegation is not
abdication.

**48-01 — Two edits to the installer, and nothing else.** The Windows installer changed in two
places only: the GSD line (now GSD Core 1.19.0, pinned, no `@latest`) and the Node floor (24). It
ships untested on lab hardware and the README says so. The GSD guide was re-targeted to GSD Core,
and its config-knobs section was deleted rather than carried over unchecked.

*Technique:* change the minimum, lint it, and say plainly what was not tested. *On stage:* section 0 / section 7 — a small diff against a known-good script beats a rewrite, and an honest "untested" beats a hopeful one.

**48-02 — Commands become skills.** Two of Ido's slash commands, handoff and continue-session, were converted into SKILL.md files and made shell-neutral: Read, Write, Glob and Grep instead of mkdir and ls pipelines, and the continuation files now live in the project under `.claude/continuations/` instead of a home folder. A hand-written git skill was planned and then dropped at Ido's request in favour of Anthropic's official commit-commands plugin, because a well-known maintained plugin beats a home-made one. The lab data skill was cut too; the slide shows a real one instead. Every description starts "Use when the user says" because the description is what Claude matches against, so it should contain the phrases a person actually types.

*Technique:* convert, then strip every assumption about the shell and the machine. *On stage:* section 6 — a skill is a command with a trigger sentence, and a maintained one beats yours.

**48-03 — A prompt that installs the rest.** SETUP.md is modelled on the professor onboarding prompt: paste one file, Claude asks five questions, then installs skills, rules and a global CLAUDE.md, always asking before it touches an existing file. The project CLAUDE.md template was replaced by "run /init, then prune" at Ido's request, so Claude writes the draft and the member cuts it. Git is handled by Anthropic's official commit-commands plugin plus a six-line Git block in the global CLAUDE.md, instead of a home-made skill, again at Ido's request.

*Technique:* a setup prompt that asks before every write, and a checklist that prunes instead of a template that rots. *On stage:* section 6 — the best install script is a prompt the member can read first.

**48-04 — The script before the slides.** All 23 slides were written as plain text first (body, narration, the exact prompt shown, a quoted fact for every Claude Code claim, the capture each demo needs) before any rendering tool existed. One review round so far. Ido's challenge was three words long in spirit: simpler, principles, less history. The first draft read like a build log: phase numbers, plan counts, the story of how this talk was made, caveats stacked on caveats. The revision states one principle per slide and uses the demo as a single illustration; narration shrank from 5196 to 3368 words, project-history references fell from 41 to 9 (all on the GSD demo slide, where the real planning folder and the 25-to-8 cut are the point), and the 13 open "confirm or replace" markers were resolved by removing the anecdote slots rather than inventing anecdotes.

*Technique:* write the content before the tooling, and ask the reviewer what to cut, not what to add. *On stage:* section 3 / section 7 — the "what did you add that I did not ask for?" challenge works on prose too.

**48-05 — Looking at the slides, not the XML.** The validator passed on the very first build, and the first render still had real problems: the cheat-sheet cards clipped their two-line descriptions, a concept slide with only bullets left half the slide blank, the capture-pending box had its text touching the border, and the title slide wrapped its subtitle for no reason. None of that is visible in the file format; all of it is obvious in a PNG. So the loop is build, validate, render in a container, look at every layout, fix, re-render only the changed slides. The fit math (how many characters and rows a terminal box holds at 10 to 14 pt) is a small tested module, so a long capture shrinks, then truncates with a visible "more lines" marker instead of spilling off the slide.

*Technique:* a green validator is not a good-looking slide; render and look. *On stage:* section 3 — "what did you add that I did not ask for?" applies to your own output too: look at the result before you call it done.

**48-06 — Real captures, nothing staged.** Thirteen text captures, each with a source header. Real files: the README install section (00), mics-backend's CLAUDE.md (06), the es-query command with hosts removed (06), a continuation file (05), the live `.planning/phases` listing (07). Real prompts from the prompt history: the vague/specific pair (02), the "do less" turn (07), the task list (08), the git-skill challenge (03, with META entry 16). Not as planned: session transcripts could not be read (the harness blocked access to the projects folder), so there is no real `/context` screen (05 shows the META log's token numbers), no real over-reach transcript (04 is a labelled constructed example), and 03-git-undo is a scratch-repo run where Claude's reply is real but the revert was run by hand because the headless session had no Bash approval. 01's Haiku-vs-Opus lines are a real scratchpad run. The installer was not run on a lab PC in this phase (Ido's cut).

*Technique:* prefer sources that need no permission, and label every substitution on the capture itself. *On stage:* section 6 — a capture that says what it is beats one that looks more impressive.

**48-07 — Assembly: 23 slides, every capture real, every slide looked at.** The strict build caught three captures that overflowed at 10 pt (slides 03, 18, 20). Two of the three were mostly layout: the title-wrap estimate was too pessimistic and the demo slide wasted a row under the title, so fixing the estimate and the gap cleared slide 18 and shrank 03 and 20. Only two `capture_lines` ranges were then needed (03: 3-19; 20: 6-12 for the left capture). Visual QA of all 23 PNGs found one more defect, the cheat sheet grid crowding its title; no slide wording changed. All 49 Fact quotes matched FACTS_VERIFIED verbatim.

*Technique:* build strict first so overflow is an error, not a surprise; fix the estimator before trimming content. *On stage:* section 7 — "I told it to do less" applies to captures too: show the five lines that matter, not all eight.

**48-09 — Titles that carry the talk.** Ido looked at the rendered 23 slides and rejected the format: too much text, examples that took over the slides, and a talk that opened with installing things. The script was rewritten from the titles down: 23 slides became 17, the illustrations went from 13 captures to 3 short ones (a git undo, a labelled constructed over-reach, a six-line excerpt of a real skill), and the deck now opens with the three ways of working with Claude (chat, Cowork, Code); install and setup appear once, on "take it home" near the end. Every title is a sentence a listener could repeat, at most 70 characters so it fits the template's headline box, and the test is to read the titles alone, in order, and check that they tell the talk. Body text is capped at 30 words a slide; the narration and the quoted facts moved to the notes, and the ten captures no slide uses were deleted (they stay in git history).

*Technique:* write the titles first and read them alone. *On stage:* the deck itself.

**48-10 — The template draws the slides.** The hand-drawn pptxgenjs design system was dropped once the institute's own template arrived: matching its look by eye would always be a copy, while using the file is the real thing. The useful finding was that the template's look lives in its 58 sample slides (their own text boxes and pictures), not in its layouts, which carry no usable placeholders, so the build duplicates a prototype sample slide per layout, rewrites its text through the prototype's own runs, and deletes the samples. A second finding came from the render: Benton Sans is not supplied and fontconfig substitutes a monospace face, so body text is Arial. It took three render rounds: first build (all layouts right on the first look, text too small), larger sizes plus the org label rewritten in Arial, and one geometry fix for the two-column slide whose illustration ran into the footer line.

*Technique:* build from the organisation's template; render and look. *On stage:* none (tooling).

**48-11 — A skill from what was proven.** The wis-slides skill was written only after the template build worked and Ido approved the look, so it records findings rather than guesses: the assertion-title rule with its two-line cap, the prototype sample slide behind each layout, and the Benton Sans finding (not supplied, falls back to a monospace face, so body text is Arial). A three-slide sample deck was then built using only the skill's own instructions and passed the QA check.

*Technique:* turn a proven workflow into a skill, then follow the skill yourself once. *On stage:* teach slide (skills are for what you repeat).

**48-08 — Dark means structure.** Ido's first look at the template-built deck found it patchy: some slides black, some cream, the boxes slide without the logo strip, grey pages, petals on some. The fix was a rule, not taste: black pages only for the title, the three part dividers and the closing; every other slide cream with the same strip, title position and size, body start and footer. The same round added drawn illustrations (speech bubble, folder with cloud, terminal, chevron flows, PI/postdoc boxes, a context meter, cards, a step strip) as python-pptx autoshapes driven by a `[visual]` table in each slide's front matter, so they carry the brand colours and need no image files, and no title, body line or note changed (notes check 17/17). One render found a hidden cause: the columns sample's master paints a grey full-slide shape, so a cream slide background was not enough.

*Technique:* state the visual rule first, then make the build enforce it; keep illustration labels to words already on the slide. *On stage:* none (tooling).

**48-08 — One idea per divider.** Ido's content review of the rendered deck found three problems a titles-only reading had missed: a Part 1 divider that joined two unrelated ideas (bad asks, and undo), a PI/postdoc analogy he did not want, and a context slide that used the word "subagent" before anyone had said what context or a subagent is. Undo became its own part ("Every step can be undone, so you can work without fear"), the analogy slide went (its two working lines, scope it and see the code behind every number, moved into the science divider's notes), and a new slide explains context and subagents before the slide that says what to do about them. The skill example was swapped from the lab's Elasticsearch query to a constructed, generic summarise-session skill, because most of the room has never seen the lab's event store. Thin slides got one supporting line each (body cap 30 to 40 words); 18 slides, notes check 18/18.

*Technique:* read the rendered deck as a listener, not as the author; each divider carries one idea, and every term is explained before it is used. *On stage:* none (process).

**48-08 — Show the real thing, and what it leaves behind.** Ido's third review asked for two changes. The skills slide now shows six lines of the repo's own wis-slides skill, the one that built this deck, instead of a made-up example: the trigger, where the official template lives, a layout rule, the title rule and the build command, all in one file, so the next deck starts from the same place. The GSD slide now shows the whole loop with its checks: you challenge the plan, GSD replans and a plan checker verifies it before anything runs, verify-work checks the result, and every plan ends in a SUMMARY on disk. The notes say why that summary matters later (questions about what was done, context for the next session, control over what changed, a starting point for extending a finished task). They also say that planning starts from context and research, and that a phase is one broad topic split into plans, some of which run in parallel. The points layout takes at most four steps, so execute, verify and the summary share the last line.

*Technique:* use a real artefact from your own work as the example; show what a workflow leaves on disk, not only what it does. *On stage:* teach and GSD slides.

**48-08 — Teach the habits you actually use.** Ido's fourth review asked for more on the things he does every day, not only on what Claude Code is: more on GSD and how to work with it, more on context, subagents and handoff, and how to get a subagent (by asking, or by letting a framework spawn them). He also described a habit of his own: asking Claude to present a plan as an artifact, a rendered page he can read and challenge. Six slides were added (18 to 24). One comes right after "plan first", for the artifact review. Two go in part three, on how to spawn a subagent and on handing off through a continuation file; the handoff slide shows the real headings of the repo's handoff skill. Three go in part four, on starting a project, planning a phase (challenge, replan) and executing with summaries. FACTS_VERIFIED had nothing on artifacts. Before writing the slide, the docs page was read and an Artifacts section added, with quotes and the URL. Artifacts turned out to be documented ("it updates in place as the session continues"). In plan mode, Claude Code asks before the first publish. The cut path now goes to 76 minutes. Two of its cuts are new slides: GSD "start a project" and the artifact slide.

*Technique:* when a habit of yours is part of the lesson, check the docs before you claim anything about it; the docs may say more than you expected. *On stage:* the artifact, subagent, handoff and GSD slides.

**48-08 — Say more in the notes, not on the slide.** Ido's fifth review asked for a more detailed talk, with examples that could live in the presenter notes rather than on the slides, something concise that pins down the flow, a longer treatment of context, and a slide on looping, "how this really yields the best results". The slides stayed as they were (title, up to three lines, one drawn visual); the notes grew. Every content slide now carries one or two `Example:` lines, said aloud and never shown, and one `Bridge:` line, the sentence that leads to the next slide; the Bridge lines alone, collected in the curriculum, are the flow sheet. One running example, a reaction-time figure from one CSV per session, threads through all four parts, so the ask, the plan challenge, the undo, the handoff, the CLAUDE.md lines and the GSD phase are all the same piece of work. Three slides were added (24 to 27). A loop slide closes part one: one pass is a draft, each pass gives the model something concrete to react to, loop on what you can check, exit after two failed corrections, and GSD is the same loop at project scale; it needed a new drawn visual, a chevron row with an orange return arrow (`cycle`, built test-first). Context went from two slides to four: what it is, what fills it and how fast (files read whole, test output, pasted documents, CLAUDE.md on every session), the signs it is degrading with a three-quarters rule for handing off, then the three habits. The 90 minutes held by taking one minute from thirteen older slides; the cut path is 79.

*Technique:* when a talk needs more depth, put it in the notes and the examples; the slide is the claim, the notes are the evidence. *On stage:* the loop slide, and the four context slides.

**48-08 — The loop that checks itself.** Ido rejected the first loop slide: it described his own corrections as the loop, and he meant the harness's loop: plan, verify, fix, with a cap, the way GSD's planner and checker revise a plan at most three times. The slide was rewritten around three parts, a check Claude can run itself (a test, a validator, a plan reviewer), an instruction to fix and rerun until it passes, and a cap of three rounds with a report; the examples are a test loop, a figure checked against a three-item list, and GSD's revision loop, whose cap was read from the GSD source and added to the repo's GSD guide. He also found the noun "ask" awkward on the Part 1 slides; "prompt" replaced it in titles, kicker, body and notes, with the verb kept where it is a verb.

*Technique:* when the presenter says a slide is wrong, ask what they meant before rewording; the fix here was a different idea, not a different sentence. *On stage:* the loop slide.

**48-08 — Rehearsed, re-checked, released.** Timed rehearsal: not yet run at release; the deck was released after five content rounds so the facts and tag would not drift while the date was fixed, and the rehearsal (full run and the 79-minute cut path from the curriculum) is Ido's to time before the session. Facts re-check on 2026-11-02 against the live docs, four changes: new sessions start in auto only on Claude Code 2.1.283 or later (the best-practices page still says it unconditionally; the permission-modes page owns it); Cowork's sandbox is per session, cloud by default, with the agent loop on the device, and 2026-10-06 was never a default-change date; the merger quote lives on the claude.com article, not the support article, and the Enterprise status is softer than "GA"; and "higher token intensity" was never on the rate-limits page, which says Code and Cowork "consume tokens at a significantly higher rate than standard chat". Sixteen other bullets could not be verified on the cited pages and are listed in the plan summary; none is quoted by a slide. The ~/.claude hash list differed in one file, a `.last-complete-round` marker that Claude Code's skill sync rewrites on its own; nothing this phase did touches it. GSD 1.42.3, no gsd-core. Remote: the default, a private GitHub repo idopo/claude-jumpstart, tagged v1.

*Technique:* re-verify every quoted fact within a week of the talk; the docs moved four times in one day. *On stage:* the take-it-home slide — the repo the room clones is the one tagged v1.

**48-08 — A divider is not a slide.** After the v1 tag Ido noticed that the Part 3 divider, "Models over-deliver, so you keep the scientific decisions", led straight into the context slides: the claim had no content slide of its own since round 2 moved the PI/postdoc analogy's two working lines into the divider's notes. A titles-only reading had hidden it, because the divider title reads like a slide. Round 6 adds 13-scope right after the divider: over-delivery looks like help (one column asked, two sessions dropped and a p-value added), say "do only X" and make it ask before changing what is in or out, and a number you did not see computed is not a result. The divider's notes shrink to a part introduction and a bridge. 28 slides; the 90 minutes hold by a minute each from 03, 10 and the divider.

*Technique:* every divider's claim must be carried by the next slide, not by the divider's notes. *On stage:* slide 13.

**48-08 — Fonts the deck never shows.** On the presenting Mac, PowerPoint reported two missing fonts, "Ezer Doo TRIAL ONLY" and "Weizmann BETA 5", although no slide uses either: they come from the template's masters (the Hebrew text style and an older headline build) and its embedded-font list. A post-build step (deck/wis_fonts.py, written test-first) remaps the two faces to Arial and Weizmann in every part and removes their embedded copies and relationships; the deck now embeds only Benton Sans and Weizmann. The four Weizmann OTFs still need installing on the presenting machine for editable headlines.

*Technique:* when a tool reports something missing, find every part that references it; the slides are not the only parts. *On stage:* none (tooling).
