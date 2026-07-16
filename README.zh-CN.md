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
- `~/.zshrc` 中的简短 loader（先 `env.zsh` 再 `config.zsh`）

本机覆盖：`${ZDOTDIR:-$HOME}/.zshrc.local`。

## 选项

```text
--dry-run           只预览，不改动文件
--install-deps      用系统包管理器安装缺失的 zsh/git/curl
--force             备份后替换冲突的托管路径
--chsh / --no-chsh  回答是否修改登录 Shell
--non-interactive   不提问，使用默认选项
```

默认只打印缺失依赖与安装示例；加上 `--install-deps` 才会自动调包管理器。

## 包含内容

- 自动建议和语法高亮
- 模糊补全及 `Ctrl+R` 历史搜索
- 方向键历史搜索和目录历史
- 缩写及简洁的 Git 感知提示符（直接用 `git`，不依赖 `vcs_info`）
- 兼容 macOS 和 Linux 的颜色配置

## 行为

- 保留现有配置，并在修改前创建备份。
- Antidote、插件、fzf 以及 `share/` 载荷都固定版本并校验校验和。
- 托管文本文件统一权限 `0600`。
- 重复运行时会修复缺失或损坏的托管文件。
- 插件异常时退回基础补全和标准按键。
- 只有安装验证成功并得到明确同意后，才会修改登录 Shell。

需要 Zsh 5.4.2 或更高版本以及 Git。详情见 `bash install-fishlike-zsh.sh --help`。
