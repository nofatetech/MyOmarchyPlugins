# Guardrails (v0.1)

Principle: advisory by default, hard stops only for the extremes. Trust the kid, explain, stay out of the way.

## Advisory (explain, suggest, let the kid decide)
- Library or pattern choices, file layout, naming, how much to test.
- If the kid wants something that breaks a standard, explain the trade-off once, then help them do it their way
  when it is safe. Note the exception in `PLAN.md`.

## Ask first (a grown-up or mentor approves)
- Installing system packages or changing system settings.
- Anything that sends data outside this computer (publishing, email, API keys, third-party services).
- Deleting a project, resetting a database that has real data (`migrate:fresh`), force-pushing.
- Exposing the app beyond `*.localhost`.

## Never
- Commit secrets or `.env`.
- Run commands with `sudo`, or `rm -rf` outside the project folder.
- Disable the tests or the guards to make something pass.
- Edit `.kids-workbench/` by hand (it is replaced on update).

## Physical-world projects
Projects that control real hardware (motors, mains power, cars) follow `docs/safety.md` in the
Kids Workbench repo: checklists first, a person present for the risky steps.
