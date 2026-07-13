#!/usr/bin/env bash
#
# tmux-claude — bind a key that opens a scratch Claude Code session in a
# tmux popup, preloaded with your recent fish history and the current pane's
# contents. TPM-compatible entry point; also usable via run-shell.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

opt() {
  local val
  val="$(tmux show-option -gqv "$1")"
  printf '%s' "${val:-$2}"
}

key="$(opt @claude-popup-key 'C')"
root_key="$(opt @claude-popup-root-key '')"
width="$(opt @claude-popup-width '80%')"
height="$(opt @claude-popup-height '75%')"

popup_args=(-E -w "$width" -h "$height" -d '#{pane_current_path}')

# Popup titles and border styles need tmux >= 3.3.
tmux_version="$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -n 1)"
if printf '3.3\n%s\n' "$tmux_version" | sort -C -V; then
  popup_args+=(-b rounded -T ' Claude scratch ')
fi

popup_cmd="\"$CURRENT_DIR/bin/claude-popup\" '#{pane_id}'"

tmux bind-key "$key" display-popup "${popup_args[@]}" "$popup_cmd"
if [ -n "$root_key" ]; then
  tmux bind-key -n "$root_key" display-popup "${popup_args[@]}" "$popup_cmd"
fi
