#!/usr/bin/env bash
#
# agy-switch Installer
# Universal multi-account switcher for Google Antigravity CLI (agy)
# Supports: Android Termux, Linux (Ubuntu, Debian, Fedora, Arch), and macOS
#

set -e

# --- Styling ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}"
cat << 'EOF'
   __ _  __ _ _   _       _____          _ _       _     
  / _` |/ _` | | | |     /  ___|        (_) |     | |    
 | (_| | (_| | |_| |_____\ `--.__      ___ _| |_ ___| |__  
  \__,_|\__, |\__, |_____/`--. \ \ /\ / / | __/ __| '_ \ 
         __/ | __/ |     /\__/ /\ V  V /| | || (__| | | |
        |___/ |___/      \____/  \_/\_/ |_|\__\___|_| |_|
EOF
echo -e "${NC}"
echo -e "${BOLD}Antigravity CLI (agy) Multi-Account Switcher Installer${NC}\n"

# --- 1. Python 3 Check ---
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}Error: Python 3 is required but not installed.${NC}"
    if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
        echo -e "${YELLOW}Install it using: pkg install python${NC}"
    elif [ "$(uname)" = "Darwin" ]; then
        echo -e "${YELLOW}Install it using: brew install python3${NC}"
    else
        echo -e "${YELLOW}Install it using your package manager (e.g., sudo apt install python3)${NC}"
    fi
    exit 1
fi

# --- 2. Detect Platform & Target Directory ---
IS_TERMUX=0
if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=1
    TARGET_DIR="${PREFIX:-/data/data/com.termux/files/usr}/bin"
else
    TARGET_DIR="$HOME/.local/bin"
    if [ -w "/usr/local/bin" ] && [ -n "$INSTALL_GLOBAL" ]; then
        TARGET_DIR="/usr/local/bin"
    fi
fi

mkdir -p "$TARGET_DIR"

# --- 3. Resolve agy-switch source ---
SCRIPT_PATH=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/agy-switch" ]; then
    SCRIPT_PATH="$SCRIPT_DIR/agy-switch"
    echo -e "${CYAN}Installing from local files...${NC}"
    cp "$SCRIPT_PATH" "$TARGET_DIR/agy-switch"
else
    echo -e "${CYAN}Downloading latest agy-switch...${NC}"
    REPO_URL="${GITHUB_REPO:-https://raw.githubusercontent.com/superman-enamy/antigravity-cli-account-switcher/main}"
    curl -fsSL "$REPO_URL/agy-switch" -o "$TARGET_DIR/agy-switch"
fi

chmod +x "$TARGET_DIR/agy-switch"

# Fix shebang if on Termux
if [ "$IS_TERMUX" -eq 1 ]; then
    if command -v termux-fix-shebang >/dev/null 2>&1; then
        termux-fix-shebang "$TARGET_DIR/agy-switch"
    else
        sed -i '1s|^.*$|#!/data/data/com.termux/files/usr/bin/python3|' "$TARGET_DIR/agy-switch"
    fi
fi

# Create symlink agy-account
ln -sf "$TARGET_DIR/agy-switch" "$TARGET_DIR/agy-account"

# --- 4. Setup Wrapper and Shell Integration ---
WRAPPER_BLOCK='
# Antigravity CLI (agy) Account Switcher integration
agy() {
    if [ "$1" = "accounts" ] || [ "$1" = "account" ]; then
        shift
        agy-switch list "$@"
    elif [ "$1" = "switch" ]; then
        shift
        if [ -z "$1" ]; then
            agy-switch
        else
            agy-switch switch "$@"
        fi
    elif [ "$1" = "quota" ] || [ "$1" = "usage" ] || [ "$1" = "verify" ] || [ "$1" = "check" ]; then
        shift
        agy-switch check "$@"
    elif [ "$1" = "refresh" ]; then
        shift
        agy-switch refresh "$@"
    elif [ "$1" = "model" ] || [ "$1" = "models" ]; then
        shift
        agy-switch model "$@"
    else
        \command agy "$@"
    fi
}
'

# Handle Termux binary wrapping if applicable
if [ "$IS_TERMUX" -eq 1 ]; then
    TERMUX_BIN="$TARGET_DIR/agy"
    TERMUX_REAL="$TARGET_DIR/agy-real"

    if [ -f "$TERMUX_BIN" ] && [ ! -f "$TERMUX_REAL" ]; then
        if file "$TERMUX_BIN" | grep -q "ELF"; then
            echo -e "${CYAN}Creating native agy binary wrapper in Termux...${NC}"
            cp "$TERMUX_BIN" "$TERMUX_REAL"
            cat << 'EOF' > "$TERMUX_BIN"
#!/data/data/com.termux/files/usr/bin/bash
if [ "$1" = "switch" ]; then
    shift
    if [ -z "$1" ]; then
        exec /data/data/com.termux/files/usr/bin/agy-switch
    else
        exec /data/data/com.termux/files/usr/bin/agy-switch switch "$@"
    fi
elif [ "$1" = "accounts" ] || [ "$1" = "account" ]; then
    shift
    exec /data/data/com.termux/files/usr/bin/agy-switch list "$@"
elif [ "$1" = "quota" ] || [ "$1" = "usage" ] || [ "$1" = "verify" ] || [ "$1" = "check" ]; then
    shift
    exec /data/data/com.termux/files/usr/bin/agy-switch check "$@"
elif [ "$1" = "refresh" ]; then
    shift
    exec /data/data/com.termux/files/usr/bin/agy-switch refresh "$@"
elif [ "$1" = "model" ] || [ "$1" = "models" ]; then
    shift
    exec /data/data/com.termux/files/usr/bin/agy-switch model "$@"
else
    exec /data/data/com.termux/files/usr/bin/agy-real "$@"
fi
EOF
            chmod +x "$TERMUX_BIN"
        fi
    fi
fi

# Inject PATH and shell function into shell rc files
CONFIG_FILES=()
[ -f "$HOME/.bashrc" ] && CONFIG_FILES+=("$HOME/.bashrc")
[ -f "$HOME/.zshrc" ] && CONFIG_FILES+=("$HOME/.zshrc")
[ -f "$HOME/.bash_profile" ] && CONFIG_FILES+=("$HOME/.bash_profile")

# If none exist, create .bashrc
if [ ${#CONFIG_FILES[@]} -eq 0 ]; then
    touch "$HOME/.bashrc"
    CONFIG_FILES+=("$HOME/.bashrc")
fi

for CFG in "${CONFIG_FILES[@]}"; do
    # Check if PATH contains TARGET_DIR
    if ! grep -q "$TARGET_DIR" "$CFG" 2>/dev/null; then
        echo -e "\nexport PATH=\"$TARGET_DIR:\$PATH\"" >> "$CFG"
    fi
    # Only add shell function on non-Termux systems (Termux uses the native binary wrapper)
    if [ "$IS_TERMUX" -eq 0 ] && ! grep -q "Antigravity CLI (agy) Account Switcher integration" "$CFG" 2>/dev/null; then
        echo -e "$WRAPPER_BLOCK" >> "$CFG"
    fi
done

# --- 5. Initialize Vault & Auto-Register Current Login ---
echo -e "\n${CYAN}Initializing account vault...${NC}"
"$TARGET_DIR/agy-switch" list || true

echo -e "\n${GREEN}${BOLD}✔ Installation completed successfully!${NC}\n"
echo -e "${BOLD}Quick Usage:${NC}"
echo -e "  ${CYAN}agy accounts${NC}             List all registered Google Pro accounts"
echo -e "  ${CYAN}agy switch${NC}               Interactive account picker menu"
echo -e "  ${CYAN}agy switch pro2${NC}          Switch to account 'pro2' instantly"
echo -e "  ${CYAN}agy model${NC}                List available AI models & select active model"
echo -e "  ${CYAN}agy model argon${NC}          Switch directly to Gemini 4 Argon (High)"
echo -e "  ${CYAN}agy model opus${NC}           Switch directly to Claude Opus 5.5"
echo -e "  ${CYAN}agy-switch add <alias>${NC}   Log in & register another Google Pro account"
echo -e "  ${CYAN}agy-switch whoami${NC}        Show active account, tier, and model"
echo
echo -e "${YELLOW}Note: Restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to activate commands.${NC}\n"
