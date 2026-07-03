# Dotfiles

My personal development environment and terminal configuration for macOS.

## What's included

| Tool | Theme / Config | Purpose |
|------|----------------|---------|
| **Neovim** | LazyVim + Catppuccin (Transparent) | Terminal editor. |
| **Ghostty** | Niji + Powerlevel10k | GPU-accelerated terminal emulator. |
| **Herdr** | Catppuccin - Default | Terminal multiplexer for AI agents. |
| **tmux** | Catppuccin | Terminal multiplexer. |
| **Zsh** | Oh My Zsh | Interactive shell with plugins. |
| **Powerlevel10k** | Lean preset | Fast, minimal prompt with Git status and developer context. |
| **Git** | Custom aliases & defaults | Version control and streamlined Git workflow. |
| **AeroSpace** | Tiling window manager | Keyboard-driven window management on macOS. |
| **SketchyBar** | Custom | Customizable macOS status bar. |
| **Yazi** | Catppuccin | Blazing-fast terminal file manager. |
| **Fastfetch** | Minimal | Display system information on terminal startup. |
| **btop** | Catppuccin | Interactive system resource monitor. |

## Requirements

Install the following before using these dotfiles:

- Git
- GNU Stow
- Zsh
- Neovim
- tmux
- Ghostty
- AeroSpace (optional)
- Yazi (optional)
- Fastfetch (optional)
- btop (optional)

## Installation

Clone the repository:

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Symlink everything using GNU Stow:

```bash
stow .
```

Or stow individual packages (recommended if using a package-based layout):

```bash
stow zsh tmux git nvim ghostty
```

## Updating

After making changes to your local configuration:

```bash
git add .
git commit -m "Update dotfiles"
git push
```

On another machine:

```bash
cd ~/dotfiles
git pull
stow .
```

## Structure

```text
.
├── .config/
│   ├── aerospace/
│   ├── btop/
│   ├── fastfetch/
│   ├── ghostty/
│   ├── lazygit/
│   ├── nvim/
│   └── yazi/
├── .gitconfig
├── .p10k.zsh
├── .tmux.conf
└── .zshrc
```

## Notes

- Machine-specific files are intentionally excluded.
- Secrets, SSH keys, API tokens, and history files are **not** tracked.
- The repository is managed with GNU Stow.


