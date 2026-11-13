#
# Agent Task Manager CLI installer (Windows PowerShell)
# 任务 A/184 · P0-5；A/215：一键安装 / 幂等升级 / 权限兜底
#
# One-line install — also the upgrade command:
#   irm https://atm.si-world.online/install.ps1 | iex
#
# Options (environment variables):
#   $env:ATM_VERSION = "1.4.1"                 install / pin a specific version (default: latest)
#   $env:ATM_NPM_PACKAGE = "C:\path\core.tgz"  local tarball or another package name
#   $env:ATM_NPM_REGISTRY = "https://..."      registry mirror (e.g. https://registry.npmmirror.com)
#   $env:ATM_NPM_PREFIX = "C:\npm-global"      user-level prefix when the global one is not writable
#   $env:ATM_FORCE = "1"                       reinstall even when that version is already current
#
$ErrorActionPreference = 'Stop'

$Package = if ($env:ATM_NPM_PACKAGE) { $env:ATM_NPM_PACKAGE } else { 'agent-task-manager-core' }
$Version = if ($env:ATM_VERSION) { $env:ATM_VERSION } else { '' }
$Registry = if ($env:ATM_NPM_REGISTRY) { $env:ATM_NPM_REGISTRY } else { '' }
$PrefixOverride = if ($env:ATM_NPM_PREFIX) { $env:ATM_NPM_PREFIX } else { '' }
$Force = if ($env:ATM_FORCE) { $env:ATM_FORCE } else { '' }

function Fail([string]$Message) {
    Write-Host "[atm] $Message" -ForegroundColor Red
    throw 'atm installer stopped'
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Fail 'Node.js >= 18 is required. Install it with:  winget install -e --id OpenJS.NodeJS.LTS  — then reopen the terminal and rerun.'
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Fail 'npm is required — it ships with Node.js. Install Node.js >= 18 and rerun.'
}

$nodeVersion = (& node -p 'process.versions.node').Trim()
$major = [int]($nodeVersion.Split('.')[0])
if ($major -lt 18) {
    Fail "Node.js >= 18 is required (current: $nodeVersion). Upgrade Node.js and rerun."
}

# 已是最新版本时直接结束（幂等；固定版本 / 本地 tgz / ATM_FORCE 不走此分支）
$current = ''
try { $current = (& atm version 2>$null | Out-String).Trim() } catch { $current = '' }
if (-not $Force -and $current) {
    $latest = ''
    if ($Version) {
        $latest = $Version
    } else {
        try { $latest = (& npm view $Package version 2>$null | Out-String).Trim() } catch { $latest = '' }
    }
    if ($latest -and $latest -eq $current) {
        Write-Host "atm $current is already installed and up to date."
        Write-Host 'Use $env:ATM_FORCE = "1" to reinstall, or $env:ATM_VERSION = "<version>" to install another version.'
        return
    }
}

# 目标规格：本地 tgz / 带作用域 / 已带版本时原样使用，否则拼上 ATM_VERSION
$isLocalPath = $Package -match '[\\/]' -or $Package -match '\.tgz$'
$spec = $Package
if ($Version -and -not $isLocalPath -and $Package -notmatch '@') {
    $spec = "$Package@$Version"
}

function Install-Global([string[]]$ExtraArgs) {
    if ($Registry) {
        & npm install -g --registry $Registry @ExtraArgs
    } else {
        & npm install -g @ExtraArgs
    }
    return $LASTEXITCODE
}

Write-Host "Installing $spec ..."
$binDir = ''
$code = Install-Global @($spec)
if ($code -ne 0) {
    $fallback = if ($PrefixOverride) { $PrefixOverride } else { Join-Path $env:APPDATA 'npm' }
    Write-Host ''
    Write-Host "Global install failed (usually a permissions issue)."
    Write-Host "Retrying with a user-level prefix: $fallback"
    New-Item -ItemType Directory -Force -Path $fallback | Out-Null
    $code = Install-Global @('--prefix', $fallback, $spec)
    if ($code -ne 0) {
        Fail "npm install failed.`n  Check your network or registry, or install manually:`n    npm install -g --prefix `"$fallback`" `"$spec`""
    }
    $binDir = $fallback
}
if (-not $binDir) {
    $npmPrefix = ''
    try { $npmPrefix = (& npm config get prefix 2>$null | Out-String).Trim() } catch { $npmPrefix = '' }
    if ($npmPrefix) { $binDir = $npmPrefix }
}

$atmCmd = ''
if ($binDir -and (Test-Path (Join-Path $binDir 'atm.cmd'))) {
    $atmCmd = Join-Path $binDir 'atm.cmd'
} else {
    $found = Get-Command atm -ErrorAction SilentlyContinue
    if ($found) { $atmCmd = $found.Source }
}
if (-not $atmCmd) {
    Fail "Installed, but the 'atm' command is not on PATH.`n  Add this directory to your user PATH, then open a new terminal:`n    $binDir`n  If atm.cmd still does not exist there, the installed package does not ship the atm binary — check the npm output above."
}

$installed = (& $atmCmd version | Out-String).Trim()
Write-Host "atm $installed installed: $atmCmd"

if ($binDir) {
    $pathParts = ($env:PATH -split ';') | Where-Object { $_ }
    if ($pathParts -notcontains $binDir) {
        Write-Host ''
        Write-Host "Note: $binDir is not on your PATH yet. Add it to your user PATH:"
        Write-Host "  [Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ';$binDir', 'User')"
    }
}

Write-Host ''
Write-Host 'Next:'
Write-Host '  atm                  # start the core and open the welcome page'
Write-Host '  atm service auto     # optional: start automatically at sign-in (undo: atm service remove auto)'
Write-Host '  atm mcp              # stdio MCP endpoint for Claude Code / Codex / Cursor'
Write-Host ''
Write-Host 'Upgrade any time by rerunning this installer.'
Write-Host 'Uninstall: npm uninstall -g agent-task-manager-core (your data in %USERPROFILE%\atm_data is kept).'
Write-Host 'If PowerShell blocks atm.ps1: Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned'
