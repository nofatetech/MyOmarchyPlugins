#!/usr/bin/env bash
# open-agent.sh <project-dir> <prompt>: open a terminal and start the agent there.
here="$(cd "$(dirname "$0")" && pwd -P)"
exec omarchy-launch-tui --app-id=org.kidsworkbench.agent "$here/agent.sh" "$1" "$2"
