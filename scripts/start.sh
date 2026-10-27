#!/usr/bin/env bash
# For working without Claude: sets up the core and the checks, installs the app and starts a preview.
# With Claude Code you don't need this, opening the project does the same.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
./scripts/setup.sh
echo "Core at $(git -C .core rev-parse --short HEAD), local checks on"
.core/hooks/checks/run.sh || true
npm install --no-audit --no-fund --loglevel=error
if [ "${1:-}" = "--no-serve" ]; then
  .core/scripts/build-site.sh
else
  npm run dev
fi
