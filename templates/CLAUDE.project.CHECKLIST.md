<!-- Structure follows https://code.claude.com/docs/en/memory . There is deliberately no project template: Claude writes the first draft, you prune it. -->
# Project CLAUDE.md checklist

1. In your project folder run `/init`.
2. Prune the result with these questions:
   - Is every line a command, a convention or a gotcha?
   - Can the agent read this from the code itself? If yes, delete it.
   - Is the file under 200 lines?
   - Are knowledge bases linked by path (for example `docs/data-format.md` - read before touching data), not pasted or @-imported?
3. Add a "Do not" block from templates/rules/keep-the-science-yours.md if the project is analysis.
4. Re-run the questions after a month.
