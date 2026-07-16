# zish

[English](README.md) | 简体中文

从网络安装 fish 风格的 Zsh。**始终装最新**——不做 commit pin，不做 SHA 打包冻结。

## 安装

```sh
curl -fsSL https://raw.githubusercontent.com/kongjiadongyuan/zish/main/install-fishlike-zsh.sh | bash
```

或在 git 仓库内（优先用本地 `share/`）：

```sh
bash install-fishlike-zsh.sh
```

## 包含

- 自动建议、语法高亮、fzf-tab、历史搜索
- `Ctrl+R` 模糊历史、缩写、目录历史（`prevd` / `nextd` / `cdh`）
- 简洁 git 提示符
- 隔离目录：`~/.config/fishlike-zsh`、`~/.local/share/fishlike-zsh`
- 保留原有 `.zshrc`，只加一小段 loader

## 行为

| 项 | 策略 |
|----|------|
| 版本 | 每次安装从网络拉最新（`main` / fzf latest release） |
| 启动 | 只读：source 安装时生成的 `plugins.zsh`，运行时不跑 Antidote |
| 备份 | `~/.local/share/fishlike-zsh/backup/<timestamp>/` |
| 卸载 | `bash install-fishlike-zsh.sh --uninstall`（挪走托管目录；保留历史与 `.zshrc.local`） |
| 系统包 | 默认不装；`--install-deps` 才尝试 |
| 登录 Shell | 默认不改；需 `--chsh` 或确认 |

本机覆盖：`~/.zshrc.local`。

## 选项

```text
--dry-run           只预览
--install-deps      用包管理器装缺失的 zsh/git/curl
--force             替换/卸载时少提问
--uninstall         移除 loader 与托管树
--chsh / --no-chsh  登录 Shell
--non-interactive   不提问
```

重跑安装器即可从网络更新插件与配置。
