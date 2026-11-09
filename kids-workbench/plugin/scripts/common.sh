# Shared settings. Sourced by the other scripts.
# pwd -P resolves the plugin symlink, so KW_ROOT is the real repo folder
# (it holds plugin/ and standards/).
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
KW_ROOT="$(cd "$PLUGIN_DIR/.." && pwd -P)"
USER_TEMPLATES="${XDG_CONFIG_HOME:-$HOME/.config}/kids-workbench/templates"
PROJECTS_DIR="${KIDS_WORKBENCH_PROJECTS:-$HOME/Projects}"
STANDARDS_DIR="$KW_ROOT/standards"

# Print the template directory for an id (user templates win over built-in).
template_dir() {
  [ -n "${1:-}" ] || return 0
  if [ -f "$USER_TEMPLATES/$1/template.json" ]; then echo "$USER_TEMPLATES/$1"
  elif [ -f "$PLUGIN_DIR/templates/$1/template.json" ]; then echo "$PLUGIN_DIR/templates/$1"
  fi
}

standards_version() { tr -d '[:space:]' < "$STANDARDS_DIR/VERSION" 2>/dev/null; }

# Version of a template's managed layer ("" if it has none).
template_version() {
  local tpl; tpl="$(template_dir "$1")"
  [ -n "$tpl" ] && [ -f "$tpl/managed/VERSION" ] && tr -d '[:space:]' < "$tpl/managed/VERSION"
}
