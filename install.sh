#!/bin/bash
# install.sh — install ansulev-neovim: system tools (Arch) and the ~/.config/nvim link
set -euo pipefail

readonly VERSION="0.1"
SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO
readonly TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
DRY=0
BACKUP=0
YES=()

# command on PATH = package that provides it. Only missing commands are installed, so
# -git / -bin variants you already have are never replaced.
readonly CORE=(
  nvim=neovim git=git rg=ripgrep fd=fd tree-sitter=tree-sitter-cli cc=gcc
)
readonly LSP=(
  pyright-langserver=pyright ruff=ruff bash-language-server=bash-language-server
  shellcheck=shellcheck shfmt=shfmt lua-language-server=lua-language-server taplo=taplo-cli
  tflint=tflint yaml-language-server=yaml-language-server
  vscode-json-language-server=vscode-json-languageserver marksman=marksman
  docker-langserver=dockerfile-language-server
)
readonly AUR_PKGS=(
  terraform-ls=terraform-ls ltex-ls-plus=ltex-ls-plus-bin claude-agent-acp=claude-agent-acp
)

log()  { echo "[$(date '+%H:%M:%S')] $*"; }
err()  { echo "[ERROR] $*" >&2; }
die()  { err "$*"; exit 1; }
run()  { if (( DRY )); then echo "  [dry-run] $*"; else "$@"; fi; }

usage() {
  cat <<EOF
──────────────────────────────────────────────────
  ${SCRIPT}  v${VERSION}  ·  Install ansulev-neovim on Arch Linux
  © ANSULEV Group · Angel Sulev
──────────────────────────────────────────────────

Usage:
  ./${SCRIPT} <deps|link|all> [OPTIONS]

Commands:
  deps   install missing tools: yay/paru (repo + AUR), else pacman (repo only)
  link   point ${TARGET/#$HOME/\~} at this repo
  all    deps, then link

Options:
  --backup       link: move an existing config aside instead of stopping
  -y, --yes      deps: install without asking (--noconfirm)
  -n, --dry-run  print what would run, change nothing
  -h, --help     show this help
  -V, --version  print version and exit

Examples:
  ./${SCRIPT} all --dry-run
  ./${SCRIPT} all --backup
  ./${SCRIPT} link --backup
EOF
}

# Prints the packages from a cmd=pkg list whose command is not on PATH.
missing_pkgs() {
  local pair
  for pair in "$@"; do
    command -v "${pair%%=*}" >/dev/null 2>&1 || echo "${pair#*=}"
  done
}

clipboard_pair() {
  if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then echo "wl-copy=wl-clipboard"; else echo "xclip=xclip"; fi
}

# yay/paru installs repo and AUR packages in one go. Without one, pacman installs the repo
# packages and the AUR extras are listed for you.
install_deps() {
  command -v pacman >/dev/null 2>&1 || { err "pacman not found — install the tools in README.md by hand"; exit 3; }
  local pkgs aur_pkgs helper
  mapfile -t pkgs < <(missing_pkgs "${CORE[@]}" "$(clipboard_pair)" "${LSP[@]}")
  mapfile -t aur_pkgs < <(missing_pkgs "${AUR_PKGS[@]}")
  helper="$(command -v yay || command -v paru || true)"
  if [[ -n "$helper" ]]; then
    pkgs+=("${aur_pkgs[@]}")
    (( ${#pkgs[@]} )) || { log "deps: nothing missing"; return 0; }
    log "$(basename "$helper"): ${pkgs[*]}"
    run "$helper" -S --needed "${YES[@]}" "${pkgs[@]}"
    return 0
  fi
  if (( ${#pkgs[@]} )); then
    log "pacman: ${pkgs[*]}"
    run sudo pacman -S --needed "${YES[@]}" "${pkgs[@]}"
  fi
  (( ${#aur_pkgs[@]} )) && log "AUR, install with your helper: ${aur_pkgs[*]}"
  return 0
}

link_config() {
  if [[ -L "$TARGET" && "$(readlink -f "$TARGET")" == "$REPO" ]]; then
    log "link: ${TARGET} already points here"; return 0
  fi
  if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    (( BACKUP )) || die "${TARGET} exists. Re-run with --backup to move it aside."
    local aside
    aside="${TARGET}.backup-$(date '+%Y%m%d-%H%M%S')"
    log "link: moving ${TARGET} -> ${aside}"
    run mv -- "$TARGET" "$aside"
  fi
  run mkdir -p -- "$(dirname "$TARGET")"
  run ln -s -- "$REPO" "$TARGET"
  log "link: ${TARGET} -> ${REPO}. Start nvim; plugins install on first launch."
}

main() {
  [[ $# -eq 0 ]] && { usage; exit 0; }
  local cmd="" a
  for a in "$@"; do
    case "$a" in
      -h|--help)    usage; exit 0 ;;
      -V|--version) echo "${SCRIPT}  v${VERSION}"; exit 0 ;;
      -n|--dry-run) DRY=1 ;;
      --backup)     BACKUP=1 ;;
      -y|--yes)     YES=(--noconfirm) ;;
      deps|link|all) cmd="$a" ;;
      *)            err "unknown argument: $a"; usage >&2; exit 2 ;;
    esac
  done
  case "$cmd" in
    deps) install_deps ;;
    link) link_config ;;
    all)  install_deps; link_config ;;
    *)    err "no command given"; exit 2 ;;
  esac
}

main "$@"
