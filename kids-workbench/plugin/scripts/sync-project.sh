#!/usr/bin/env bash
# sync-project.sh <project-dir>: replace the project's .kids-workbench/ with the newest
# standards and print what changed. The agent then migrates the project (SYNC.md).
set -euo pipefail
. "$(dirname "$0")/managed.sh"
dir="$(cd "$1" && pwd)"
state="$dir/.kids-workbench/STATE.json"
[ -f "$state" ] || { echo "Not a Kids Workbench project with standards: $dir" >&2; exit 1; }
id="$(jq -r .template "$state")"
old="$(jq -r .standards "$state")"; oldt="$(jq -r '.templateVersion // ""' "$state")"
install_managed "$dir" "$id"
new="$(standards_version)"; newt="$(template_version "$id")"
echo "Standards: $old -> $new"
echo "Template $id: ${oldt:-none} -> ${newt:-none}"
if [ "$old" = "$new" ] && [ "$oldt" = "$newt" ]; then echo "Already up to date."; else
  echo "Read .kids-workbench/CHANGELOG.md for the entries newer than $old, then migrate (see .kids-workbench/SYNC.md)."; fi
