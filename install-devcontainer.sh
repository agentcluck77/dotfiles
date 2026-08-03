#!/bin/sh
# Bootstrap the personal terminal environment inside a dev container.
# The devcontainer CLI plugin clones this repository before invoking the script.
set -eu

DOTFILES_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

step() {
    printf '\n==> %s\n' "$*"
}

as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        printf 'error: root or sudo is required to install container prerequisites\n' >&2
        exit 1
    fi
}

install_prerequisites() {
    step "Container prerequisites"

    if command -v apt-get >/dev/null 2>&1; then
        as_root apt-get update
        as_root apt-get install -y build-essential ca-certificates curl file git procps
    elif command -v dnf >/dev/null 2>&1; then
        as_root dnf install -y ca-certificates curl file gcc gcc-c++ git make procps-ng
    elif command -v apk >/dev/null 2>&1; then
        as_root apk add bash build-base ca-certificates curl file git procps
    else
        printf 'error: unsupported container package manager\n' >&2
        exit 1
    fi
}

ensure_homebrew() {
    step "Homebrew"

    if ! command -v brew >/dev/null 2>&1; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
        eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
    fi

    command -v brew >/dev/null 2>&1 || {
        printf 'error: Homebrew was installed but is not available on PATH\n' >&2
        exit 1
    }
}

install_tools() {
    step "Terminal development tools"
    brew install bash-completion chezmoi fd fzf git-delta lazygit neovim ripgrep starship tmux zoxide
}

apply_dotfiles() {
    step "Apply dotfiles"
    chezmoi init --source "$DOTFILES_DIR"
    chezmoi apply
}

install_prerequisites
ensure_homebrew
install_tools
apply_dotfiles

printf '\nDev container environment is ready.\n'
