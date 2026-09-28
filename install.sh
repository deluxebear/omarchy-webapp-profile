#!/bin/bash

# omarchy-webapp-profile installer.
#
#   ./install.sh              symlink commands into ~/.local/bin + add menu entry
#   ./install.sh --uninstall  remove symlinks + menu entry (keeps all your data)
#
# Commands are symlinked (not copied), so updating is just `git pull`.

set -e

REPO_DIR=$(cd "$(dirname "$0")" && pwd)
BIN_DIR="$HOME/.local/bin"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"

# Same shape as the stock "install.webapp" entry, so both live side by side
# under Install. The action uses the identical presentation wrapper the stock
# entry uses: themed floating terminal + logo + done screen.
MENU_ENTRY='  "install.webapp-profile": {"icon":"", "label":"Web App (Multi-account)", "description":"Install a web app with its own profile directory - run the same site under multiple accounts", "action":"omarchy-launch-floating-terminal-with-presentation omarchy-webapp-profile-install"},'

link_bins() {
  mkdir -p "$BIN_DIR"
  local f name
  for f in "$REPO_DIR"/bin/*; do
    name=${f##*/}
    if [[ -e $BIN_DIR/$name && ! -L $BIN_DIR/$name ]]; then
      echo "Preserving existing $BIN_DIR/$name as $name.pre-plugin"
      mv "$BIN_DIR/$name" "$BIN_DIR/$name.pre-plugin"
    fi
    ln -sfn "$f" "$BIN_DIR/$name"
    echo "linked  $name -> $BIN_DIR/"
  done
}

install_menu_entry() {
  if [[ ! -f $MENU_FILE ]]; then
    mkdir -p "$(dirname "$MENU_FILE")"
    printf '{\n}\n' >"$MENU_FILE"
  fi
  grep -q '"install\.webapp-profile"' "$MENU_FILE" && return 0
  # Insert before the final closing brace. The extension file is JSONC with
  # trailing commas tolerated (the stock file uses them too).
  if [[ $(tail -n 1 "$MENU_FILE" | tr -d '[:space:]') == "}" ]]; then
    sed -i "\$i\\$MENU_ENTRY" "$MENU_FILE"
    echo "menu    added 'Install → Web App (Multi-account)'"
  else
    echo "warn:   could not edit $MENU_FILE automatically; add this line before the closing brace:"
    echo "$MENU_ENTRY"
  fi
}

uninstall_menu_entry() {
  [[ -f $MENU_FILE ]] && sed -i '/"install\.webapp-profile"/d' "$MENU_FILE"
}

case ${1:-} in
--uninstall)
  for f in "$REPO_DIR"/bin/*; do
    name=${f##*/}
    [[ -L $BIN_DIR/$name ]] && rm "$BIN_DIR/$name"
  done
  uninstall_menu_entry
  echo "Removed commands and menu entry."
  echo "Profile data kept in ~/.local/share/omarchy/webapp-profiles/"
  echo "Installed app launchers kept; remove with: omarchy webapp remove <name>"
  ;;
*)
  link_bins
  install_menu_entry
  echo
  echo "Done. Two ways to use it:"
  echo "  App menu → Install → Web App (Multi-account)   (wizard like the stock one)"
  echo "  omarchy-webapp-profile --help                   (CLI: install/list/remove/purge)"
  echo "Update later with: git pull"
  ;;
esac
