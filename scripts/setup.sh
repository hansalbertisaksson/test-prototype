#!/usr/bin/env bash
# Gets the latest shared core into .core/ and turns on the git checks.
# .core/ is not part of this repo (see .gitignore), so updating it never shows up as a change.
# Safe to run any number of times. Used by start.sh and by the Claude session hook.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

core_url="https://github.com/hansalbertisaksson/test-core"
# macOS has no timeout command, so only use it where it exists.
t() { if command -v timeout >/dev/null 2>&1; then timeout "$@"; else shift; "$@"; fi; }
if grep -qs 'path = .core' .gitmodules; then
  # Older projects keep the core as a git submodule.
  git submodule update --init --remote -q .core 2>/dev/null
else
  # Tidy what an old .core submodule left behind in git's own folder.
  git config --remove-section submodule..core 2>/dev/null
  rm -rf "$(git rev-parse --git-dir)/modules/.core"
  [ -f .core/.git ] && rm -rf .core
  if [ -d .core/.git ]; then
    # Update in place. If it can't be reached, keep working with the copy we have.
    t 60 git -C .core fetch -q --depth 1 origin main 2>/dev/null && git -C .core reset -q --hard FETCH_HEAD
  else
    rm -rf .core
    t 120 git clone -q --depth 1 "$core_url" .core
  fi
fi
git config core.hooksPath .core/hooks/adapters/git
[ -f .core/AGENTS.md ]
