#!/bin/sh
# Set up dotfiles on a new machine.
# Safe to re-run: existing installs and chezmoi state are reused where possible.
set -eu

DOTFILES_REPO="https://github.com/agentcluck77/dotfiles"
DOTFILES_DIR="$HOME/dotfiles"

step() {
  echo ""
  echo "==> $*"
}

is_alpine() {
  [ -f /etc/alpine-release ]
}

ensure_alpine_packages() {
  step "Alpine essentials"

  apk add git curl openssh-client chezmoi
}

ensure_homebrew() {
  step "Homebrew"

  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # On Linux, brew is not on PATH until shellenv is sourced.
  if [ "$(uname)" != "Darwin" ]; then
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
      eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
    fi
  fi

  echo "  brew $(brew --version | head -1)"
}

sync_dotfiles_repo() {
  step "Dotfiles repo"

  if [ ! -d "$DOTFILES_DIR/.git" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    echo "  Cloned to $DOTFILES_DIR"
  else
    echo "  Reusing existing checkout at $DOTFILES_DIR"
  fi
}

install_packages() {
  step "Packages"

  brew install fzf zsh-autosuggestions zsh-syntax-highlighting zoxide starship chezmoi \
    git-delta lazygit fd neovim node wakeonlan devcontainer

  if command -v npm >/dev/null 2>&1; then
    npm install -g neovim
  fi
}

install_clipboard_tools() {
  step "Clipboard tools"

  if [ "$(uname)" = "Darwin" ]; then
    brew install --cask maccy
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y xclip copyq
  fi
}

install_font() {
  step "Font"

  if [ "$(uname)" = "Darwin" ]; then
    brew install --cask font-jetbrains-mono-nerd-font
  else
    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNF"
    mkdir -p "$FONT_DIR"

    TMPFILE=$(mktemp --suffix=.zip)
    echo "  Downloading JetBrains Mono Nerd Font..."
    curl -fL --progress-bar \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
      -o "$TMPFILE"
    unzip -oq "$TMPFILE" -d "$FONT_DIR"
    rm "$TMPFILE"
    fc-cache -f "$FONT_DIR"
  fi

  echo "  Installed: JetBrainsMono Nerd Font Mono"
}

apply_dotfiles() {
  step "chezmoi"
  chezmoi init --source "$DOTFILES_DIR" 2>/dev/null || true
  echo "  Initialized (source: $DOTFILES_DIR)"

  step "chezmoi apply"
  chezmoi apply
  echo "  Done."
}

print_next_steps() {
  echo ""
  echo "========================================"
  echo "  Setup complete."
  echo "========================================"
  echo ""
  echo "Manual steps remaining:"
  echo "  1. Set terminal font: JetBrainsMono Nerd Font Mono"
  echo "  2. Open tmux, then press prefix + I to install plugins"
  echo "  3. Run nvim - LazyVim will bootstrap plugins automatically"
  if [ "$(uname)" = "Darwin" ]; then
    echo "  4. Open Maccy and grant it access in:"
    echo "     System Settings > Privacy & Security > Accessibility"
  fi
  echo ""
  echo "Font preferences:"
  echo "  macOS Terminal.app  - Preferences > Profiles > Text > Font"
  echo "  iTerm2              - Preferences > Profiles > Text > Font"
  echo "  GNOME Terminal      - Preferences > Profile > Text > Custom font"
  echo "  Konsole             - Settings > Edit Current Profile > Appearance > Font"
  echo ""
}

print_alpine_next_steps() {
  echo ""
  echo "========================================"
  echo "  Minimal iSH/Alpine setup complete."
  echo "========================================"
  echo ""
  echo "Installed: git, curl, openssh-client, chezmoi"
  echo "Applied all dotfiles, including ~/.ssh/config."
  echo ""
}

if is_alpine; then
  ensure_alpine_packages
  sync_dotfiles_repo
  apply_dotfiles
  print_alpine_next_steps
else
  ensure_homebrew
  sync_dotfiles_repo
  install_packages
  install_clipboard_tools
  install_font
  apply_dotfiles
  print_next_steps
fi
