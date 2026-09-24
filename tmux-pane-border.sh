#!/bin/sh
# Turn a window's pane-border-status on only when it has multiple panes that
# aren't all in the same directory, so single-pane (or same-directory)
# windows don't get an empty border row. Invoked as a tmux hook.
#
# With a window id argument, refreshes just that window (used by hooks whose
# target window is reliably known, e.g. after-select-pane). With no
# argument, refreshes every window in every session — used by pane-exited,
# a bare notification hook whose #{window_id} doesn't reliably resolve to
# the pane that actually exited (it can pick up an unrelated attached
# client's current window instead).
refresh_window() {
  window="$1"
  count=$(tmux list-panes -t "$window" -F '#{pane_current_path}' | sort -u | wc -l | tr -d ' ')
  if [ "$count" -gt 1 ]; then
    tmux set-window-option -t "$window" pane-border-status top
  else
    tmux set-window-option -t "$window" pane-border-status off
  fi
}

if [ -n "$1" ]; then
  refresh_window "$1"
else
  tmux list-windows -a -F '#{window_id}' | while read -r window_id; do
    refresh_window "$window_id"
  done
fi
