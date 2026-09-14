#!/usr/bin/env bash
#
# agy-switch Uninstaller
# Cleans up agy-switch, restores original agy binary, and removes shell wrappers.
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}Uninstalling agy-switch...${NC}\n"

IS_TERMUX=0
if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=1
    TARGET_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"
else
    TARGET_DIR="$HOME/.local/bin"
    [ -f "/usr/local/bin/agy-switch" ] && TARGET_DIR="/usr/local/bin"
fi

# Remove binaries & symlinks
[ -f "$TARGET_DIR/agy-switch" ] && rm -f "$TARGET_DIR/agy-switch"
[ -L "$TARGET_DIR/agy-account" ] && rm -f "$TARGET_DIR/agy-account"

# Restore original agy binary if wrapped on Termux
if [ "$IS_TERMUX" -eq 1 ]; then
    if [ -f "$TARGET_DIR/agy-real" ]; then
        echo -e "${CYAN}Restoring original agy binary in Termux...${NC}"
        mv -f "$TARGET_DIR/agy-real" "$TARGET_DIR/agy"
    fi
fi

# Clean shell rc configs
for CFG in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
    if [ -f "$CFG" ]; then
        # Remove wrapper block if present
        sed -i '/# Antigravity CLI (agy) Account Switcher integration/,/^[[:space:]]*}/d' "$CFG" 2>/dev/null || true
    fi
done

read -p "Do you also want to remove all saved account tokens in ~/.gemini/accounts? [y/N]: " -r ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.gemini/accounts"
    echo -e "${GREEN}Removed account vault ~/.gemini/accounts.${NC}"
else
    echo -e "${CYAN}Preserved account vault ~/.gemini/accounts for future use.${NC}"
fi

echo -e "\n${GREEN}${BOLD}✔ agy-switch has been uninstalled.${NC}\n"
