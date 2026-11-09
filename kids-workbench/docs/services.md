# Shared services (Caddy, PHP-FPM, Postgres, Mailpit, Adminer)

One set of services for all projects, managed by the `kids-workbench` CLI (`bin/kids-workbench`,
linked to `~/.local/bin` by `install.sh`). Names and addresses follow [../standards/naming.md](../standards/naming.md).

```
browser ─► Caddy (Docker, host network, 127.0.0.1:80)
            ├─ kids-workbench.localhost        live list of ~/Projects (landing page)
            ├─ <name>.kids-workbench.localhost ~/Projects/<name>: Laravel via php-fpm, else static files
            ├─ db.kids-workbench.localhost     ─► Adminer   127.0.0.1:8088
            └─ mail.kids-workbench.localhost   ─► Mailpit   127.0.0.1:8025
php-fpm (native, systemd --user, runs as you) ◄── unix socket in $XDG_RUNTIME_DIR/kids-workbench/
Postgres (Docker, pgvector/pg16)  127.0.0.1:54329   (5432 is left alone: other projects use it)
Mailpit SMTP                       127.0.0.1:1025
```

## Why this shape
- **Caddy in Docker, host network:** binds port 80 without root on the host, and a wildcard host maps
  `<name>.kids-workbench.localhost` to `~/Projects/<name>`, so **no per-project registration**: create a folder, it has an address.
- **php-fpm native:** the agent runs `php artisan` and `composer` natively anyway, and a user-level fpm
  shares the files and permissions with them. One pool serves every project.
- **Postgres, Mailpit, Adminer in Docker:** stateful things that are easy to share and reset.
- **Everything on `127.0.0.1`:** nothing is reachable from the network. `*.localhost` needs no DNS setup and
  counts as a secure context in browsers, so plain HTTP is fine.
- **SQLite stays the default.** Adminer opens the SQLite files too (login with an empty password; it is local only).

## Commands
```
kids-workbench install-host   # sudo pacman: php php-fpm php-sqlite php-pgsql php-intl php-gd php-sodium composer sqlite;
                              # enables missing PHP extensions in /etc/php/conf.d/kids-workbench.ini; starts php-fpm
kids-workbench up | down      # Caddy, Postgres, Mailpit, Adminer (docker compose, project "kids-workbench")
kids-workbench status | logs | doctor
kids-workbench reload         # after editing ~/.config/kids-workbench/caddy.d/*.caddy
kids-workbench db create|drop|list <project>   # per-project Postgres db; prints DB_* and MAIL_* lines for .env
kids-workbench open [project]
```

Files: sources in `services/`, copied to `~/.local/share/kids-workbench/services/` (with a generated `.env`
that holds the Postgres admin password) when you run `up`.

## Overrides
A snippet in `~/.config/kids-workbench/caddy.d/<name>.caddy` for an exact host beats the wildcard, for example a dev server:

```
http://space-dodger.kids-workbench.localhost {
	reverse_proxy 127.0.0.1:5173
}
```

## Tested / not yet
- Tested: Caddy routing (landing page, static project, unknown project 404, db and mail hosts), the PHP route through a
  throwaway php-fpm container on a unix socket with matching paths, Postgres create/use/drop, Adminer SQLite login, binding to 127.0.0.1.
- Not tested: `install-host` (needs sudo) and the native php-fpm systemd unit, because PHP is not installed on this machine yet.
- Datasette (a friendlier "explore your data" view for SQLite) is a possible later addition.
