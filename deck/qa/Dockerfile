# Purpose: render the deck to PNG for visual QA.
# Build with: docker build -t jumpstart-qa deck/qa
# Carlito/Caladea/Liberation are metric-compatible with Calibri/Cambria/Courier New,
# so text fit in the render matches PowerPoint.
FROM debian:trixie-slim@sha256:f6b08b09a05725f9431502d3b5714f5c4576e82c1a84fa1debe0c24a7e0c3ec4

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      libreoffice-impress poppler-utils imagemagick \
      fonts-crosextra-carlito fonts-crosextra-caladea fonts-liberation \
 && rm -rf /var/lib/apt/lists/*
