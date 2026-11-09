# Architecture (web apps, v0.1)

One Laravel app per project. Keep it small and boring.

## Stack
- **Laravel** (current stable) from Laravel's official **Vue starter kit**: Inertia + Vue 3 + Tailwind.
  No React. Do not swap the frontend framework.
- **SQLite** by default (a file in `database/`). Postgres is opt-in and shared (see naming.md).
- **Pest** for tests, **Pint** for code style.
- Everything runs locally. Hosted at `<name>.kids-workbench.localhost` through the central Caddy (when set up).

## Layers
1. **Browser:** Inertia pages in `resources/js/pages/<Feature>/`, shared components in `resources/js/components/`.
2. **Routes and controllers:** thin. A controller reads the request, calls one Action, returns a response.
3. **Actions** (`app/Actions/<Feature>/<Verb><Thing>.php`): where the logic lives. One public method `handle()`.
4. **Models** (`app/Models`): data and relations only.
5. **Validation and authorization:** Form Requests and Policies, never inline in controllers.
6. **Database:** migrations only. Never edit the database by hand, never edit an old migration after it was shared.

## Rules
- Feature code follows the layers above. No business logic in routes, views or models.
- No new top-level folders without a note in `PLAN.md`.
- One way to do each thing: before adding a library or pattern, check whether the project already has one.
- Secrets live in `.env` only. `.env` is never committed.

## Planned (not yet in v0.1)
- Entity declarations that generate models, pages and tests.
- Optional AI chat with the app's content.
- Browser smoke tests.
