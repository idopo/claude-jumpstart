#!/usr/bin/env bash
# Purpose: validate a deck, read it back with markitdown, render it to PNG in Docker.
# Usage: deck/qa/check.sh <deck.pptx> [--pages N,M]
# One-time setup: docker build -t jumpstart-qa deck/qa
#                 python3 -m venv deck/qa/venv && deck/qa/venv/bin/pip install "markitdown[pptx]==0.1.9" python-pptx==1.0.2 lxml defusedxml
#                 (no npm: the deck is built by deck/build.py)
set -euo pipefail

qa="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill="${PPTX_SKILL:-$HOME/.claude/plugins/marketplaces/anthropic-agent-skills/skills/pptx}"
pptx="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
pages=""
[ "${2:-}" = "--pages" ] && pages="${3:?--pages needs a comma list}"
mkdir -p "$qa/out"
fonts="$(cd "$qa/../brand/assets-2" && pwd)"

validation="$(PYTHONDONTWRITEBYTECODE=1 "$qa/venv/bin/python" "$skill/scripts/office/validate.py" "$pptx" --original "$qa/../brand/WIS-extended-english-template.pptx" 2>&1)" || true
echo "$validation"
echo "$validation" | /usr/bin/grep -q "All validations PASSED" || { echo "FAIL: validator" >&2; exit 1; }

"$qa/venv/bin/markitdown" "$pptx" > "$qa/out/readback.txt"
slides="$(/usr/bin/grep -c '<!-- Slide number' "$qa/out/readback.txt" || true)"
notes="$(/usr/bin/grep -c '### Notes:' "$qa/out/readback.txt" || true)"
echo "readback: $slides slides, $notes notes blocks"
[ "$slides" = "$notes" ] || { echo "FAIL: slides and notes counts differ" >&2; exit 1; }
if /usr/bin/grep -iEn '\bx{3,}\b|lorem|ipsum|\bTODO|\[insert|Slide Headline|Presentation Title|Body copy|Box text|Name Surname|January 1, 2023|SUBHEADING' "$qa/out/readback.txt"; then
  echo "FAIL: placeholder text in read-back" >&2
  exit 1
fi

docker run --rm --network none --user "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$(dirname "$pptx"):/in:ro" -v "$qa:/qa" -v "$fonts:/usr/share/fonts/truetype/wis:ro" jumpstart-qa \
  bash /qa/render.sh "/in/$(basename "$pptx")" /qa/out $pages

ls -1 "$qa"/out/slide-*.png "$qa/out/grid.png"
