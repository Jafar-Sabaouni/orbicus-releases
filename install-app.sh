#!/usr/bin/env bash
set -e

# Orbicus Workspace Desktop One-Line Installer
VERSION="v1.0.1"
RELEASE_REPO="Jafar-Sabaouni/orbicus-releases"
BASE_URL="https://github.com/${RELEASE_REPO}/releases/download/${VERSION}"

echo "==> Installing Orbicus Workspace (${VERSION})..."

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin)
    if [ "$ARCH" = "arm64" ]; then
      FILE="Orbicus-1.0.1-arm64.dmg"
    else
      FILE="Orbicus-1.0.1-x64.dmg"
    fi

    TMP_DIR="$(mktemp -d)"
    DMG_PATH="${TMP_DIR}/${FILE}"

    echo "==> Downloading ${FILE}..."
    curl -fL --progress-bar "${BASE_URL}/${FILE}" -o "${DMG_PATH}"

    echo "==> Mounting disk image..."
    MOUNT_POINT=$(hdiutil attach "${DMG_PATH}" -nobrowse -readonly | grep "/Volumes/" | awk '{for(i=3;i<=NF;++i)printf $i""FS ; print ""}' | sed 's/[[:space:]]*$//')

    APP_SOURCE="${MOUNT_POINT}/orbicus-app.app"
    if [ ! -d "${APP_SOURCE}" ]; then
      APP_SOURCE="${MOUNT_POINT}/Orbicus.app"
    fi

    if [ ! -d "${APP_SOURCE}" ]; then
      echo "Error: Could not locate app bundle inside disk image."
      hdiutil detach "${MOUNT_POINT}" -quiet || true
      rm -rf "${TMP_DIR}"
      exit 1
    fi

    DEST_APP="/Applications/Orbicus.app"

    echo "==> Installing to /Applications/Orbicus.app..."
    rm -rf "${DEST_APP}"
    cp -R "${APP_SOURCE}" "${DEST_APP}"

    echo "==> Clearing macOS quarantine attributes..."
    xattr -cr "${DEST_APP}" 2>/dev/null || true

    echo "==> Unmounting disk image..."
    hdiutil detach "${MOUNT_POINT}" -quiet || true
    rm -rf "${TMP_DIR}"

    echo ""
    echo "=========================================================="
    echo "  Orbicus Workspace successfully installed to /Applications!"
    echo "  You can launch Orbicus now from Spotlight or Applications."
    echo "=========================================================="
    ;;

  Linux)
    FILE="Orbicus-1.0.1.AppImage"
    INSTALL_DIR="${HOME}/.local/bin"
    mkdir -p "${INSTALL_DIR}"
    TARGET="${INSTALL_DIR}/orbicus-app"

    echo "==> Downloading ${FILE}..."
    curl -fL --progress-bar "${BASE_URL}/${FILE}" -o "${TARGET}"
    chmod +x "${TARGET}"

    echo ""
    echo "=========================================================="
    echo "  Orbicus Workspace installed to ${TARGET}!"
    echo "  Ensure ~/.local/bin is in your PATH to launch directly."
    echo "=========================================================="
    ;;

  *)
    echo "Error: Unsupported operating system: ${OS}"
    echo "For Windows, install via: irm https://orbicus.dev/install-app.ps1 | iex"
    exit 1
    ;;
esac
