#!/usr/bin/env bash
# Install Kids Workbench into the current user's Omarchy shell:
# symlink the plugin and enable it in shell.json (backup kept next to it).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
id="myomarchy.kids-workbench"
plugins="$HOME/.config/omarchy/plugins"
cfg="$HOME/.config/omarchy/shell.json"

mkdir -p "$plugins"
ln -sfn "$here/plugin" "$plugins/$id"

if ! jq -e --arg id "$id" '(.plugins // []) | any(.id == $id)' "$cfg" >/dev/null; then
  cp "$cfg" "$cfg.pre-kids-workbench"
  jq --arg id "$id" '.plugins = ((.plugins // []) + [{id: $id}])' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
  echo "Enabled $id in $cfg (backup: $cfg.pre-kids-workbench)"
fi
echo "Installed. Toggle with: omarchy-shell myomarchy.kids-workbench toggle"
