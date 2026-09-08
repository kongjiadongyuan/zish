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
- 只占一个目录：`~/.config/zish`
- `.zshrc` 只留一小段 loader；标记块之外的内容会保留
- `zish version` / `zish check` / `zish update` / `zish theme` / `zish uninstall`
- 交互 shell 发现远程有新版本会高亮提示（后台检查，最多一天一次）

## 行为

| 项 | 策略 |
|----|------|
| 版本 | 每次安装从网络拉最新（`main` / latest fzf release） |
| 启动 | 只读：source 安装时生成的 `plugins.zsh`；补全只 `compinit` 一次并走缓存；运行时不跑 Antidote |
| 备份 | `~/.config/zish/backup/<timestamp>/` |
| 卸载 | `zish uninstall`（挪走 `~/.config/zish`；保留历史） |
| 系统包 | 默认不装；`--install-deps` 才尝试 |
| 登录 Shell | 默认不改；需 `--chsh` 或确认 |
| 装完检查 | 没有——开新终端直接用 |

`~/.zshrc` 只负责 source `~/.config/zish/config.zsh`。PATH、别名、本机环境写在 `.zshrc` 里 loader 标记块下面。

```sh
zish version
zish check       # 立刻对比 GitHub 上的版本
zish update      # 从网络拉最新；.zshrc 里 loader 下面的内容会留着
zish theme       # 交互选择（fzf，没有则数字菜单）
zish theme nord  # 只改这台机器，update 不会冲掉
zish theme list  # 只打印，不挑选
zish uninstall
```

## 选项

```text
--dry-run           只预览
--install-deps      用包管理器装缺失的 zsh/git/curl
--force             替换/卸载时少提问
--uninstall         移除 loader 与 ~/.config/zish
--chsh / --no-chsh  登录 Shell
--non-interactive   不提问
```

## 安装后布局

```text
~/.zshrc                 # 一小段 loader → source ~/.config/zish/config.zsh

~/.config/zish/          # zish 只在这里
  config.zsh             # prompt、按键、别名（重装会换）
  plugins.txt            # 要装哪些插件
  plugins.zsh            # 安装时生成的 source 列表
  plugins/               # 从 GitHub 拉下来的第三方插件
  bin/fzf
  bin/zish               # zish version / update / uninstall
  install.sh
  antidote/
  backup/
  state
```

重跑安装器即可从网络更新插件与配置。
