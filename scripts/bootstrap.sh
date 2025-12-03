#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"

install_uv() {
  if [ ! -x "${HOME}/.local/bin/uv" ]; then
    echo "[uv] installing to \$HOME/.local/bin..."
    curl -fsSL https://astral.sh/uv/install.sh | sh
  else
    echo "[uv] already installed at \$HOME/.local/bin/uv"
  fi
}

install_mise() {
  if [ ! -x "${HOME}/.local/bin/mise" ]; then
    echo "[mise] installing to \$HOME/.local/bin..."
    curl -fsSL https://mise.run | sh
  else
    echo "[mise] already installed at \$HOME/.local/bin/mise"
  fi
}

install_make_debian() {
  if ! command -v make >/dev/null 2>&1; then
    echo "[make] installing via apt..."
    sudo apt-get update -y
    sudo apt-get install -y make
  else
    echo "[make] already available on PATH"
  fi
}

install_homebrew_macos() {
  if command -v brew >/dev/null 2>&1; then
    echo "[brew] already installed"
    return
  fi

  echo "[brew] installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "[brew] installed. PATH changes will be handled later by Ansible."
}

case "$OS" in
  Linux)
    if [ -f /etc/debian_version ]; then
      echo "[os] Detected Debian-like Linux"
      install_make_debian
      install_uv
      install_mise
    else
      echo "Unsupported Linux distribution (only Debian/Ubuntu-like is handled)" >&2
      exit 1
    fi
    ;;

  Darwin)
    echo "[os] Detected macOS"

    # make is usually provided by Xcode CLT
    if ! command -v make >/dev/null 2>&1; then
      echo "[make] not found. Please install Xcode Command Line Tools:"
      echo "       xcode-select --install"
    else
      echo "[make] already available on PATH"
    fi

    install_homebrew_macos
    install_uv
    install_mise
    ;;

  *)
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

echo
echo "Bootstrap complete."
echo "uv:   \$HOME/.local/bin/uv"
echo "mise: \$HOME/.local/bin/mise"
echo "brew: /opt/homebrew/bin/brew or /usr/local/bin/brew (on macOS)"

