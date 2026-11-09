# Naming

The product name is **Kids Workbench**. Wherever a name is needed, derive it from that, in the
form the context allows:

| Form | Where | Why |
|---|---|---|
| `kids-workbench` | hostnames, folders, config dirs, packages, docker compose project, CLI | hyphens are legal in hostnames and paths |
| `kids_workbench` | database names, table prefixes, Python modules | underscores are legal there, hyphens are not |
| `KIDS_WORKBENCH_` | environment variables | convention |
| `KidsWorkbench` | PHP namespace, class names | PSR-4 |
| `Kids Workbench` | UI text, docs titles | human-facing |

## Hosts (Caddy)
- Project: `<name>.kids-workbench.localhost` (for example `space-dodger.kids-workbench.localhost`).
- Landing page / project list: `kids-workbench.localhost`.
- Database viewer: `db.kids-workbench.localhost`.
- Mail catcher: `mail.kids-workbench.localhost`.
- `<name>` is the project slug: lowercase letters, digits and `-`, at most 63 characters.
  It is the same slug as the project's folder name.
- `*.localhost` resolves to the local machine without any DNS setup.

## Folders
- Plugin config and user templates: `~/.config/kids-workbench/`
  (`templates/`, `caddy.d/` for per-project Caddy snippets).
- Projects: `~/Projects/<name>/` today (set `KIDS_WORKBENCH_PROJECTS` to change).
- Shared services (compose file, data): `~/.local/share/kids-workbench/services/`.

## Shared services
- Docker compose project name: `kids-workbench`. Containers: `kids-workbench-postgres`, `kids-workbench-redis`, ...
- Ports are published on `127.0.0.1` only.
- Postgres: one database and one role per project that opts in, both named `kids_workbench_<name_with_underscores>`.
  SQLite is the default and lives inside the project.

## Code
- Shell plugin id: `myomarchy.kids-workbench` (IPC target and folder).
- Env vars: `KIDS_WORKBENCH_PROJECTS`, `KIDS_WORKBENCH_DOMAIN` (default `kids-workbench.localhost`), ...
- Laravel starter: Composer package `kids-workbench/app`, namespace `KidsWorkbench\`
  for anything shared; the app's own feature code follows the starter's conventions.
- Laravel-owned names (`App\`, `users`, `DB_*`, `APP_*`) are left alone.

## Rule of thumb
If a name is needed and one of the forms above fits, use it. Do not invent a new spelling.
