#!/usr/bin/env bash
# Remove Kids Workbench from the shell (projects in ~/Projects are untouched).
set -euo pipefail
id="myomarchy.kids-workbench"
cfg="$HOME/.config/omarchy/shell.json"
jq --arg id "$id" '.plugins = ((.plugins // []) | map(select(.id != $id)))' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
rm -f "$HOME/.config/omarchy/plugins/$id"
echo "Removed $id"
