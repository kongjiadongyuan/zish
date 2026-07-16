# zish

English | [简体中文](README.zh-CN.md)

A repeatable installer for a fish-like Zsh setup. It keeps your existing `.zshrc`, installs pinned dependencies in isolated directories, and adds a small loader block.

## Install

With `curl`:

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

With `wget`:

```sh
wget -qO- https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

From a git checkout (uses local `share/`):

```sh
bash install-fishlike-zsh.sh
```

## Layout

| Path | Role |
|------|------|
| `install-fishlike-zsh.sh` | Installer only: fetch, verify, land files, wire loader |
| `share/config.zsh` | Runtime shell behavior (source of truth) |
| `share/plugins.txt` | Pinned Antidote plugin list (source of truth) |

On install the script writes:

- `~/.config/fishlike-zsh/env.zsh` — machine paths
- `~/.config/fishlike-zsh/config.zsh` — copy of `share/config.zsh`
- `~/.config/fishlike-zsh/plugins.txt` — copy of `share/plugins.txt`
- `~/.config/fishlike-zsh/plugins.zsh` — **install-time** static source list (Antidote is not used at shell startup)
- plugin clones under `~/.cache/fishlike-zsh/plugins/`
- a short loader in `~/.zshrc` that sources `env.zsh` then `config.zsh`

Startup is read-only: re-run the installer to repair plugins. Local overrides: `${ZDOTDIR:-$HOME}/.zshrc.local`.

## Options

```text
--dry-run           Preview actions without changing anything
--install-deps      Install missing system packages (zsh/git/curl) via the package manager
--force             Replace conflicting managed paths after backup
--chsh / --no-chsh  Answer the login-shell question
--non-interactive   Never prompt; use defaults
```

Missing system tools are printed with install hints by default. They are only auto-installed when you pass `--install-deps`.

## Included

- Autosuggestions and syntax highlighting
- Fuzzy completion and `Ctrl+R` history search
- Arrow-key history search and directory history
- Abbreviations and a compact Git-aware prompt (`git`, not `vcs_info`)
- Portable colors for macOS and Linux

## Behavior

- Existing configuration is preserved and backed up before changes.
- Antidote is used only during install to materialize the plugin bundle; interactive shells do not load Antidote.
- Plugins, fzf, and the `share/` payload are pinned and checksum-verified.
- Managed text files are always mode `0600`.
- Re-running the installer repairs missing or damaged managed files.
- Verification uses a login interactive shell (`zsh -lic`).
- The login shell is changed only after a successful install and explicit approval.

Requires Zsh 5.4.2 or newer and Git. Run `bash install-fishlike-zsh.sh --help` for details.
