#!/usr/bin/env bash
# Claude Code SessionStart hook. Lives in the project, not the core, because the core
# may not be fetched yet on a fresh clone. Sets everything up, starts the preview,
# then hands over to the core's session hook (kickoff questions or the brief).
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0

if ! ./scripts/setup.sh; then
  echo "Build Kit: could not fetch the shared core. Tell the person to check their internet connection and access to GitHub."
  exit 0
fi

preview() {
  if ! command -v npm >/dev/null 2>&1; then
    echo "Build Kit: Node.js is not installed, so the preview can't start. Ask the person if you may run 'brew install node', then run ./scripts/session-start.sh again."
    return
  fi
  if [ ! -d node_modules ]; then
    if ! log="$(npm install --no-audit --no-fund --loglevel=error 2>&1)"; then
      echo "Build Kit: npm install failed, so the preview can't start. Fix the cause, then run ./scripts/session-start.sh again. The error:"
      printf '%s\n' "$log" | tail -15
      return
    fi
  fi
  # Reuse this project's own preview if it runs, otherwise start one on the first free port from 8000.
  for port in 8000 8001 8002 8003 8004 8005; do
    pid="$(lsof -ti "tcp:$port" -sTCP:LISTEN 2>/dev/null | head -1)"
    if [ -n "$pid" ]; then
      if [ "$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')" = "$(pwd -P)" ]; then
        echo "Build Kit: the preview is running at http://localhost:$port and updates as files change. Tell the person the link."
        return
      fi
      continue
    fi
    nohup npx --no-install vite --port "$port" --strictPort > .vite-preview.log 2>&1 &
    disown
    for _ in $(seq 1 30); do
      if curl -fsS "http://localhost:$port/" >/dev/null 2>&1; then
        echo "Build Kit: the preview is running at http://localhost:$port and updates as files change. Tell the person the link."
        return
      fi
      sleep 0.5
    done
    echo "Build Kit: the preview did not start. The last lines of .vite-preview.log:"
    tail -15 .vite-preview.log
    return
  done
  echo "Build Kit: ports 8000 to 8005 are all in use, so the preview isn't running. Ask the person to close an old preview."
}
preview

exec .core/hooks/adapters/claude/session-start.sh
