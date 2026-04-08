#!/usr/bin/env bash

set -euo pipefail

print_logo() {
  cat <<EOF
 _            _    __
| |_ _____  _| |_ / _| _____  ___   _
| __/ _ \ \/ / __| |_ / _ \ \/ / | | |
| ||  __/>  <| |_|  _| (_) >  <| |_| |
 \__\___/_/\_\\__|_|  \___/_/\_\\__, |
                                |___/
EOF
}

clean_path() {
  local fp="${1:-}"

  fp="${fp/#\~/$HOME}"
  fp="${fp%/}"
  while [[ "$fp" == *"//"* ]]; do
    fp="${fp//\/\//\/}"
  done
  fp="${fp//\'/}"
  fp="${fp//\"/}"

  printf '%s\n' "$fp"
}

choose_browser() {
  local choice

  echo "Choose browser:"
  echo "1) Firefox"
  echo "2) LibreWolf"
  read -rp "Selection [1/2]: " choice

  case "$choice" in
    1|"")
      BROWSER_NAME="Firefox"
      PROFILE_ROOT="$HOME/.mozilla/firefox"
      ;;
    2)
      BROWSER_NAME="LibreWolf"
      PROFILE_ROOT="$HOME/.librewolf"
      ;;
    *)
      echo "[!!] Invalid selection"
      exit 1
      ;;
  esac
}

ask_profile_path() {
  local fp

  echo
  echo "Selected browser: ${BROWSER_NAME}"
  echo "Default profile root: ${PROFILE_ROOT}"

  if [[ "$BROWSER_NAME" == "LibreWolf" ]]; then
    echo "If that path does not exist, check: ~/.config/librewolf/librewolf"
  fi

  if [[ "${1:-}" != "" ]]; then
    PROFILE_PATH="$(clean_path "$1")"
  else
    read -rp "Path to ${BROWSER_NAME} profile: " fp
    PROFILE_PATH="$(clean_path "$fp")"
  fi

  while [[ ! -d "$PROFILE_PATH" ]]; do
    echo "[!!] Directory does not exist: ${PROFILE_PATH}"
    read -rp "Path to ${BROWSER_NAME} profile: " fp
    PROFILE_PATH="$(clean_path "$fp")"
  done
}

backup_existing_profile() {
  local fp
  fp="$(clean_path "$1")"

  if [[ -d "${fp}/chrome" ]]; then
    echo "[!!] Backing up existing chrome directory..."
    mv -v "${fp}/chrome" "${fp}/chrome-$(date +%Y%m%d_%H%M%S).bak"
  fi
}

copy_chrome() {
  local fp
  fp="$(clean_path "$1")"

  if [[ ! -d "./chrome" ]]; then
    echo "[!!] Missing ./chrome directory near the script"
    return 1
  fi

  echo "Copying ./chrome -> ${fp}/chrome"
  cp -r "./chrome" "${fp}/chrome"
}

install_user_js() {
  local fp
  local install_js

  fp="$(clean_path "$1")"

  if [[ ! -f "./user.js" ]]; then
    echo "user.js not found, skipping."
    return 0
  fi

  read -rp "Do you want to install the user.js file? (Y/N): " install_js
  case "$install_js" in
    [Yy]*)
      cp -v "./user.js" "${fp}/user.js"
      ;;
    *)
      echo "Skipping user.js installation."
      ;;
  esac
}

tf_install() {
  local arg_path="${1:-}"

  printf "\nInstalling textfoxy...\n"

  choose_browser
  ask_profile_path "$arg_path"

  echo "Using ${BROWSER_NAME} profile @ ${PROFILE_PATH}"

  backup_existing_profile "${PROFILE_PATH}"
  copy_chrome "${PROFILE_PATH}"
  install_user_js "${PROFILE_PATH}"

  printf "✓ Installation completed\n"
}

print_logo
tf_install "${1:-}"
