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

有可用终端时，脚本只在确实需要选择时询问：

```text
Install the missing system dependencies now? [Y/n]
Back up and replace this and any other conflicting managed paths? [y/N]
Set Zsh as your login shell? [y/N]
```

大写字母表示默认选项，直接按回车即可。没有可交互终端时，脚本不会等待输入，而是采用同样的默认选项。

## 包含内容

- 自动建议和语法高亮
- 模糊补全及 `Ctrl+R` 历史搜索
- 方向键历史搜索和目录历史
- 缩写及简洁的 Git 感知提示符
- 兼容 macOS 和 Linux 的颜色配置

## 行为

- 保留现有配置，并在修改前创建备份。
- Antidote、插件和 fzf 都固定版本并经过验证。
- 重复运行时会修复缺失或损坏的托管文件。
- 插件异常时退回基础补全和标准按键。
- 只有安装验证成功并得到明确同意后，才会修改登录 Shell。

需要 Zsh 5.4.2 或更高版本以及 Git。预览和自动化选项可运行 `bash install-fishlike-zsh.sh --help` 查看。
