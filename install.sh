#!/usr/bin/env sh
#
# Agent Task Manager CLI installer (Linux / macOS)
# 任务 A/184 · P0-5；A/215：一键安装 / 幂等升级 / 权限兜底
#
# One-line install — also the upgrade command:
#   curl -fsSL https://atm.si-world.online/install.sh | sh
#
# Options (environment variables):
#   ATM_VERSION=1.4.1                 install / pin a specific version (default: latest)
#   ATM_NPM_PACKAGE=/path/core.tgz    install from a local tarball or another package name
#   ATM_NPM_REGISTRY=https://...      use a registry mirror (e.g. https://registry.npmmirror.com)
#   ATM_NPM_PREFIX=$HOME/.npm-global  user-level prefix, used when the global one is not writable
#   ATM_FORCE=1                       reinstall even when that version is already current
#
# POSIX sh only, and stdin is never read: the file is piped from curl.
set -eu

PACKAGE="${ATM_NPM_PACKAGE:-agent-task-manager-core}"
VERSION="${ATM_VERSION:-}"
REGISTRY="${ATM_NPM_REGISTRY:-}"
PREFIX_OVERRIDE="${ATM_NPM_PREFIX:-}"
FORCE="${ATM_FORCE:-}"
MIN_NODE=18

say() { printf '%s\n' "$*"; }
fail() { printf '%s\n' "[atm] $*" >&2; exit 1; }

command -v node >/dev/null 2>&1 || fail "Node.js >= ${MIN_NODE} is required.
  Install it from https://nodejs.org/ (macOS: brew install node; Debian/Ubuntu: apt install nodejs npm)
  then rerun this installer."
command -v npm >/dev/null 2>&1 || fail "npm is required — it ships with Node.js.
  Install Node.js >= ${MIN_NODE} (https://nodejs.org/) and rerun this installer."

node_major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
[ "${node_major}" -ge "${MIN_NODE}" ] 2>/dev/null \
    || fail "Node.js >= ${MIN_NODE} is required (current: $(node -v 2>/dev/null || echo unknown)). Upgrade Node.js and rerun."

# 已是最新版本时直接结束（幂等；固定版本 / 本地 tgz / ATM_FORCE 不走此分支）
current="$(atm version 2>/dev/null || true)"
if [ -z "${FORCE}" ] && [ -n "${current}" ]; then
    latest=""
    if [ -n "${VERSION}" ]; then
        latest="${VERSION}"
    else
        latest="$(npm view "${PACKAGE}" version 2>/dev/null || true)"
    fi
    if [ -n "${latest}" ] && [ "${latest}" = "${current}" ]; then
        say "atm ${current} is already installed and up to date."
        say "Use ATM_FORCE=1 to reinstall, or ATM_VERSION=<version> to install another version."
        exit 0
    fi
fi

# 目标规格：本地路径 / 作用域包 / 已带版本时原样使用，否则拼上 ATM_VERSION
case "${PACKAGE}" in
    *@*|*/*) spec="${PACKAGE}" ;;
    *)
        if [ -n "${VERSION}" ]; then spec="${PACKAGE}@${VERSION}"; else spec="${PACKAGE}"; fi
        ;;
esac

install_global() {
    if [ -n "${REGISTRY}" ]; then
        npm install -g --registry "${REGISTRY}" "$@"
    else
        npm install -g "$@"
    fi
}

say "Installing ${spec} …"
bin_dir=""
if ! install_global "${spec}"; then
    fallback_prefix="${PREFIX_OVERRIDE:-${HOME}/.npm-global}"
    say ""
    say "Global install failed (usually a permissions issue on the npm prefix)."
    say "Retrying with a user-level prefix: ${fallback_prefix}"
    mkdir -p "${fallback_prefix}"
    install_global --prefix "${fallback_prefix}" "${spec}" || fail "npm install failed.
  Check your network or registry, or install manually with a prefix you own:
    npm install -g --prefix \"\$HOME/.npm-global\" \"${spec}\""
    bin_dir="${fallback_prefix}/bin"
fi

if [ -z "${bin_dir}" ]; then
    npm_prefix="$(npm config get prefix 2>/dev/null || true)"
    if [ -n "${npm_prefix}" ]; then bin_dir="${npm_prefix}/bin"; fi
fi
[ -n "${bin_dir}" ] || bin_dir="/usr/local/bin"

atm_bin=""
if [ -x "${bin_dir}/atm" ]; then
    atm_bin="${bin_dir}/atm"
else
    atm_bin="$(command -v atm 2>/dev/null || true)"
fi
[ -n "${atm_bin}" ] || fail "Installed, but the 'atm' command is not on PATH.
  Add this line to your shell profile (~/.profile, ~/.zshrc or ~/.bashrc) and open a new terminal:
    export PATH=\"${bin_dir}:\$PATH\"
  If ${bin_dir}/atm still does not exist, the installed package does not ship the atm binary — check the npm output above."

installed="$("${atm_bin}" version 2>/dev/null || true)"
say "atm ${installed:-?} installed: ${atm_bin}"

case ":${PATH}:" in
    *:"${bin_dir}":*) ;;
    *)
        say ""
        say "Note: ${bin_dir} is not on your PATH yet. Add this to your shell profile:"
        say "  export PATH=\"${bin_dir}:\$PATH\""
        ;;
esac

say ""
say "Next:"
say "  atm                  # start the core and open the welcome page"
say "  atm service auto     # optional: start automatically at login (undo: atm service remove auto)"
say "  atm mcp              # stdio MCP endpoint for Claude Code / Codex / Cursor"
say ""
say "Upgrade any time by rerunning this installer."
say "Uninstall: npm uninstall -g agent-task-manager-core (your data in ~/atm_data is kept)."
