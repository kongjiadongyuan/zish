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
- One directory: `~/.config/zish`
- `.zshrc` stays a tiny loader; extra lines outside that block are kept
- `zish version` / `zish check` / `zish update` / `zish theme` / `zish uninstall`
- Interactive shells notice a newer remote version (checked in the background, at most daily)

## Behavior

| Topic | Policy |
|-------|--------|
| Versions | Latest from GitHub on each install (`main` / latest fzf release) |
| Startup | Read-only: sources prebuilt `plugins.zsh`; one cached `compinit`; no Antidote at runtime |
| Backups | `~/.config/zish/backup/<timestamp>/` |
| Uninstall | `zish uninstall` (moves `~/.config/zish`; keeps history) |
| System packages | Not installed unless `--install-deps` |
| Login shell | Unchanged unless you pass `--chsh` / answer yes |
| Post-install check | None — open a new shell and use it |

`~/.zshrc` only sources `~/.config/zish/config.zsh`. Put PATH, aliases, and machine-specific env in `~/.zshrc` below the loader block.

```sh
zish version
zish check       # compare with GitHub now
zish update      # latest from the network; keeps .zshrc outside the loader
zish theme       # interactive picker (fzf, or a numbered menu)
zish theme nord  # set this machine; kept across updates
zish theme list  # print palettes without picking
zish uninstall
```

## Options

```text
--dry-run           Preview only
--install-deps      Install missing zsh/git/curl via package manager
--force             Replace / uninstall without extra prompts
--uninstall         Remove loader + `~/.config/zish`
--chsh / --no-chsh  Login-shell question
--non-interactive   Never prompt
```

## Layout after install

```text
~/.zshrc                 # tiny loader → source ~/.config/zish/config.zsh

~/.config/zish/          # everything zish owns
  config.zsh             # prompt, keys, aliases (replaced on reinstall)
  plugins.txt            # which plugins to fetch
  plugins.zsh            # generated source list
  plugins/               # third-party plugin source (from GitHub)
  bin/fzf
  bin/zish               # zish version / update / uninstall
  install.sh             # copy of the installer (for uninstall)
  antidote/              # install-time tool
  backup/
  state
```
