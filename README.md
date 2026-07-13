# zish

English | [简体中文](README.zh-CN.md)

A cautious, repeatable installer for a fish-like Zsh setup. It adds completion, history search, autosuggestions, syntax highlighting, directory history, and a compact prompt while minimizing changes to existing configuration.

## Quick install

With `curl`:

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

Or with `wget`:

```sh
wget -qO- https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

The installer does not change your login shell by default. To set Zsh as the login shell after installation:

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash -s -- --chsh
```

To preview all planned actions without changing anything:

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash -s -- --dry-run
```

Piping a download into Bash executes remote code immediately. To inspect the script first:

```sh
curl -fsSLO https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh
less install-fishlike-zsh.sh
bash install-fishlike-zsh.sh
```

## What it installs

- Zsh autosuggestions and syntax highlighting
- Fuzzy completion and `Ctrl+R` history search
- History substring search with the up and down arrow keys
- Directory history through `prevd`, `nextd`, and `cdh`
- Abbreviations through `zsh-abbr`
- A prompt showing the path, Git branch, and previous exit status
- Portable `ls` color configuration for macOS and Linux

Antidote, all plugins, and fzf are pinned to explicit versions or commits. The downloaded fzf archive and binary are SHA-256 verified. Plugin remotes, commits, entry points, and working trees are checked after installation.

## Safety and compatibility

- Existing `.zshrc` content is preserved. The installer adds only a loader block and creates backups before changes.
- Configuration, plugin caches, and binaries use isolated directories and do not reuse an existing Antidote setup.
- The installer is safe to rerun. Missing or damaged plugin caches are preserved and rebuilt.
- If plugins or fzf are temporarily unavailable, Zsh falls back to basic completion and standard key bindings.
- macOS and Linux are supported, along with Homebrew, APT, DNF, YUM, Pacman, Zypper, and APK.
- Zsh 5.4.2 or newer and a working Git installation are required. Installing fzf also requires `curl` or `wget`, `tar`, and a SHA-256 tool.

## Options

```text
--chsh       Set Zsh as the login shell after installation
--no-chsh    Never change the login shell (default)
--force      Back up and replace conflicts in the managed namespace
--dry-run    Show planned actions without downloading or changing files
--skip-pkgs  Do not invoke a system package manager
```

Machine-specific configuration can be placed in `${ZDOTDIR:-$HOME}/.zshrc.local`. The installer never overwrites that file.
