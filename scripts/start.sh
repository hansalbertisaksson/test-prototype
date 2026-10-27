#!/usr/bin/env bash
# For working without Claude: sets up the core and the checks, builds the site and starts a preview.
# With Claude Code you don't need this, opening the project does the same.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
./scripts/setup.sh
echo "Core at $(git -C .core rev-parse --short HEAD), local checks on"
.core/hooks/checks/run.sh || true
.core/scripts/build-site.sh
if [ "${1:-}" != "--no-serve" ]; then
  echo "Preview at http://localhost:8000 (Ctrl+C to stop)"
  python3 -m http.server 8000 --directory _site
fi
