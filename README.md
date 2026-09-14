# 🚀 agy-switch

> **Universal Multi-Account Switcher for Google Antigravity CLI (`agy`)**  
> Switch between multiple Pro accounts instantly without losing your active chat sessions, conversation history, or projects.

[![Termux](https://img.shields.io/badge/Termux-Supported-brightgreen.svg)](https://termux.dev)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20Debian%20%7C%20Fedora%20%7C%20Arch-blue.svg)](https://www.kernel.org)
[![macOS](https://img.shields.io/badge/macOS-Supported-black.svg)](https://apple.com)
[![Windows](https://img.shields.io/badge/Windows-PowerShell-0078D6.svg)](https://microsoft.com)
[![Python](https://img.shields.io/badge/Python-3.7+-yellow.svg)](https://python.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## ⚡ The Problem & The Solution

- **The Problem**: By default, `agy` only maintains a single active Google account. If you hit your hourly/daily Pro rate limits or need to switch between personal and work accounts, you normally have to wipe your login, open a browser, and log in each time from scratch.
- **The Solution**: `agy-switch` vaults all your Google OAuth credentials with their `refresh_token`s. It allows instant 0.1-second account swapping **while keeping all your conversation databases and active sessions 100% intact**!

---

## ✨ Features

- 🔄 **Instant Account Switching**: Swap active accounts with `agy switch <alias>` or `agy switch <number>` in under 0.1s.
- 💾 **100% Session & History Preservation**: Conversations in `agy` are stored in local SQLite databases independent of user credentials. Switching accounts lets you resume the exact same conversation (`agy -c`) using your other account's Pro quota.
- 🔒 **Permanent Logins**: Never re-authenticate through a browser again. Each account's OAuth `refresh_token` is safely preserved in an isolated local vault.
- 📱 **Mobile & Termux Optimized**: Includes an interactive visual menu (`agy switch`) so you can tap numbers instead of typing names on mobile keyboards.
- ⚡ **Auto-Token Refresh**: Automatically refreshes short-lived Google access tokens in the background before activating them.
- 🌍 **Cross-Platform**: Zero third-party dependencies (pure Python 3 standard library). Runs identically on Android Termux, Linux, macOS, and Windows.
- 🧩 **Native Shell Integration**: Directly extends the official `agy` command (`agy accounts`, `agy switch`).

---

## 📥 Quick Installation

### Option 1: One-Line Installer (Termux / Linux / macOS)

Open your terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/superman-enamy/antigravity-cli-account-switcher/main/install.sh | bash
```

### Option 2: Clone & Install Manually

```bash
git clone https://github.com/superman-enamy/antigravity-cli-account-switcher.git
cd antigravity-cli-account-switcher
bash install.sh
```

### Option 3: Windows (PowerShell)

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/superman-enamy/antigravity-cli-account-switcher/main/install.ps1 | iex
```

*(Or clone the repository and run `.\install.ps1`)*

> [!TIP]
> After installation, reload your shell config with `source ~/.bashrc` (or `~/.zshrc`) or restart your terminal.

---

## 🎮 Usage Guide

### 1. View All Registered Accounts

```bash
agy accounts
```
*Output:*
```text
===============================================================
           ANTIGRAVITY CLI (AGY) ACCOUNT MANAGER              
===============================================================
  Sessions & History: Shared & Preserved across accounts
---------------------------------------------------------------
 [1] ● ACTIVE   main          personal@gmail.com           Valid (58m remaining)
       └─ Moin Personal
 [2] ○          work          work@company.com             Valid (45m remaining)
       └─ Moin Work
 [3] ○          pro3          backup@gmail.com             Valid (50m remaining)
       └─ Moin Backup
---------------------------------------------------------------
```

### 2. Switch Accounts Instantly

You can switch by alias, account number, or email:

```bash
# Switch by alias
agy switch work

# Switch by number
agy switch 2

# Switch by email
agy switch work@company.com
```

### 3. Interactive TUI Menu

Simply type:
```bash
agy switch
```
Press `1`, `2`, or `3` to instantly switch accounts, or `a` to add a new account.

### 4. Adding a New Account

```bash
agy-switch add pro4
```
1. Follow the Google OAuth login link shown in your terminal.
2. In your browser (use an **Incognito / Private tab** if already logged into an account), select your new Google account and grant permissions.
3. Paste the authorization code back into the terminal.
4. `agy-switch` automatically retrieves the account's Google email and display name and saves the profile permanently.

### 5. Check Active Account Status

```bash
agy-switch whoami
```

---

## 📋 Full Command Reference

| Command | Shorthand | Description |
| :--- | :--- | :--- |
| `agy accounts` | `agy-switch list` | Display all accounts with token health & active indicator |
| `agy switch` | `agy-switch` | Launch the interactive selection menu |
| `agy switch <target>` | `agy-switch switch <target>` | Switch active account by alias, number, or email |
| `agy-switch add [alias]` | `agy-switch login` | Add and authenticate a new Google account |
| `agy-switch whoami` | `agy-switch status` | Inspect the currently active account |
| `agy-switch refresh [alias]` | — | Proactively refresh an account's token with Google |
| `agy-switch remove <alias>` | `agy-switch rm` | Delete an account from the vault |
| `agy-switch rename <old> <new>` | — | Rename an account alias |
| `agy-switch import <file> [alias]` | — | Import an existing `antigravity-oauth-token` JSON file |
| `agy-switch export <alias> <file>` | — | Export an account's token JSON for backup/transfer |
| `agy-switch sync` | — | Sync latest refreshed token from CLI to vault |

---

## 🏗️ Architecture: How It Works

```
~/.gemini/
├── antigravity-cli/
│   ├── antigravity-oauth-token   <── [Currently Active Token (Swapped by agy-switch)]
│   ├── conversations/*.db        <── [All Chat Sessions & Context (NEVER Touched)]
│   ├── conversation_summaries.db <── [Session Index & Titles (NEVER Touched)]
│   └── settings.json             <── [CLI Configuration & Permissions]
│
└── accounts/                      <── [agy-switch Vault]
    ├── accounts.json              <── [Registry of all profiles & Google emails]
    ├── active.json                <── [Tracks currently active profile]
    └── profiles/
        ├── main/antigravity-oauth-token
        ├── work/antigravity-oauth-token
        └── pro3/antigravity-oauth-token
```

### Why Do Conversations Stay Preserved?
In `agy`, all conversation trajectories, steps, tools, and project contexts are saved in local SQLite databases in `~/.gemini/antigravity-cli/conversations/`. These databases do **not** bind conversations to an email address. 

When you run `agy switch`, the switcher only swaps the active OAuth credentials file. When you continue (`agy -c` or `agy --conversation <id>`), `agy` loads your exact previous session and makes subsequent API requests with the newly activated Pro account!

---

## 🛡️ Security & Privacy

- **100% Local**: No credentials or tokens ever leave your machine. There is no telemetry, external server, or third-party relay.
- **Strict File Permissions**: All token files are written with POSIX `0600` permissions (read/write only by the current user).
- **Official Google OAuth**: Direct communication exclusively with Google's official endpoints (`oauth2.googleapis.com` and `googleapis.com/oauth2/v3/userinfo`).

---

## 🗑️ Uninstallation

If you ever wish to remove `agy-switch`:

```bash
bash uninstall.sh
```

This restores your original `agy` binary, removes shell integration, and prompts whether to keep or delete your local account vault.

---

## 🤝 Contributing & License

Contributions, bug reports, and feature suggestions are welcome! Feel free to open an issue or submit a Pull Request.

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.
