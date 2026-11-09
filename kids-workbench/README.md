# Kids Workbench

A kid-friendly maker environment built on [Omarchy](https://omarchy.org) (Arch + Hyprland), for kids roughly 8–16.
Started as an experiment for our own kids.

**One line:** the laptop is a workshop companion for making real things, not a screen to sit at.

## Core ideas

- **Projects, not apps.** A project (go-kart, treehouse lights, band concert) bundles notes, photos, files, to-dos and the right tools.
- **Creating over consuming.** Draw, write, code, build games, make music, CAD, 3D print, solder, fix cars, do woodwork.
- **Mentors, not policing.** Advisory defaults ("Richtgeschwindigkeit"), guardrails only for the extremes, trust the kids.
- **Real world.** Computer lives in the garage, workshop or treehouse. Portfolio, skills and internships connect to real life.

## Docs

| File | What's in it |
|---|---|
| [docs/vision.md](docs/vision.md) | Why, who, and the shape of the thing |
| [docs/principles.md](docs/principles.md) | Design principles and trust model |
| [docs/features.md](docs/features.md) | Every feature idea, grouped by area |
| [docs/agents-and-standards.md](docs/agents-and-standards.md) | Agent-driven templates, standards sync, kid profiles |
| [docs/hardware.md](docs/hardware.md) | Devices, physical computing, workshop setup |
| [docs/mentors.md](docs/mentors.md) | Mentor model |
| [docs/real-world.md](docs/real-world.md) | Portfolio, skills, internships, pedagogy |
| [docs/safety.md](docs/safety.md) | Safety layer and guardrails |
| [docs/omarchy-integration.md](docs/omarchy-integration.md) | How it could be built on Omarchy |
| [docs/roadmap.md](docs/roadmap.md) | Suggested v1 and later phases |
| [standards/naming.md](standards/naming.md) | Naming rules for hosts, folders, DBs, env vars, code |
| [docs/open-questions.md](docs/open-questions.md) | What we haven't decided |

## Try it (Omarchy shell plugin)

```bash
./install.sh      # symlinks plugin/ into ~/.config/omarchy/plugins and enables it
omarchy-shell myomarchy.kids-workbench toggle   # or: open / close
./uninstall.sh
```

A thin strip on the left edge; click it and it widens to **New** (templates) and **My stuff** (projects).
Clicking a template creates `~/Projects/<fun-name>/` from the template and opens the right app on it.
Set `KIDS_WORKBENCH_PROJECTS` to use another folder.

**Templates** are plain folders: `plugin/templates/<id>/template.json` (name, icon, `launch` commands with `{dir}`) plus a `starter/` folder copied into the new project.
Add your own in `~/.config/kids-workbench/templates/<id>/`.

The HTML in `prototype/` is the original design sketch, not the real thing.

## Status

Sidebar v0.1: New and My stuff, three templates (HTML game, Godot game, Drawing). Next: project name prompt, step mode, link saver.
