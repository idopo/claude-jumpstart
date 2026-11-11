+++
title = "Ask for the plan as an artifact: a page you can read and challenge"
layout = "statement"
kicker = "Prompt well, plan first"
notes = '''
This is something I do all the time. A big plan in the terminal scrolls away, so I type one line:
"Present this plan as an artifact so I can review it."
Claude publishes it as a page on claude.ai and opens it in the browser. I read it top to bottom, then challenge it in the chat, as on the last slide. Claude edits the page and republishes to the same link, so the page always shows the current plan.
It stays private until I share it from the page, so a colleague can read the same plan. `/artifacts` finds it again, even after `/clear`.
In plan mode it asks before the first publish: say yes. It needs a paid plan and a claude.ai login.
Example: the pipeline plan came back as a page with the goal, the files it would touch, five steps and a risks list. I read it on the second screen, typed two challenges into the terminal, and watched the page change. The two-second outlier step disappeared from the page while I watched.
Live option: in a scratch repo, ask for a small plan, type that one line, open the page.
Fallback: describe the page: goal, files, steps, risks; the challenge goes in the chat.
Bridge: Plan, challenge, replan: that was a loop with you as the checker. Next, the loop that checks itself.
Fact: "it updates in place as the session continues." (FACTS_VERIFIED, Artifacts)
Fact: "Use an artifact when terminal text is the wrong medium for what Claude produced" (FACTS_VERIFIED, Artifacts)
Fact: "Claude edits the underlying file and publishes again to the same URL." (FACTS_VERIFIED, Artifacts)
Fact: "A new artifact is visible only to you." (FACTS_VERIFIED, Artifacts)
Fact: "`/artifacts` works in a new session and after `/clear`" (FACTS_VERIFIED, Artifacts)
Fact: "Asks before the first publish of each artifact" (FACTS_VERIFIED, Artifacts)
Fact: "Artifacts are available on Pro, Max, Ultra, Team, and Enterprise plans" (FACTS_VERIFIED, Artifacts)
Cut 4: this slide is skipped fourth; its line is said at the end of 06-plan-first.
'''

[visual]
kind = "cards"
highlight = "Artifact"
cards = [
  { label = "Terminal", text = "scrolls away" },
  { label = "Artifact", text = "a page, top to bottom" },
  { label = "Artifact", text = "one link to share" },
  { label = "Artifact", text = "updates as you challenge" },
]
+++

- Ask: "Present this plan as an artifact so I can review it"
- Read the page top to bottom; challenge it in the chat
- Claude republishes to the same link; share it with a colleague
