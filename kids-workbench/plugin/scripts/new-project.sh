#!/usr/bin/env bash
# new-project.sh <template-id> [name]: copy the template into a new project
# folder named after [name] (a random fun name if empty), then open it.
# Prints the new folder path.
set -euo pipefail
. "$(dirname "$0")/common.sh"
id="$1"; tpl="$(template_dir "$id")"
[ -n "$tpl" ] || { echo "no such template: $id" >&2; exit 1; }

name="${2:-}"
if [ -z "${name//[[:space:]]/}" ]; then
  adj=(brave sunny quick clever wild cosmic tiny mighty happy lucky)
  noun=(fox rocket otter comet badger robot dragon owl panda falcon)
  name="${adj[RANDOM % ${#adj[@]}]} ${noun[RANDOM % ${#noun[@]}]}"
fi
# Folder name: lowercase, letters/digits/_/-, everything else becomes a dash.
base="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^[:alnum:]_-]+/-/g; s/^-+//; s/-+$//')"
[ -n "$base" ] || base="project"
mkdir -p "$PROJECTS_DIR"
dir="$PROJECTS_DIR/$base"; n=2
while [ -e "$dir" ]; do dir="$PROJECTS_DIR/$base-$n"; n=$((n+1)); done
mkdir -p "$dir"
[ -d "$tpl/starter" ] && cp -r "$tpl/starter/." "$dir/"

title="$name"
esc="$(printf '%s' "$title" | sed 's/[&|\\]/\\&/g')"
{ grep -rIl "__NAME__" "$dir" 2>/dev/null || true; } | while IFS= read -r f; do sed -i "s|__NAME__|$esc|g" "$f"; done
jq -n --arg t "$id" --arg n "$name" --arg d "$(date -Iseconds)" '{template:$t, name:$n, created:$d}' > "$dir/project.json"

"$(dirname "$0")/launch.sh" "$id" "$dir"
echo "$dir"
