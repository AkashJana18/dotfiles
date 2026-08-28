# Dotfiles

My personal development environment and terminal configuration for macOS.

## What's included

| Tool | Theme / Config | Purpose |
|------|----------------|---------|
| **Neovim** | LazyVim + Gruvbox | Terminal editor |
| **Ghostty** | Gruvbox Dark Hard | GPU-accelerated terminal emulator |
| **Herdr** | Gruvbox | Terminal multiplexer for AI agents |
| **SketchyBar** | Custom (Catppuccin) | Customizable macOS status bar |
| **AeroSpace** | Tiling window manager | Keyboard-driven window management |
| **Zsh** | Oh My Zsh + Powerlevel10k | Interactive shell with plugins |
| **eza** | Gruvbox | Modern `ls` replacement |
| **fd** | — | Modern `find` replacement |
| **bat** | — | Modern `cat` replacement |
| **fzf** | — | Fuzzy finder |
| **yazi** | Gruvbox Dark | Terminal file manager |
| **btop** | — | System resource monitor |
| **Fastfetch** | Gruvbox | System info display with custom avatar |

## Requirements

- macOS (Apple Silicon recommended)
- Homebrew (auto-installed by setup.sh if missing)

## Installation

One command:

```bash
git clone https://github.com/AkashJana18/dotfiles.git ~/dotfiles && ~/dotfiles/setup.sh
```

This will:
1. Install Homebrew (if missing)
2. Install all packages from `Brewfile`
3. Install Oh My Zsh + Powerlevel10k
4. Symlink all dotfiles into place
5. Build the SketchyBar helper

Then restart your terminal or run `exec zsh`.

## Manual install (without setup.sh)

```bash
git clone https://github.com/AkashJana18/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle --file=Brewfile --no-lock
bash link.sh
```

## Updating

After making changes:

```bash
cd ~/dotfiles
git add .
git commit -m "Update dotfiles"
git push
```

On another machine:

```bash
cd ~/dotfiles
git pull
bash link.sh
```

## Structure

```text
.
├── .config/
│   ├── aerospace/      # Tiling window manager
│   ├── btop/           # System monitor
│   ├── eza/            # ls replacement theme
│   ├── fastfetch/      # System info display (Gruvbox)
│   ├── fd/             # find replacement config
│   ├── ghostty/        # Terminal emulator (Gruvbox)
│   ├── herdr/          # AI terminal multiplexer
│   ├── nvim/           # Neovim (LazyVim + Gruvbox)
│   ├── opencode/       # AI coding assistant
│   ├── sketchybar/     # macOS status bar
│   └── yazi/           # File manager (Gruvbox)
├── Brewfile            # Homebrew packages
├── setup.sh            # One-command install
├── link.sh             # Symlink creator
├── .gitconfig
├── .p10k.zsh
└── .zshrc
```

## Notes

- All themes are **Gruvbox** (neovim, ghostty, herdr, eza, yazi).
- Machine-specific files (apps, keys, local paths) are not tracked.
- Secrets, SSH keys, API tokens, and history files are **not** tracked.
- The SketchyBar helper binary is not tracked (rebuild via `make` in `.config/sketchybar/helper/`).
