# Standards changelog

Written for agents: each entry says what changed, how to migrate a project, and how to check it.
A project's current version is in `.kids-workbench/STATE.json` (`standards`).

## 0.1.1 - shared services
- The shared services exist: Caddy (`<name>.kids-workbench.localhost`), php-fpm, Postgres, Mailpit, Adminer.
  Documented in `naming.md` (addresses, reserved slugs `db mail www api admin`) and `architecture.md`.
- Migration: none required. Projects do not need their own web server. Use `php artisan serve` only if the shared
  Caddy is not running. For Postgres, run `kids-workbench db create <name>` and put the printed lines in `.env`.
- Check: `.kids-workbench/scripts/test.sh` passes; the app opens at `http://<name>.kids-workbench.localhost/`.

## 0.1.0 - initial
- First version of the standards: naming, architecture, conventions, guardrails, testing.
- Migration: none (new projects start here).
- Check: `.kids-workbench/scripts/test.sh` passes.
