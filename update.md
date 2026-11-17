---
layout: default
title: Updating Agent Task Manager
---

# Updating Agent Task Manager

The dashboard tells you when a newer release is available: a strip appears under the top bar, and the **About** dialog shows the installed version, the latest version and the exact commands to run. Update checks read a public version file at most once a day — no account, token or usage data is sent, and you can switch them off in **About → Updates**.

## Command-line core (`atm`)

Upgrade through npm — the same command works on macOS, Linux and Windows:

```bash
npm install -g agent-task-manager-core@latest
atm restart
```

`atm restart` is required after upgrading the package: it installs the new core payload and restarts the daemon.

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
