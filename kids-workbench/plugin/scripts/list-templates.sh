#!/usr/bin/env bash
# Print all templates (built-in and user) as a JSON array.
. "$(dirname "$0")/common.sh"
for base in "$PLUGIN_DIR/templates" "$USER_TEMPLATES"; do
  [ -d "$base" ] || continue
  for d in "$base"/*/; do
    [ -f "$d/template.json" ] || continue
    jq --arg id "$(basename "$d")" '. + {id: $id}' "$d/template.json"
  done
done | jq -s 'unique_by(.id)'
