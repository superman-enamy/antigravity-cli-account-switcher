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
- 🤖 **On-Demand AI Model Synchronization**: Synchronizes available models dynamically when you switch to an account. Automatically unlocks and selects your Pro model (Gemini 4 Argon, Claude Opus 5.5, Claude Sonnet 5.5, GPT-OSS) when switching to Pro accounts, and gracefully falls back to supported Gemini models on Standard accounts.
- 🎯 **Direct Model Switcher (`agy model`)**: Inspect available models, remaining quotas, and switch active AI models in 1 second (`agy model argon`, `agy model opus`, `agy model sonnet`, `agy model 1`).
- 🔒 **Permanent Logins**: Never re-authenticate through a browser again. Each account's OAuth `refresh_token` is safely preserved in an isolated local vault.
- 📱 **Mobile & Termux Optimized**: Includes an interactive visual menu (`agy switch`) so you can tap numbers instead of typing names on mobile keyboards.
- ⚡ **Auto-Token Refresh**: Automatically refreshes short-lived Google access tokens in the background before activating them.
- 🌍 **Cross-Platform**: Zero third-party dependencies (pure Python 3 standard library). Runs identically on Android Termux, Linux, macOS, and Windows.
- 🧩 **Native Shell Integration**: Directly extends the official `agy` command (`agy accounts`, `agy switch`, `agy model`).

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

### 6. Manage & Switch AI Models (On-Demand)

`agy-switch` queries Google's model backend on-demand when you switch to an account, dynamically tailoring `settings.json` to that account's entitled tier (Pro vs Standard):

- **Automatic Tier Adaptation**: Switching to a Pro account immediately unlocks and restores Pro models (Gemini 4 Argon, Claude Opus 5.5, Claude Sonnet 5.5, GPT-OSS). Switching to a Standard/Plus account gracefully falls back to Gemini 2.5 Pro without errors or stale configurations.
- **View & Switch Models**:

```bash
# View available models & quota for the active account
agy model

# Switch model directly by name or alias
agy model argon
agy model opus
agy model sonnet
agy model gpt
agy model gemini-pro

# Switch by index number
agy model 1
```

---

## 📋 Full Command Reference

| Command | Shorthand | Description |
| :--- | :--- | :--- |
| `agy accounts` | `agy-switch list` | Display all accounts with token health & active indicator |
| `agy switch` | `agy-switch` | Launch the interactive selection menu |
| `agy switch <target>` | `agy-switch switch <target>` | Switch active account (fetches models & auto-adapts tier) |
| `agy model` | `agy-switch model` | List all available AI models with live quotas & active indicator |
| `agy model <name\|idx>` | `agy-switch model <target>` | Switch active model (`argon`, `opus`, `sonnet`, `gemini-pro`, `1`) |
| `agy-switch add [alias]` | `agy-switch login` | Add and authenticate a new Google account |
| `agy quota [alias]` | `agy usage`, `agy verify` | Live rate limits (Gemini, Claude, GPT) & instant verification link |
| `agy refresh [alias]` | `agy-switch refresh` | Proactively refresh an account's token with Google |
| `agy-switch whoami` | `agy-switch status` | Inspect active account, plan tier, and active model |
| `agy-switch remove <alias>` | `agy-switch rm` | Delete an account from the vault |
| `agy-switch rename <old> <new>` | — | Rename an account alias |
| `agy-switch import <file> [alias]` | — | Import an existing `antigravity-oauth-token` JSON file |
| `agy-switch export <alias> <file>` | — | Export an account's token JSON for backup/transfer |
| `agy-switch sync` | — | Sync latest refreshed token from CLI to vault |

---

## 💡 Troubleshooting & Crucial Tips

### 1. ⚠️ Google Verification Trap ("Eligibility check failed: Verify your account")
If Google prompts you with an account verification link during startup or after switching accounts:

```text
Eligibility Check
  ⎿ Eligibility check failed: Your current account is not eligible for Antigravity.
    Verify your account to continue.
    Alternatively, try signing in with another personal Google account.
    Please verify your account in your browser to continue:
    https://accounts.google.com/signin/continue?sarp=1&scc=1&...&flowName=GlifWebSignIn&authuser
```

> [!IMPORTANT]
> **Two Essential Steps to Prevent Endless Verification Loops:**
>
> 1. **Open Link in Incognito / Private Tab**:
>    On mobile (especially Android / Chrome), clicking the link directly defaults to **Account 0** (your primary device account). Even if you complete the verification screen, Google will have verified your *primary* account instead of the *secondary* account you just switched to!  
>    **Fix:** Long-press/copy the URL, open a **Private / Incognito tab** in your browser, and sign in with the **exact Google email** being verified.
>
> 2. **Run `agy-switch refresh` Immediately After Verification**:
>    ```bash
>    agy-switch refresh
>    ```
>    Once you see `auth_success_gemini` in your browser, Google's backend marks your account as verified. However, the local OAuth access token cached on your machine still carries the previous unverified state. Running `agy-switch refresh` forces Google's OAuth endpoint to issue a brand-new access token with the updated eligibility claims!
>
> 3. **Restart / Resume your session**:
>    ```bash
>    agy -c
>    ```

---

### 2. 🔄 Switching Accounts Across Multiple Terminals
* The `agy` CLI loads credentials into memory when launched. If Terminal 1 is running an active session and you run `agy switch <account>` in Terminal 2, Terminal 1 will **not** switch accounts mid-conversation.
* **Best Practice Workflow**:
  1. In your active CLI session, type `/exit` (or press `Ctrl+D`).
  2. Switch account: `agy switch <alias>`
  3. Resume your exact conversation: `agy -c` (all context, tools, and history are preserved).

---

### 3. 📱 Termux Native Binary & Gemini 4 Argon Support (`v1.5.4+`)
If you are on Android Termux and previously installed an older unofficial `glibc`-wrapped `agy` binary (such as `v1.1.27` / `agy.va39`), newer models like **Gemini 4 Argon (`gemini-4-argon-high`)** will be rejected by the old binary's local model resolver and outdated User-Agent version gate.

Google now provides an **official native Android ARM64 (Bionic)** build (`v1.5.4+`) that runs directly on Termux without any `glibc` wrapper and includes built-in `agy update` and **Gemini 4 Argon** support:

```bash
# Check your current underlying binary version
agy-real --version

# Update to the latest official Google Android ARM64 release anytime
agy update
```

*(If migrating from an older unofficial `glibc` package on Termux, extract Google's `android_arm64` archive from `https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/android_arm64.json` directly into `$PREFIX/bin/agy-real` and `chmod +x $PREFIX/bin/agy-real`).*

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

---

## 🛠️ Development & Session Reference

- **Development Session ID**: `282a378d-7e20-4699-985e-bfd415a306c1`

> **Tip for Future Maintenance**: You can resume this exact development session and context in Antigravity CLI anytime to debug, maintain, or add new features by running:
> ```bash
> agy --conversation 282a378d-7e20-4699-985e-bfd415a306c1
> ```
