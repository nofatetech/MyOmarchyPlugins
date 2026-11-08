#!/usr/bin/env bash
# launch.sh <template-id> <project-dir>: open a project in its template's apps.
. "$(dirname "$0")/common.sh"
tpl="$(template_dir "$1")"; dir="$2"
if [ -z "$tpl" ]; then setsid -f xdg-open "$dir" >/dev/null 2>&1; exit 0; fi
jq -r '.launch[]?' "$tpl/template.json" | while IFS= read -r cmd; do
  cmd="${cmd//\{dir\}/$dir}"
  (cd "$dir" && setsid -f bash -c "$cmd" >/dev/null 2>&1)
done
