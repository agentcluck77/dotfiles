# dotfiles

Personal config for shell, tmux, Neovim, Git, and AI tools — managed with [chezmoi](https://www.chezmoi.io/).

**Shell convention:** zsh on macOS, bash on Linux.

## Contents

| Path | Tool |
|---|---|
| `dot_zshrc` | Zsh (macOS) — fzf, autosuggestions, syntax highlighting, zoxide, starship |
| `dot_bashrc` | Bash (Linux) — fzf, bash-completion, zoxide, starship |
| `dot_tmux.conf` | tmux — vi keys, mouse, clipboard auto-detect, resurrect/continuum |
| `dot_config/nvim/` | Neovim (LazyVim) |
| `install-devcontainer.sh` | Minimal dotfiles and CLI-tool bootstrap for dev containers |
| `dot_gitconfig` | Git — delta diffs, `git lg` / `git undo` aliases, gh credential helper, LFS |
| `dot_ssh/private_config` | SSH config — Tailscale host aliases for all homelab devices |
| `dot_config/copyq/` | CopyQ clipboard manager settings and commands (Linux only) |
| `setup.sh` | Platform-aware setup — full desktop or minimal iSH/Alpine |
| `CHANGELOG.md` | Planned additions |

## Setup on a new machine

### macOS, desktop Linux, and iSH/Alpine

```bash
curl -fsSL https://raw.githubusercontent.com/agentcluck77/dotfiles/main/setup.sh | sh
```

On macOS and desktop Linux, this handles Homebrew, packages, fonts, chezmoi
initialisation, and `chezmoi apply`.

On iSH/Alpine, the same script detects `/etc/alpine-release`, installs only
`git`, `curl`, `openssh-client`, and `chezmoi`, then applies all managed
dotfiles. Desktop packages, fonts, clipboard tools, Neovim, Homebrew, and npm
are skipped.

**Manual steps after desktop setup:**
1. Set terminal font to **JetBrainsMono Nerd Font Mono**
2. Open tmux → `prefix + I` to install plugins
3. Run `nvim` — LazyVim bootstraps automatically
4. On macOS, open Maccy and allow it in **System Settings → Privacy & Security → Accessibility**

If you already have the repo cloned, you can also run `sh ~/dotfiles/setup.sh` directly.

## LazyVim in dev containers

The Neovim configuration uses `devcontainer-cli.nvim` to open the current
project's existing dev container with the same terminal and LazyVim setup. The
dotfiles bootstrap is applied automatically and does not require changes to the
project's `devcontainer.json`.

- `<leader>Ds` builds or starts the container.
- `<leader>Da` connects to it.

The host needs the `devcontainer` CLI and a Docker-compatible runtime. The
desktop setup installs the CLI through Homebrew.

## SSH

All homelab devices are defined by short alias in `~/.ssh/config` — no IPs or usernames needed.


Connection multiplexing (`ControlMaster`) is enabled globally — a second `ssh` to the same host reuses the existing connection instantly.

## Git aliases

| Alias | Command |
|---|---|
| `git lg` | Pretty graph log with branches and relative dates |
| `git undo` | Soft-reset last commit (keeps changes staged) |

Diffs use [delta](https://github.com/dandavison/delta).

## Starship prompt

Starship uses its defaults. To customise, add `~/.config/starship.toml`

## Clipboard

- **macOS**: Maccy clipboard history (installed as a Homebrew cask) and `pbcopy` for terminal integration
- **Linux Wayland**: `wl-copy` (wl-clipboard via apt)
- **Linux X11**: CopyQ and `xclip`, installed through `apt`

CopyQ settings and commands are managed in `dot_config/copyq/` on Linux and
excluded from macOS by `.chezmoiignore`. On macOS, Maccy requires Accessibility
permission to paste into other apps.

Terminal clipboard integration works in both tmux copy-mode and Neovim (`"+y`).

## Notes

- **tmux clipboard**: auto-detects `pbcopy` → `wl-copy` (Wayland only) → `xclip` (X11 fallback).
- **tmux resurrect**: restores pane layout and contents. Restart processes manually.
- **Adding new configs**: name the file with `dot_` prefix for hidden files, run `chezmoi apply`, commit.
