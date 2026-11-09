#!/usr/bin/env bash
# One command to check the project. Prints a plain pass or fail for each layer.
cd "$(dirname "$0")/../.." || exit 1
fails=0
run() {
  local label="$1"; shift
  echo "▶ $label"
  if "$@"; then echo "  ✅ ok"; else echo "  ❌ failed"; fails=$((fails + 1)); fi
}
if [ ! -f artisan ]; then
  echo "No Laravel app yet. Run scripts/bootstrap.sh first."; exit 1
fi
run "Standards guards" ./vendor/bin/pest .kids-workbench/guards
run "Style (Pint)"     ./vendor/bin/pint --test
run "App tests"        php artisan test
echo
if [ "$fails" -eq 0 ]; then echo "🎉 Everything passes."; else echo "$fails check(s) failed."; exit 1; fi
