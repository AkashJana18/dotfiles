# Dotfiles

My personal development environment and terminal configuration for macOS.

<p align="center">
  <img width="700" height="455" alt="wallpaper-neovim-akabone" src="https://github.com/user-attachments/assets/95b0e84b-6a8c-49c9-a95c-ee400fdde937" />
</p>

## What's included

| Tool | Theme / Config | Purpose |
| ------ | ---------------- | --------- |
| **Neovim** | LazyVim + Zenwritten (stark, transparent) | Terminal editor |
| **Ghostty** | Zenwritten Dark | GPU-accelerated terminal emulator |
| **Herdr** | Akabones (zenbones plugin) | Terminal multiplexer for AI agents |
| **SketchyBar** | Custom (Transparent) | Customizable macOS status bar |
| **AeroSpace** | Tiling window manager | Keyboard-driven window management |
| **Zsh** | Oh My Zsh + Powerlevel10k (akabones) | Interactive shell with plugins |
| **eza** | Lean · icons (akabones) | Modern `ls` replacement |
| **fd** | Default | Modern `find` replacement |
| **bat** | Default | Modern `cat` replacement |
| **fzf** | Default | Fuzzy finder |
| **yazi** | Akabones Dark / Light (WIP) | Terminal file manager |
| **btop** | Default | System resource monitor |
| **Fastfetch** | Akabones | System info display with custom avatar |

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
│   ├── eza/            # ls replacement (lean, akabones)
│   ├── fastfetch/      # System info display (akabones)
│   ├── fd/             # find replacement config
│   ├── ghostty/        # Terminal emulator (Zenwritten Dark)
│   ├── herdr/          # AI terminal multiplexer (Catppuccin / Akabones)
│   ├── nvim/           # Neovim (LazyVim + Zenwritten stark)
│   ├── opencode/       # AI coding assistant
│   ├── sketchybar/     # macOS status bar
│   └── yazi/           # File manager (Akabones)
├── Brewfile            # Homebrew packages
├── setup.sh            # One-command install
├── link.sh             # Symlink creator
├── .gitconfig
├── .p10k.zsh
└── .zshrc
```

## Notes

- All themes are **Akabones / Zenwritten** (nvim + ghostty: Zenwritten stark; yazi/p10k/herdr: Akabones).
- Machine-specific files (apps, keys, local paths) are not tracked.
- Secrets, SSH keys, API tokens, and history files are **not** tracked.
- The SketchyBar helper binary is not tracked (rebuild via `make` in `.config/sketchybar/helper/`).
