# omarchy-webapp-profile

[English](README.md) | [简体中文](README.zh-CN.md)

多账号 Web App for [Omarchy](https://omarchy.org/) — 给 `omarchy webapp install`
加上"独立 profile 目录"能力,让同一个网站可以多个账号同时登录。

## 安装

**方式一 — 自动,通过 Omarchy 内建 AI agent:**

打开 agent(`omarchy agent`,或 SUPER+SHIFT+CTRL+A 选择一个),
把仓库地址发给它,让它自行安装:

> 安装 https://github.com/deluxebear/omarchy-webapp-profile

agent 会自己 clone 仓库并执行 `./install.sh`。

**方式二 — 手动:**

```bash
git clone https://github.com/deluxebear/omarchy-webapp-profile ~/Work/omarchy-webapp-profile
cd ~/Work/omarchy-webapp-profile
./install.sh
```

`install.sh` 做两件事:

1. 把 `bin/` 下的命令**符号链接**到 `~/.local/bin/`
2. 在 `~/.config/omarchy/extensions/omarchy-menu.jsonc` 添加菜单条目
   **Install → Web App (Multi-account)** — 与原生 Web App 安装器并排,
   同样的主题化浮动终端 + gum 向导,只多一步 profile 选择

卸载:`./install.sh --uninstall`(保留所有账号数据)。

## 用法

```bash
omarchy-webapp-profile install          # 向导(或从应用菜单进入)
omarchy-webapp-profile install <名称> <url> <图标|-> <profile> [浏览器flag...]
omarchy-webapp-profile launch <profile> <url> [flag...]
omarchy-webapp-profile list             # 已装的多账号 web app + 数据目录大小
omarchy-webapp-profile remove <名称> [--purge]
omarchy-webapp-profile purge <profile> [--yes]
omarchy-webapp-profile dir <profile>    # 打印数据目录路径
```

## 工作原理

- 桌面条目仍由系统 `omarchy webapp install` 的 custom-exec 参数生成,
  `Exec` 以 `omarchy-launch-webapp` 开头 → 删除、图标抓取、浏览器解析、
  uwsm 启动全部复用原生机制,`omarchy webapp remove` 照常可用
- 每个账号一个 `--user-data-dir`(独立 cookie 罐,可与主浏览器同时运行)
  位于 `~/.local/share/omarchy/webapp-profiles/<profile>/`
- 同时传 `--profile-directory=<profile>`:Wayland 下 Chrome app 窗口的 class
  为 `chrome-<域名>__-<内部profile名>`,因此每个账号的窗口 class 唯一,
  Hyprland 规则和 launch-or-focus 可区分(`--class` 在 Wayland 下无效)
- 向导中复用已有 profile = 多个应用共享一个登录身份(Google 只登一次);
  新建 profile = 完全隔离的账号

### 内存

相比原生 web app(挂主 Chrome 实例),每个账号多一个渲染进程 +
少量实例开销(轻页面实测 ~125–200 MB,重应用更多)。账号窗口全部关闭后
实例自动退出,内存释放。

## 窗口匹配示例

```lua
-- ~/.config/hypr/bindings.lua
o.bind("SUPER + ALT + W", "WhatsApp (Work)", "omarchy-launch-or-focus-webapp 'whatsapp.com__-work' 'https://web.whatsapp.com/' --user-data-dir=" .. os.getenv("HOME") .. "/.local/share/omarchy/webapp-profiles/work --profile-directory=work")
```

## 更新

```bash
git pull   # 命令是符号链接,无需重装;新增了命令文件时重跑 ./install.sh
```
