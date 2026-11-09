#!/usr/bin/env bash
# Print project folders (newest first) as a JSON array.
. "$(dirname "$0")/common.sh"
[ -d "$PROJECTS_DIR" ] || { echo "[]"; exit 0; }
now=$(date +%s)
find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d -not -name '.*' -printf '%T@ %p\n' | sort -rn | head -30 |
while read -r ts path; do
  ts=${ts%.*}; icon="📁"; web=false
  if [ -f "$path/project.json" ]; then
    t=$(jq -r '.template // empty' "$path/project.json")
    tpl="$(template_dir "$t")"
    if [ -n "$tpl" ]; then icon=$(jq -r '.icon // "📁"' "$tpl/template.json"); web=$(jq -r '.web // false' "$tpl/template.json"); fi
  fi
  outdated=false
  if [ -f "$path/.kids-workbench/STATE.json" ]; then
    ps=$(jq -r '.standards // ""' "$path/.kids-workbench/STATE.json")
    pt=$(jq -r '.templateVersion // ""' "$path/.kids-workbench/STATE.json")
    pid=$(jq -r '.template // ""' "$path/.kids-workbench/STATE.json")
    if [ "$ps" != "$(standards_version)" ] || [ "$pt" != "$(template_version "$pid")" ]; then outdated=true; fi
  fi
  s=$((now - ts))
  if   [ $s -lt 3600 ];   then ago="$((s/60)) min ago"
  elif [ $s -lt 86400 ];  then ago="$((s/3600)) h ago"
  else ago="$((s/86400)) days ago"; fi
  jq -n --arg name "$(basename "$path")" --arg path "$path" --arg icon "$icon" --arg ago "$ago" --argjson outdated "$outdated" --argjson web "$web" \
    '{name:$name, path:$path, icon:$icon, ago:$ago, outdated:$outdated, web:$web}'
done | jq -s '.'
