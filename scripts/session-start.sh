#!/usr/bin/env bash
# Claude Code SessionStart hook. Lives in the project, not the core, because the core
# may not be fetched yet on a fresh clone. Sets everything up, starts the preview,
# then hands over to the core's session hook (kickoff questions or the brief).
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0

if ! ./scripts/setup.sh; then
  echo "Build Kit: could not fetch the shared core. Tell the person to check their internet connection and access to GitHub."
  exit 0
fi

.core/scripts/build-site.sh >/dev/null 2>&1
port=8000
if ! (exec 3<>/dev/tcp/127.0.0.1/$port) 2>/dev/null; then
  nohup python3 -m http.server $port --directory _site >/dev/null 2>&1 &
  disown
fi
echo "Build Kit: the preview is running at http://localhost:$port and rebuilds after every edit. Tell the person the link."

exec .core/hooks/adapters/claude/session-start.sh
