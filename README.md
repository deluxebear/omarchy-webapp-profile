# omarchy-webapp-profile

[English](README.md) | [简体中文](README.zh-CN.md)

Multi-account web apps for [Omarchy](https://omarchy.org/) — adds a
per-account profile directory to `omarchy webapp install`, so the same site
can run under multiple logged-in accounts at the same time.

[![Demo video: install two WhatsApp accounts and run them side by side](docs/demo.jpg)](docs/demo.mp4)

*Demo (2:23, bilingual captions): menu wizard → two accounts side by side →
`list` / window classes → `remove --purge`. Click to play.*

## Install

**Option 1 — automatic, via Omarchy's built-in AI agent:**

Open your agent (`omarchy agent`, or SUPER+SHIFT+CTRL+A to pick one), paste the
repo URL and tell it to install itself:

> Install https://github.com/deluxebear/omarchy-webapp-profile

The agent clones the repo and runs `./install.sh` for you.

**Option 2 — manually:**

```bash
git clone https://github.com/deluxebear/omarchy-webapp-profile ~/Work/omarchy-webapp-profile
cd ~/Work/omarchy-webapp-profile
./install.sh
```

`install.sh` does two things:

1. **Symlinks** the commands in `bin/` into `~/.local/bin/`
2. Adds a menu entry to `~/.config/omarchy/extensions/omarchy-menu.jsonc`:
   **Install → Web App (Multi-account)** — sits next to the stock Web App
   installer, in the same themed floating terminal with the same gum wizard,
   plus one extra profile-picker step

Uninstall with `./install.sh --uninstall` (keeps all account data).

## Usage

```bash
omarchy-webapp-profile install          # wizard (or use the app menu)
omarchy-webapp-profile install <name> <url> <icon|-> <profile> [browser-flags...]
omarchy-webapp-profile launch <profile> <url> [flags...]
omarchy-webapp-profile list             # installed multi-account apps + data dir sizes
omarchy-webapp-profile remove <name> [--purge]
omarchy-webapp-profile purge <profile> [--yes]
omarchy-webapp-profile dir <profile>    # print the data dir path
```

## How it works

- Desktop entries are still created by the stock `omarchy webapp install`
  custom-exec argument, and their `Exec` lines still start with
  `omarchy-launch-webapp` — so removal, icon fetching, browser resolution and
  the uwsm launch path all keep working; `omarchy webapp remove` works as usual
- Each account gets its own `--user-data-dir` (a separate cookie jar that can
  run alongside your main browser) under
  `~/.local/share/omarchy/webapp-profiles/<profile>/`
- `--profile-directory=<profile>` is passed as well: on Wayland, Chrome app
  windows get the class `chrome-<origin>__-<internal-profile-name>`, so each
  account's window class is unique and Hyprland window rules / launch-or-focus
  can tell them apart (`--class` is ignored on Wayland)
- Reusing an existing profile in the wizard = several apps share one login
  identity (sign into Google once); creating a new profile = a fully isolated
  account

### Memory

Compared to a stock web app (which joins your main Chrome instance), each
account costs one extra renderer plus a small fixed overhead (~125–200 MB for
light pages, more for heavy apps). Once all of an account's windows are
closed, its instance exits and the memory is released.

## Window matching example

```lua
-- ~/.config/hypr/bindings.lua
o.bind("SUPER + ALT + W", "WhatsApp (Work)", "omarchy-launch-or-focus-webapp 'whatsapp.com__-work' 'https://web.whatsapp.com/' --user-data-dir=" .. os.getenv("HOME") .. "/.local/share/omarchy/webapp-profiles/work --profile-directory=work")
```

## Update

```bash
git pull   # commands are symlinked; re-run ./install.sh only if new files were added
```
