---
layout: default
title: Updating Agent Task Manager
---

# Updating Agent Task Manager

The dashboard tells you when a newer release is available: a strip appears under the top bar, and the **About** dialog shows the installed version, the latest version and the exact commands to run. Update checks read a public version file at most once a day — no account, token or usage data is sent, and you can switch them off in **About → Updates**.

## Command-line core (`atm`)

Repeat the installer — it is idempotent, and does nothing when you are already current:

```bash
curl -fsSL https://atm.si-world.online/install.sh | sh
```

```powershell
irm https://atm.si-world.online/install.ps1 | iex
```

Or use npm directly:

```bash
npm install -g agent-task-manager-core@latest
atm restart
```

`atm restart` is required after upgrading the package: it installs the new core payload and restarts the daemon.

Pin a version when you need to:

```bash
ATM_VERSION=1.4.1 curl -fsSL https://atm.si-world.online/install.sh | sh
```

## VS Code extension

Install the newer VSIX from the Marketplace, then run **Developer: Reload Window**. The extension ships its own core payload; no global `atm` install is required.

## Checking from the terminal

```bash
atm version --check     # prints the installed version, check result goes to stderr
atm doctor              # read-only report, includes an Update section
```

## Rolling back

```bash
npm install -g agent-task-manager-core@<older-version>
atm restart
```

Your data in `~/atm_data` (Windows: `%USERPROFILE%\atm_data`) is never touched by upgrades or downgrades.
