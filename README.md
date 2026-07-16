# zish

English | [简体中文](README.zh-CN.md)

Install a fish-like Zsh setup from the network. **Always latest** — no frozen pins, no SHA release packages.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

Or from a git checkout (uses local `share/` when present):

```sh
bash install-fishlike-zsh.sh
```

## What you get

- Autosuggestions, syntax highlighting, fzf-tab, history search
- `Ctrl+R` fuzzy history, abbreviations, directory history (`prevd` / `nextd` / `cdh`)
- Compact git-aware prompt
- Isolated under `~/.config/fishlike-zsh` and `~/.local/share/fishlike-zsh`
- Your existing `.zshrc` is kept; only a small loader block is added

## Behavior

| Topic | Policy |
|-------|--------|
| Versions | Latest from GitHub on each install (`main` / latest fzf release) |
| Startup | Read-only: sources prebuilt `plugins.zsh` — no Antidote at runtime |
| Backups | `~/.local/share/fishlike-zsh/backup/<timestamp>/` |
| Uninstall | `bash install-fishlike-zsh.sh --uninstall` (moves managed trees; keeps history & `.zshrc.local`) |
| System packages | Not installed unless `--install-deps` |
| Login shell | Unchanged unless you pass `--chsh` / answer yes |
| Post-install check | None — open a new shell and use it |

Local overrides: `~/.zshrc.local`.

## Options

```text
--dry-run           Preview only
--install-deps      Install missing zsh/git/curl via package manager
--force             Replace / uninstall without extra prompts
--uninstall         Remove loader + managed trees
--chsh / --no-chsh  Login-shell question
--non-interactive   Never prompt
```

## Layout after install

```text
~/.config/fishlike-zsh/
  env.zsh         # paths
  config.zsh      # shell behavior
  plugins.txt     # plugin list (floating latest)
  plugins.zsh     # static source list written at install time

~/.local/share/fishlike-zsh/
  antidote/       # Antidote checkout (install-time tool)
  bin/fzf
  backup/
  state

~/.cache/fishlike-zsh/plugins/   # plugin clones
```

Re-run the installer anytime to pull newer plugins/config from the network.
