#!/usr/bin/env bash
# Replace .kids-workbench/ with the newest standards from the Kids Workbench source.
here="$(cd "$(dirname "$0")/../.." && pwd)"
source_dir="$(jq -r '.source // empty' "$here/.kids-workbench/STATE.json")"
if [ -z "$source_dir" ] || [ ! -x "$source_dir/plugin/scripts/sync-project.sh" ]; then
  echo "Cannot find the Kids Workbench source ($source_dir). Is it still on this computer?" >&2; exit 1
fi
exec "$source_dir/plugin/scripts/sync-project.sh" "$here"
