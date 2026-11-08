# Omarchy integration

Not sure yet whether this is a plugin, apps, menus, integrations, or a mix. Initial view: mostly configuration and curation, with one or two small custom apps.

## Layers (cheapest first)
1. **Account and app set.** Separate user, no sudo. Curated packages and webapps.
2. **Menu and sidebar.** Rebuild the launcher menu as big tiles; permanent sidebar (eww, Quickshell or Waybar variant) with shortcuts and a "New..." button.
3. **Custom app(s).** Qt Quick/C++ following the Omarchy app conventions (qmake6, Arch package, follows Omarchy theme live). Candidates: project hub, link saver.
4. **Browser extension** for the link saver, talking to a local app.
5. **Device layer.** udev rules, permissions groups, a detector that suggests apps.
6. **Packaging.** An Arch package or meta-package that installs and configures all of the above.
7. **Plain-text config** the family can edit: templates, checklists, mentor list, app set.

## Things to check
- Hyprland window rules for a gentler floating mode.
- Omarchy theme following for custom apps.
- Voice control stack (Vosk or whisper.cpp) and hotkeys.
- Offline knowledge base storage and search.
- Snapshots with snapper/btrfs per-user.
