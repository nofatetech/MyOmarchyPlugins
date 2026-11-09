#!/usr/bin/env bash
# open-project.sh <project-dir>: re-open a project the way its template says.
. "$(dirname "$0")/common.sh"
dir="$1"; t=""
[ -f "$dir/project.json" ] && t=$(jq -r '.template // empty' "$dir/project.json")
exec "$(dirname "$0")/launch.sh" "$t" "$dir" open
