#!/usr/bin/env bash
# sync-launch.sh <project-dir>: update the managed folder, then open the agent to migrate.
here="$(cd "$(dirname "$0")" && pwd -P)"
dir="$1"
"$here/sync-project.sh" "$dir" >/dev/null 2>&1
exec "$here/open-agent.sh" "$dir" "The standards were just updated. Follow .kids-workbench/SYNC.md: read the changelog, migrate the project in small steps, explain what changes, run the tests, and commit."
