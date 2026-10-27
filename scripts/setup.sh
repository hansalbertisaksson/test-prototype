#!/usr/bin/env bash
# Gets the latest shared core into .core/ and turns on the git pre-commit check.
# Safe to run any number of times. Used by start.sh and by the Claude session hook.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

core_url="https://github.com/hansalbertisaksson/test-core"
git submodule update --init --remote -q .core 2>/dev/null
if [ ! -f .core/AGENTS.md ]; then
  rm -rf .core
  git submodule add -q -f "$core_url" .core 2>/dev/null || git clone -q --depth 1 "$core_url" .core
fi
git config core.hooksPath .core/hooks/adapters/git
[ -f .core/AGENTS.md ]
