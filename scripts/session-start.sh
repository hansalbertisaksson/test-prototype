#!/usr/bin/env bash
# Claude Code SessionStart hook. Lives in the project, not the core, because the core
# may not be fetched yet on a fresh clone. Sets everything up, starts the preview,
# then hands over to the core's session hook (kickoff questions or the brief).
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0

if ! ./scripts/setup.sh; then
  echo "Build Kit: could not fetch the shared core. Tell the person to check their internet connection and access to GitHub."
  exit 0
fi

# Install the app the first time, then start the Vite preview. It updates as files change.
if ! command -v npm >/dev/null 2>&1; then
  echo "Build Kit: Node.js is not installed, so the preview can't start. Ask the person if you may run 'brew install node', then run ./scripts/session-start.sh again."
  exec .core/hooks/adapters/claude/session-start.sh
fi
[ -d node_modules ] || npm install --no-audit --no-fund --loglevel=error >/dev/null 2>&1
port=8000
if ! (exec 3<>/dev/tcp/127.0.0.1/$port) 2>/dev/null; then
  nohup npx --no-install vite --port $port --strictPort >/dev/null 2>&1 &
  disown
fi
echo "Build Kit: the preview is running at http://localhost:$port and updates as files change. Tell the person the link."

exec .core/hooks/adapters/claude/session-start.sh
