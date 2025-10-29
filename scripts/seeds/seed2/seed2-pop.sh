#!/usr/bin/env bash

SCRIPT_SOURCE="${BASH_SOURCE[0]}"
SCRIPT_NAME="$(basename "$SCRIPT_PATH")"
echo "$SCRIPT_NAME ran"


is_root() {
  [ "$(id -u)" -eq 0 ]
}


can_sudo() {
  # expects a password file path in $SUDO_FILE
  [ -f "$SUDO_FILE" ] || return 1
  # sudo -S -p '' -v <"$SUDO_FILE" 2>/dev/null
  sudo ls
}

# --- paths ---
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# --- environment info ---
echo "========== DEBUG INFO =========="
echo "Script path      : $SCRIPT_PATH"
echo "Script directory : $SCRIPT_DIR"
echo "Current working  : $(pwd)"
echo "USER             : $USER"
echo "HOME             : $HOME"
echo "SUDO_FILE        : $SUDO_FILE"

# --- privilege info ---
if is_root; then
  echo "is_root          : YES"
else
  echo "is_root          : NO"
fi

if can_sudo; then
  echo "can_sudo         : YES"
else
  echo "can_sudo         : NO"
fi
echo "================================"
echo "SUDO_CMD         : $SUDO_CMD"










