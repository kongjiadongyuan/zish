# zish

English | [简体中文](README.zh-CN.md)

A repeatable installer for a fish-like Zsh setup. It keeps your existing `.zshrc`, installs pinned dependencies in isolated directories, and adds a small loader block.

## Install

```sh
# curl
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash

# wget
wget -qO- https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

When a terminal is available, the installer asks only when it needs a decision:

```text
Install the missing system dependencies now? [Y/n]
Back up and replace this and any other conflicting managed paths? [y/N]
Set Zsh as your login shell? [y/N]
```

The capital letter is the default; press Enter to accept it. Without a terminal, the installer never waits for input and uses the same defaults.

## Included

- Autosuggestions and syntax highlighting
- Fuzzy completion and `Ctrl+R` history search
- Arrow-key history search and directory history
- Abbreviations and a compact Git-aware prompt
- Portable colors for macOS and Linux

## Behavior

- Existing configuration is preserved and backed up before changes.
- Antidote, plugins, and fzf are pinned and verified.
- Re-running the installer repairs missing or damaged managed files.
- Plugin failures fall back to basic completion and standard key bindings.
- The login shell is changed only after a successful install and explicit approval.

Requires Zsh 5.4.2 or newer and Git. Run `bash install-fishlike-zsh.sh --help` for preview and automation options.
