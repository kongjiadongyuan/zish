# zish

[English](README.md) | 简体中文

一个可重复执行的 fish 风格 Zsh 安装脚本。它会保留现有 `.zshrc`，把固定版本的依赖安装到独立目录，并且只加入一个简短的加载区块。

## 安装

使用 `curl`：

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

使用 `wget`：

```sh
wget -qO- https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

在 git 仓库内安装（使用本地 `share/`）：

```sh
bash install-fishlike-zsh.sh
```

## 布局

| 路径 | 职责 |
|------|------|
| `install-fishlike-zsh.sh` | 只负责安装：下载、校验、落盘、写入 loader |
| `share/config.zsh` | 运行时 shell 行为（唯一真源） |
| `share/plugins.txt` | 固定版本的 Antidote 插件列表（唯一真源） |

安装后会写入：

- `~/.config/fishlike-zsh/env.zsh` — 本机路径
- `~/.config/fishlike-zsh/config.zsh` — `share/config.zsh` 的副本
- `~/.config/fishlike-zsh/plugins.txt` — `share/plugins.txt` 的副本
- `~/.config/fishlike-zsh/plugins.zsh` — **安装时**生成的静态 `source` 列表（启动时不再跑 Antidote）
- 插件克隆目录：`~/.cache/fishlike-zsh/plugins/`
- `~/.zshrc` 中的简短 loader（先 `env.zsh` 再 `config.zsh`）

启动只读：插件坏了请重跑安装器。本机覆盖：`${ZDOTDIR:-$HOME}/.zshrc.local`。

## 选项

```text
--dry-run           只预览，不改动文件
--install-deps      用系统包管理器安装缺失的 zsh/git/curl
--force             替换冲突路径 / 卸载时不再二次确认
--uninstall         移除 loader 与托管目录（移入备份目录，非静默 rm）
--chsh / --no-chsh  回答是否修改登录 Shell
--non-interactive   不提问，使用默认选项
```

默认只打印缺失依赖与安装示例；加上 `--install-deps` 才会自动调包管理器。

卸载示例：

```sh
bash install-fishlike-zsh.sh --uninstall
# 非交互：
bash install-fishlike-zsh.sh --uninstall --force
```

**不会**改登录 Shell、历史记录或 `~/.zshrc.local`。

## 包含内容

- 自动建议和语法高亮
- 模糊补全及 `Ctrl+R` 历史搜索
- 方向键历史搜索和目录历史
- 缩写及简洁的 Git 感知提示符（直接用 `git`，不依赖 `vcs_info`）
- 兼容 macOS 和 Linux 的颜色配置

## 行为

- 保留现有配置；备份统一放在 `~/.local/share/fishlike-zsh/backup/<timestamp>/`。
- Antidote 仅在安装期用来生成插件 bundle；交互 shell 不再加载 Antidote。
- 插件、fzf 与 `share/` 载荷固定版本并校验校验和。
- 托管文本文件统一权限 `0600`。
- 安装后写入状态文件 `~/.local/share/fishlike-zsh/state`。
- 重复运行安装器可修复缺失或损坏的托管文件。
- 验证使用登录交互 shell（`zsh -lic`）。
- 只有安装验证成功并得到明确同意后，才会修改登录 Shell。
- `--uninstall` 把托管目录移走，不删历史、不碰本机覆盖配置。

需要 Zsh 5.4.2 或更高版本以及 Git。详情见 `bash install-fishlike-zsh.sh --help`。
