# zish

[English](README.md) | 简体中文

一个安全、可重复执行的 Zsh 配置安装脚本。它提供类似 fish 的补全、历史搜索、自动建议、语法高亮、目录历史和简洁提示符，同时尽量不干扰已有配置。

## 一键安装

使用 `curl`：

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

或者使用 `wget`：

```sh
wget -qO- https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

默认不会修改登录 Shell。需要同时将登录 Shell 设置为 Zsh 时：

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash -s -- --chsh
```

建议首次运行前先查看执行计划：

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash -s -- --dry-run
```

管道安装会直接执行下载到的脚本。如需先检查内容，可以下载后再运行：

```sh
curl -fsSLO https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh
less install-fishlike-zsh.sh
bash install-fishlike-zsh.sh
```

## 安装内容

- Zsh 自动建议和语法高亮
- 模糊补全及 `Ctrl+R` 历史搜索
- 上下方向键历史子串搜索
- `prevd`、`nextd` 和 `cdh` 目录历史
- `zsh-abbr` 缩写
- 路径、Git 分支和退出状态提示
- 跨 macOS 与 Linux 的 `ls` 颜色配置

Antidote、插件和 fzf 都固定到明确版本或提交。下载的 fzf 会经过 SHA-256 校验；插件会在安装结束时检查远端、提交、入口文件和工作区状态。

## 安全与兼容性

- 保留现有 `.zshrc`，只加入一个加载区块；修改前会创建备份。
- 配置、插件缓存和二进制使用独立目录，不会复用已有 Antidote 环境。
- 可以重复运行；插件缓存缺失或损坏时会保留异常副本并重新生成。
- 插件或 fzf 暂时不可用时，会退回基础补全和标准按键，不影响 Zsh 启动。
- 支持 macOS 和 Linux，以及 Homebrew、APT、DNF、YUM、Pacman、Zypper 和 APK。
- 需要 Zsh 5.4.2 或更高版本，以及可用的 Git。安装 fzf 时还需要 `curl` 或 `wget`、`tar` 和 SHA-256 工具。

## 常用选项

```text
--chsh       安装后将 Zsh 设置为登录 Shell
--no-chsh    不修改登录 Shell（默认）
--force      备份并替换托管目录中的冲突文件
--dry-run    仅显示计划，不下载或修改文件
--skip-pkgs  不调用系统包管理器
```

本地机器专用配置可以写入 `${ZDOTDIR:-$HOME}/.zshrc.local`，安装脚本不会覆盖该文件。
