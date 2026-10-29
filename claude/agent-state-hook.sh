# Claude Code hook wrapping tmux-agent-indicator's agent-state.sh (see
# configuration.nix), taking the indicator state as its only argument plus
# two internal ones, subagent-start/subagent-stop.
#
# Claude ends its turn (firing Stop) while background subagents are still
# running, then resumes when they finish. To not mark the pane "done" while
# it's only waiting on its own subagents, subagent-start/stop keep a marker
# file per running subagent, and "done" is skipped while any exist. Markers
# older than a few hours are ignored, in case a subagent died without firing
# SubagentStop.

input=$(cat)
session=$(jq -r '.session_id' <<<"$input")
markers="${TMPDIR:-/tmp}/claude-running-subagents/$session"

case "$1" in
  subagent-start)
    mkdir -p "$markers"
    touch "$markers/$(jq -r '.agent_id' <<<"$input")"
    ;;
  subagent-stop)
    rm -f "$markers/$(jq -r '.agent_id' <<<"$input")"
    ;;
  done)
    if [ -n "$(jq -r '.agent_id // empty' <<<"$input")" ]; then
      exit 0 # Stop fired inside a subagent, not the main session
    fi
    if [ -d "$markers" ] && [ -n "$(find "$markers" -type f -mmin -240)" ]; then
      exit 0
    fi
    rm -rf "$markers"
    @agentState@ --agent claude --state "$1"
    ;;
  *)
    @agentState@ --agent claude --state "$1"
    ;;
esac
