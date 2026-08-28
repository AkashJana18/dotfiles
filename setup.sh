#!/bin/bash
# setup.sh — one-command install for dotfiles
# Usage: git clone https://github.com/AkashJana18/dotfiles.git ~/dotfiles && ~/dotfiles/setup.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info()  { printf "\033[0;34m[setup]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[0;32m[done]\033[0m   %s\n" "$1"; }
warn()  { printf "\033[0;33m[warn]\033[0m  %s\n" "$1"; }
fail()  { printf "\033[0;31m[error]\033[0m %s\n" "$1"; exit 1; }

# --------------------------------------------------
# 0. Preflight
# --------------------------------------------------
if [[ "$(uname)" != "Darwin" ]]; then
  fail "This setup is for macOS only."
fi

if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --------------------------------------------------
# 1. Install from Brewfile
# --------------------------------------------------
info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock

# --------------------------------------------------
# 2. Oh My Zsh (if not installed)
# --------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  ok "Oh My Zsh already installed, skipping."
fi

# --------------------------------------------------
# 3. Powerlevel10k (if not installed)
# --------------------------------------------------
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  ok "Powerlevel10k already installed, skipping."
fi

# --------------------------------------------------
# 4. TPM (Tmux Plugin Manager) — install if tmux is used
# --------------------------------------------------
if command -v tmux &>/dev/null && [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  info "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# --------------------------------------------------
# 5. Nerd Fonts fallback (if brew cask didn't link)
# --------------------------------------------------
if ! fc-list 2>/dev/null | grep -qi "FiraCode Nerd Font"; then
  warn "FiraCode Nerd Font may not be installed."
  warn "Run: brew install --cask font-fira-code-nerd-font"
fi

# --------------------------------------------------
# 6. Link dotfiles
# --------------------------------------------------
info "Linking dotfiles..."
bash "$DOTFILES_DIR/link.sh"

# --------------------------------------------------
# 7. Build sketchybar helper (if source exists, binary is gitignored)
# --------------------------------------------------
HELPER_DIR="$DOTFILES_DIR/.config/sketchybar/helper"
if [ -f "$HELPER_DIR/makefile" ] && [ -f "$HELPER_DIR/helper.c" ]; then
  if ! [ -f "$HELPER_DIR/helper" ]; then
    info "Building sketchybar helper..."
    (cd "$HELPER_DIR" && make 2>/dev/null && ok "sketchybar helper built.")
  else
    ok "sketchybar helper already built, skipping."
  fi
fi

# --------------------------------------------------
# Done
# --------------------------------------------------
echo ""
ok "Setup complete!"
echo ""
echo "  1. Restart your terminal: exec zsh"
echo "  2. Or open a new terminal window"
echo ""
echo "  Optional:"
echo "    - Open Ghostty to see the Gruvbox theme"
echo "    - Open SketchyBar:  sketchybar --start-service"
echo "    - Open AeroSpace:   sudo launchctl bootstrap system/..."
echo "    - Update nvim plugins:  :Lazy update (inside nvim)"
echo ""
