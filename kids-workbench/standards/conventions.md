# Conventions (v0.1)

See naming.md for hosts, folders, databases and env vars.

## Code
- PHP: Pint defaults (`./vendor/bin/pint`). Types on parameters and returns.
- Tables: plural snake_case (`recipes`, `recipe_steps`). Models: singular PascalCase (`Recipe`).
- Routes: resource routes where possible (`Route::resource`), names follow Laravel defaults.
- Vue: single-file components, `<script setup>`, one component per file, PascalCase file names.
- Comments explain *why*, not what. Short, friendly, for a reader who is learning.

## Git
- Small commits, each leaving the tests green.
- Message: one line, imperative, says what the project can do now ("Add recipe list page").
- Standards updates are their own commit ("standards 0.1.0 -> 0.2.0").
- Never commit `.env`, `vendor/`, `node_modules/`, or database files.

## Docs in the project
- `BRIEF.md`: what the kid wants to make (the kid's words, edited by the kid).
- `PLAN.md`: small milestones with checkboxes, kept current by the agent.
- `AGENTS.md`: project-specific notes for the agent. The managed base lives in `.kids-workbench/`.
