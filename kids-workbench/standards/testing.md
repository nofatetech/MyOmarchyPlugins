# Testing (v0.1)

One command: `.kids-workbench/scripts/test.sh`. It prints a plain pass or fail for each layer.

| Layer | Tool | What it protects |
|---|---|---|
| Standards guards | Pest (`.kids-workbench/guards`) | Project structure and forbidden patterns. Replaced on every standards update. |
| Style | Pint | Consistent code. |
| App tests | Pest (`tests/`) | Behavior. Unit tests for Actions, feature tests for routes and pages. |

Later layers: static analysis (Larastan), browser smoke test (Playwright), AI-content evals.

## Rules
- Every Action has a test. Every route has at least one feature test.
- A failing test is information, not a problem: read it, then fix the code (or the test, if the behavior changed on purpose).
- Never skip, delete or weaken a guard to get green. If a guard is wrong, say so in `PLAN.md` and ask.
