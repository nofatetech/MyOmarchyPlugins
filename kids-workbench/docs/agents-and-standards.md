# Agents, standards and profiles

Most templates exist to give an agent (Claude Code or another) everything it needs to start a
project and keep managing it. The sidebar does the least possible: make a folder, drop in the
seed, open the agent. See also [principles.md](principles.md) and [../standards/naming.md](../standards/naming.md).

## Template = seed + agent
A template is a seed folder plus a launch type:
- `apps`: open normal apps on the files (HTML game, drawing).
- `agent`: open a terminal in the project and start the agent with a first prompt
  ("Read AGENTS.md and BRIEF.md, then start.").
The agent command is configurable (`KIDS_WORKBENCH_AGENT`); several agents are installed here.
Claude Code runs on an adult's account (the family's), under the usual usage limits.

## Seed contents (laravel-app)
- `AGENTS.md` (and `CLAUDE.md` containing `@AGENTS.md`), written in a mentor voice:
  small steps, explain what changed and why, ask before big moves.
- `BRIEF.md`: the kid's idea and the project name. `PLAN.md`: kept up to date by the agent.
- `.kids-workbench/`: the managed, versioned part (see below).
- `scripts/bootstrap.sh`: a fixed scaffold script (Laravel, Vue + Inertia, SQLite, Pest, Pint,
  Larastan) so every project starts the same way instead of being improvised.
- `.claude/settings.json`: safe commands allowed, dangerous ones denied.
- Guard tests from the first commit, so the agent cannot drift from the architecture.

## Keeping projects in sync with the standards
Standards evolve; projects should be able to follow.

- **Single source:** `standards/` in this repo, with a `VERSION` and a `CHANGELOG.md` whose
  entries are written for agents: what changed, how to migrate, how to check it worked.
- **Layers:** global (all projects) then template (laravel-app, html-game, ...) then project.
  Each layer has its own version.
- **Managed folder:** each project has `.kids-workbench/` (standards copy, base agent
  instructions, guard tests, scripts, slash commands). It is not edited by hand, so updating is
  a plain replace with no merge conflicts. Project-owned files (`AGENTS.md`, `BRIEF.md`,
  `PLAN.md`, the code) are never overwritten.
- **Root `AGENTS.md` imports the managed base** (`@.kids-workbench/AGENTS.base.md`) and adds
  project-specific notes.
- **Update flow:** replace `.kids-workbench/` with the new version, the agent reads the
  changelog between the old and new version, applies the migration steps to the project,
  runs the guard tests until green, and commits it separately ("standards 0.3 -> 0.4").
- **Agent entry point:** a slash command / skill (`/sync-standards`) in the managed folder.
- **Sidebar:** only shows "update available" on a project (project version < current) and a
  button that opens the agent with the sync prompt. No update logic lives in the sidebar.
- **Drift detection:** guard tests live in the managed folder, so a project that falls behind
  or breaks a rule fails loudly instead of silently diverging.

## Kid profiles
The agent adapts to each kid, so we keep a profile.

- **What:** a small plain-text file, `~/.config/kids-workbench/profile.md` (one Linux user per
  kid, so each has their own): first name or nickname, age band, interests, experience per area
  (drawing, games, electronics, code, ...), how they like help (more or fewer steps, how much
  explanation), goals, things they have built.
- **How it's used:** `AGENTS.md` tells the agent to read it and adapt vocabulary, step size and
  depth of explanation. It also feeds the skills map and portfolio (see [real-world.md](real-world.md)).
- **Kid owns it:** the kid can read and edit it. The agent may propose updates ("you used loops
  well today, add it to your profile?") and the kid approves. Nothing is written silently.
- **Privacy constraints (design rules):**
  - Local file, no telemetry.
  - Keep it to learning-relevant facts. No surname, school, address or similar. The file's
    contents are sent to the AI provider, so write it as if it will be.
  - The family can read it (it is their machine), and the kid knows that.
- **Fits the trust model:** transparent, kid-owned, advisory. It is not a score or a report card.

## Roles of the agent
- **Starter:** reads the brief, runs the bootstrap, proposes a small first milestone.
- **Manager:** keeps `PLAN.md` current, keeps tests green, commits in small steps.
- **Mentor voice:** explains, asks, lets the kid decide.
- **Sync:** applies standards updates (above).

## Open points
- Exact format of the profile (markdown with front matter vs plain markdown).
- Where the standards copy lives for non-Laravel templates (same `.kids-workbench/` layout).
- Whether `kids-workbench doctor` and a small `kids-workbench` CLI live in this repo or the plugin.
- Token cost and local-model option for the agent.
