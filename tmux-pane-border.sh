#!/bin/sh
# Turn a window's pane-border-status on only when it has multiple panes that
# aren't all in the same directory, so single-pane (or same-directory)
# windows don't get an empty border row. Invoked as a tmux hook.
window="$1"
count=$(tmux list-panes -t "$window" -F '#{pane_current_path}' | sort -u | wc -l | tr -d ' ')
if [ "$count" -gt 1 ]; then
  tmux set-window-option -t "$window" pane-border-status top
else
  tmux set-window-option -t "$window" pane-border-status off
fi
