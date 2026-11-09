# Syncing a project with updated standards (managed)

The managed folder `.kids-workbench/` is replaced with the newest standards. The project itself
(code, `AGENTS.md`, `BRIEF.md`, `PLAN.md`) is yours to migrate.

1. Run `.kids-workbench/scripts/update.sh`. It prints the old and new versions
   (`standards`, and the template's own version) and replaces `.kids-workbench/`.
2. Read `.kids-workbench/CHANGELOG.md`: every entry newer than the old standards version.
   Each entry says what changed, how to migrate, and how to check it.
3. Apply the migration steps to the project in small steps. Explain to the kid what is changing and why.
4. Run `.kids-workbench/scripts/test.sh` until green. Do not weaken guards.
5. Commit on its own: `standards <old> -> <new>`.
6. If a step is unclear or risky, stop and ask. Note anything you skipped in `PLAN.md`.
