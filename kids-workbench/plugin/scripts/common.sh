# Shared settings. Sourced by the other scripts.
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_TEMPLATES="${XDG_CONFIG_HOME:-$HOME/.config}/kids-workbench/templates"
PROJECTS_DIR="${KIDS_WORKBENCH_PROJECTS:-$HOME/Projects}"

# Print the template directory for an id (user templates win over built-in).
template_dir() {
  if [ -f "$USER_TEMPLATES/$1/template.json" ]; then echo "$USER_TEMPLATES/$1"
  elif [ -f "$PLUGIN_DIR/templates/$1/template.json" ]; then echo "$PLUGIN_DIR/templates/$1"
  fi
}
