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
# 4. Nerd Fonts fallback (if brew cask didn't link)
# --------------------------------------------------
if ! fc-list 2>/dev/null | grep -qi "FiraCode Nerd Font"; then
  warn "FiraCode Nerd Font may not be installed."
  warn "Run: brew install --cask font-fira-code-nerd-font"
fi

# --------------------------------------------------
# 5. Rust / rust-analyzer (for Neovim rustaceanvim)
# --------------------------------------------------
if command -v rustup &>/dev/null; then
  for tc in $(rustup toolchain list 2>/dev/null | cut -d' ' -f1); do
    if ! rustup component list --toolchain "$tc" --installed 2>/dev/null | grep -q "rust-analyzer"; then
      info "Installing rust-analyzer for $tc..."
      rustup component add rust-analyzer --toolchain "$tc" && ok "rust-analyzer for $tc installed." || warn "Failed for $tc. Run: rustup component add rust-analyzer --toolchain $tc"
    fi
  done
  # also ensure default toolchain has it (no-op if already installed above)
  if ! rustup component list --installed 2>/dev/null | grep -q "rust-analyzer"; then
    info "Installing rust-analyzer via rustup..."
    rustup component add rust-analyzer && ok "rust-analyzer installed." || warn "Failed to install rust-analyzer. Run: rustup component add rust-analyzer"
  else
    ok "rust-analyzer already installed, skipping."
  fi
else
  warn "rustup not found — skipping rust-analyzer. Install rustup: https://rustup.rs"
fi

# --------------------------------------------------
# 6. opencode plugin dependencies
# --------------------------------------------------
OPENCODE_DIR="$DOTFILES_DIR/.config/opencode"
if [ -f "$OPENCODE_DIR/package.json" ]; then
  if command -v npm &>/dev/null; then
    info "Installing opencode plugin dependencies..."
    if (cd "$OPENCODE_DIR" && npm install --silent); then
      ok "opencode dependencies installed."
    else
      warn "npm install failed — opencode plugins may not load."
    fi
  else
    warn "npm not found — skipping opencode plugin dependencies."
  fi
else
  ok "No opencode package.json, skipping."
fi

# --------------------------------------------------
# 7. Link dotfiles
# --------------------------------------------------
info "Linking dotfiles..."
bash "$DOTFILES_DIR/link.sh"

# --------------------------------------------------
# 8. Build sketchybar helper (if source exists, binary is gitignored)
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
# 9. macOS bars & window manager services
# --------------------------------------------------
if command -v sketchybar &>/dev/null; then
  if brew services list 2>/dev/null | grep -q '^sketchybar *started'; then
    ok "SketchyBar service already running, skipping."
  else
    info "Starting SketchyBar service..."
    brew services start sketchybar && ok "SketchyBar started." \
      || warn "Could not start SketchyBar — run: brew services start sketchybar"
  fi
fi

if [ -d "/Applications/aerospace.app" ]; then
  if pgrep -q -x aerospace 2>/dev/null; then
    ok "AeroSpace already running, skipping."
  else
    info "Launching AeroSpace..."
    open -a aerospace 2>/dev/null && ok "AeroSpace launched." \
      || warn "Could not launch AeroSpace — open it from Applications."
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
echo "  Not covered by this script:"
echo "    - Ghostty: install manually (not a Homebrew cask)"
echo "    - SketchyBar icons: see .config/sketchybar/readme.md"
echo "    - Update nvim plugins:  :Lazy update (inside nvim)"
echo ""
