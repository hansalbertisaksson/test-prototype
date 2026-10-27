#!/usr/bin/env bash
# Gets the latest core, turns on the local checks and starts a preview.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

if [ -f .core/AGENTS.md ]; then
  git submodule update --init --remote .core
else
  git submodule update --init --remote .core 2>/dev/null || true
  if [ ! -f .core/AGENTS.md ]; then
    rm -rf .core
    git submodule add -f https://github.com/hansalbertisaksson/test-core .core
  fi
fi
echo "Core at $(git -C .core rev-parse --short HEAD)"

git config core.hooksPath .core/hooks/adapters/git
echo "Local checks on (git pre-commit)"

.core/hooks/checks/run.sh || true
.core/scripts/build-site.sh

if [ "${1:-}" != "--no-serve" ]; then
  echo "Preview at http://localhost:8000 (Ctrl+C to stop)"
  python3 -m http.server 8000 --directory _site
fi
