#!/usr/bin/env bash
# launch.sh <template-id> <project-dir> [new|open]: open a project the way its template says:
# an agent in a terminal (template.json "agent") and/or normal apps ("launch").
. "$(dirname "$0")/common.sh"
tpl="$(template_dir "$1")"; dir="$2"; mode="${3:-open}"
if [ -z "$tpl" ]; then setsid -f xdg-open "$dir" >/dev/null 2>&1; exit 0; fi
here="$(cd "$(dirname "$0")" && pwd -P)"

if [ "$mode" = "new" ]; then key="prompt"; else key="resume"; fi
prompt="$(jq -r --arg k "$key" '.agent[$k] // .agent.prompt // empty' "$tpl/template.json")"
[ -n "$prompt" ] && "$here/open-agent.sh" "$dir" "$prompt"

jq -r '.launch[]?' "$tpl/template.json" | while IFS= read -r cmd; do
  cmd="${cmd//\{dir\}/$dir}"
  (cd "$dir" && setsid -f bash -c "$cmd" >/dev/null 2>&1)
done
