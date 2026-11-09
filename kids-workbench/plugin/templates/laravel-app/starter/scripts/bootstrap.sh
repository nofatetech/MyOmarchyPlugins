#!/usr/bin/env bash
# Create the Laravel app (Vue starter kit) inside this folder. Safe to re-run.
# Not clever on purpose: every project starts the same way.
set -euo pipefail
cd "$(dirname "$0")/.."

.kids-workbench/scripts/doctor.sh

if [ -f artisan ]; then echo "Already bootstrapped."; exit 0; fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "▶ Creating the Laravel app (this takes a few minutes)"
composer create-project laravel/vue-starter-kit "$tmp/app" --no-interaction --no-ansi

echo "▶ Moving it into this folder (our own files are kept)"
rm -rf "$tmp/app/.git"
cp -rn "$tmp/app/." .

echo "▶ Setting up"
[ -f .env ] || cp .env.example .env
php artisan key:generate --force
mkdir -p database && touch database/database.sqlite
php artisan migrate --force
# The starter kit pins PHPUnit, which blocks current Pest: swap PHPUnit for Pest (Pest brings its own).
if ! composer show pestphp/pest >/dev/null 2>&1; then
  composer remove --dev phpunit/phpunit --no-update --no-interaction --no-ansi
  composer require --dev pestphp/pest pestphp/pest-plugin-laravel -W --no-interaction --no-ansi
fi
npm install
npm run build

echo "▶ Formatting the starter code once (so the style check starts clean)"
./vendor/bin/pint >/dev/null

echo "▶ Checking"
.kids-workbench/scripts/test.sh || true

git add -A
git commit -q -m "Bootstrap Laravel app" || true
echo "Done. Next: tell the agent what you saw."
