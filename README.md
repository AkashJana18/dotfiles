# Dotfiles

My personal development environment and terminal configuration for macOS.

## What's included

- **Neovim** (LazyVim)
- **Ghostty**
- **tmux**
- **Zsh**
- **Powerlevel10k**
- **Git**
- **AeroSpace**
- **Yazi**
- **Fastfetch**
- **btop**

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


