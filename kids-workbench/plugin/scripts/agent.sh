#!/usr/bin/env bash
# agent.sh <project-dir> <prompt>: runs inside a terminal. Starts the agent in the
# project folder. The agent command is KIDS_WORKBENCH_AGENT (default: claude).
dir="$1"; prompt="$2"
cd "$dir" || exit 1
read -r -a agent <<< "${KIDS_WORKBENCH_AGENT:-claude}"
if ! command -v "${agent[0]}" >/dev/null 2>&1; then
  echo "The agent '${agent[0]}' is not installed."
  echo "Set KIDS_WORKBENCH_AGENT to another agent, or ask a grown-up to install it."
  exec "${SHELL:-bash}"
fi
"${agent[@]}" "$prompt"
exec "${SHELL:-bash}"
