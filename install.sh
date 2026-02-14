#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/local/bin"
INSTALL_NAME="ireminder"
BUILD_CONFIG="release"

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Builds iReminderCLI and installs it to your PATH.

Options:
  --install-dir DIR   Install directory (default: /usr/local/bin)
  --name NAME         Installed command name (default: ireminder)
  --debug             Build debug binary instead of release
  -h, --help          Show this help message
EOF
}

require_option_value() {
  local option="$1"
  local value="${2:-}"
  if [[ -z "$value" ]]; then
    echo "Error: ${option} requires a value." >&2
    usage
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-dir)
      require_option_value "$1" "${2:-}"
      INSTALL_DIR="$2"
      shift 2
      ;;
    --name)
      require_option_value "$1" "${2:-}"
      INSTALL_NAME="$2"
      shift 2
      ;;
    --debug)
      BUILD_CONFIG="debug"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown option '$1'" >&2
      usage
      exit 1
      ;;
  esac
done

if ! command -v swift >/dev/null 2>&1; then
  echo "Error: swift is not installed or not on PATH." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

echo "Building iReminderCLI (${BUILD_CONFIG})..."
swift build -c "$BUILD_CONFIG"

BINARY_PATH="$REPO_ROOT/.build/${BUILD_CONFIG}/iReminderCLI"
if [[ ! -x "$BINARY_PATH" ]]; then
  echo "Error: built binary not found at $BINARY_PATH" >&2
  exit 1
fi

TARGET_PATH="${INSTALL_DIR}/${INSTALL_NAME}"
PARENT_DIR="$(dirname "$INSTALL_DIR")"

install_with_or_without_sudo() {
  local cmd=("$@")
  if "${cmd[@]}"; then
    return 0
  fi
  if command -v sudo >/dev/null 2>&1; then
    echo "Retrying with sudo..."
    sudo "${cmd[@]}"
  else
    echo "Error: permission denied and sudo is not available." >&2
    exit 1
  fi
}

if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Creating install directory: $INSTALL_DIR"
  if [[ -w "$PARENT_DIR" ]]; then
    mkdir -p "$INSTALL_DIR"
  else
    install_with_or_without_sudo mkdir -p "$INSTALL_DIR"
  fi
fi

echo "Installing to $TARGET_PATH"
if [[ -w "$INSTALL_DIR" ]]; then
  cp "$BINARY_PATH" "$TARGET_PATH"
  chmod 755 "$TARGET_PATH"
else
  install_with_or_without_sudo cp "$BINARY_PATH" "$TARGET_PATH"
  install_with_or_without_sudo chmod 755 "$TARGET_PATH"
fi

echo "Installed: $TARGET_PATH"
if command -v "$INSTALL_NAME" >/dev/null 2>&1; then
  echo "On PATH as: $(command -v "$INSTALL_NAME")"
else
  echo "Warning: '$INSTALL_DIR' is not on PATH in this shell."
fi
