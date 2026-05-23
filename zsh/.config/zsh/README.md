# zsh

This config lives at `~/.config/zsh`. It requires `ZDOTDIR` to be set to that path.

## Setup

### macOS (Homebrew)

Already handled by `/etc/zsh/zshenv`:

```zsh
if [[ -z "$XDG_CONFIG_HOME" ]]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
```

### Linux

Create `/etc/zsh/zshenv` (or `/etc/zshenv`) with the same content above. This must run before zsh loads any user config files, otherwise zsh will look for `.zshenv` in `$HOME` instead of `~/.config/zsh`.
