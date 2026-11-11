#!/usr/bin/env bash
# Purpose: runs INSIDE the jumpstart-qa container (mounted at /qa): pptx -> pdf -> slide PNGs + grid.
# Usage: render.sh <in.pptx> <outdir> [pages]   (pages: comma list, re-renders only those slides)
set -euo pipefail

pptx="$1"
outdir="$2"
pages="${3:-}"
pdf="$outdir/$(basename "${pptx%.pptx}").pdf"

# Explicit profile dir: the host uid has no passwd entry in the container, so the default fails.
timeout 300 soffice --headless --norestore -env:UserInstallation=file:///tmp/lo --convert-to pdf --outdir "$outdir" "$pptx" >/dev/null

if [ -z "$pages" ]; then
  rm -f "$outdir"/slide-*.png
  pdftoppm -png -r 110 "$pdf" "$outdir/slide"
else
  IFS=',' read -ra list <<< "$pages"
  for n in "${list[@]}"; do
    pdftoppm -png -r 110 -f "$n" -l "$n" "$pdf" "$outdir/slide"
  done
fi

if command -v montage >/dev/null; then MONTAGE=(montage); else MONTAGE=(magick montage); fi
"${MONTAGE[@]}" "$outdir"/slide-*.png -tile 4x -geometry 440x248+6+6 -background white \
  -pointsize 14 -font /usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf \
  -label '%t' "$outdir/grid.png"
