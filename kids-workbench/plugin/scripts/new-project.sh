#!/usr/bin/env bash
# new-project.sh <template-id>: copy the template into a new project folder,
# then open it. Prints the new folder path.
set -euo pipefail
. "$(dirname "$0")/common.sh"
id="$1"; tpl="$(template_dir "$id")"
[ -n "$tpl" ] || { echo "no such template: $id" >&2; exit 1; }

adj=(brave sunny quick clever wild cosmic tiny mighty happy lucky)
noun=(fox rocket otter comet badger robot dragon owl panda falcon)
base="${adj[RANDOM % ${#adj[@]}]}-${noun[RANDOM % ${#noun[@]}]}"
mkdir -p "$PROJECTS_DIR"
dir="$PROJECTS_DIR/$base"; n=2
while [ -e "$dir" ]; do dir="$PROJECTS_DIR/$base-$n"; n=$((n+1)); done
mkdir -p "$dir"
[ -d "$tpl/starter" ] && cp -r "$tpl/starter/." "$dir/"

title="${base//-/ }"
{ grep -rIl "__NAME__" "$dir" 2>/dev/null || true; } | while IFS= read -r f; do sed -i "s/__NAME__/$title/g" "$f"; done
jq -n --arg t "$id" --arg d "$(date -Iseconds)" '{template:$t, created:$d}' > "$dir/project.json"

"$(dirname "$0")/launch.sh" "$id" "$dir"
echo "$dir"
