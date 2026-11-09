#!/usr/bin/env bash
# Check that the tools a web app needs are installed. Does not install anything.
missing=()
for c in git php composer node npm sqlite3; do
  if command -v "$c" >/dev/null 2>&1; then printf '  ✅ %s\n' "$c"; else printf '  ❌ %s\n' "$c"; missing+=("$c"); fi
done
if [ ${#missing[@]} -gt 0 ]; then
  echo
  echo "Missing: ${missing[*]}"
  echo "Installing tools changes the computer, so ask a grown-up or mentor to install them."
  exit 1
fi
echo "All tools found."
