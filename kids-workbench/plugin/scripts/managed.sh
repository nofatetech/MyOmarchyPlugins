# install_managed <project-dir> <template-id>
# (Re)create <project-dir>/.kids-workbench from the central standards and the
# template's managed/ folder. Safe to run again: it is a plain replace.
. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

install_managed() {
  local dir="$1" id="$2" tpl m
  tpl="$(template_dir "$id")"
  m="$dir/.kids-workbench"
  rm -rf "$m"
  mkdir -p "$m/standards"
  cp "$STANDARDS_DIR"/*.md "$m/standards/"
  mv "$m/standards/CHANGELOG.md" "$m/CHANGELOG.md"
  [ -n "$tpl" ] && [ -d "$tpl/managed" ] && cp -r "$tpl/managed/." "$m/"
  rm -f "$m/VERSION"
  jq -n --arg standards "$(standards_version)" --arg template "$id" \
        --arg tversion "$(template_version "$id")" --arg source "$KW_ROOT" --arg at "$(date -Iseconds)" \
    '{standards:$standards, template:$template, templateVersion:$tversion, source:$source, updated:$at}' > "$m/STATE.json"
  find "$m/scripts" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
}
