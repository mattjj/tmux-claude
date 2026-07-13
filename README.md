# tmux-claude

A Spotlight box for Claude Code: press a key in tmux, get a popup running a
fresh scratch Claude session, ask your quick question, hit `q`/`Ctrl-D` (or
`Esc`) to dismiss it — all without leaving the pane you were working in.

Each popup session is preloaded (via the system prompt) with ambient context:

- your **recent fish shell history** (last 20 commands by default)
- the **visible contents of the pane** you were in — great for "what does
  this error mean?"
- the pane's **working directory and git state** (branch + uncommitted
  changes); the popup also starts *in* that directory, so Claude can read
  files there

Every popup is a brand-new session: dismiss and forget. (See
[`@claude-popup-claude-args`](#configuration) if you want resumable behavior.)

## Requirements

- tmux ≥ 3.2 (for `display-popup`; ≥ 3.3 gets you the rounded border + title)
- [Claude Code](https://docs.claude.com/en/docs/claude-code) (`claude` on your `PATH`)
- fish (optional — used only to read your shell history)

## Install

### With [TPM](https://github.com/tmux-plugins/tpm)

Add to `~/.tmux.conf` (or `~/.config/tmux/tmux.conf`):

```tmux
set -g @plugin 'mattjj/tmux-claude'
```

Then `prefix + I` to install.

### Manually

```sh
git clone https://github.com/mattjj/tmux-claude ~/.tmux/tmux-claude
```

and in your tmux config:

```tmux
run-shell ~/.tmux/tmux-claude/tmux-claude.tmux
```

Reload with `tmux source-file ~/.tmux.conf`.

## Usage

Press **`prefix + C`** (capital C). A popup opens running a fresh `claude`
session with the context above already injected — just type your question.
Dismiss it by quitting Claude (`Ctrl-D` or `/exit`) or pressing `Esc`.

The binding lives in tmux rather than your shell, so it works no matter
what's running in the pane — vim, ssh, a REPL, a hung build.

## Configuration

Set any of these in your tmux config *before* the plugin loads (values shown
are the defaults):

```tmux
set -g @claude-popup-key 'C'              # prefix + this key opens the popup
set -g @claude-popup-root-key ''          # optional no-prefix key, e.g. 'M-c' (Alt-c)
set -g @claude-popup-width '80%'
set -g @claude-popup-height '75%'
set -g @claude-popup-history-lines '20'   # fish history commands to include
set -g @claude-popup-scrollback-lines '200'  # pane lines to capture
set -g @claude-popup-claude-args ''       # extra args passed to `claude`
```

Examples:

```tmux
# Open with Alt-c, no prefix needed — maximum Spotlight
set -g @claude-popup-root-key 'M-c'

# Use a faster model + lower thinking effort for quick questions, without
# touching the defaults of your other Claude sessions (both flags are
# per-session). Read at popup-open time, so no config reload needed.
set -g @claude-popup-claude-args '--model opus --effort medium'

# Make the scratch session resumable instead of fresh each time
set -g @claude-popup-claude-args '--continue'
```

## Launching from a fish prompt (optional)

The tmux binding is all you need, but if you also want a command you can type,
drop this in `~/.config/fish/functions/cq.fish`:

```fish
function cq --description "Claude scratch popup"
    tmux display-popup -E -w 80% -h 75% -d (pwd) \
        "$HOME/.tmux/plugins/tmux-claude/bin/claude-popup '"(tmux display-message -p '#{pane_id}')"'"
end
```

## How it works

`tmux-claude.tmux` binds the key to `display-popup`, passing along the active
pane's id and directory. Inside the popup, [`bin/claude-popup`](bin/claude-popup)
gathers context — `fish -c history` (falling back to parsing
`~/.local/share/fish/fish_history`), `tmux capture-pane` on the originating
pane, and `git status` — then execs:

```sh
claude --append-system-prompt "<the gathered context>"
```

No daemons, no state, ~100 lines of bash.

## License

[MIT](LICENSE)
