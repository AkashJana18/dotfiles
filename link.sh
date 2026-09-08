#!/bin/bash
# link.sh — create symlinks for all dotfiles
# Safe to re-run: backs up existing files before overwriting

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info()  { printf "\033[0;34m[info]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[0;32m[ok]\033[0m    %s\n" "$1"; }
warn()  { printf "\033[0;33m[warn]\033[0m  %s\n" "$1"; }

link_file() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"
    ln -s "$src" "$dst"
    ok "relinked $dst -> $src"
  elif [ -e "$dst" ]; then
    local backup="${dst}.backup.$(date +%s)"
    mv "$dst" "$backup"
    ln -s "$src" "$dst"
    warn "backed up existing $dst to $backup"
    ok "linked $dst -> $src"
  else
    ln -s "$src" "$dst"
    ok "linked $dst -> $src"
  fi
}

info "Linking dotfiles from $DOTFILES_DIR ..."

# Root-level dotfiles
link_file "$DOTFILES_DIR/.gitconfig"    "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.zshrc"        "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.p10k.zsh"     "$HOME/.p10k.zsh"

# .config directories — keep ghostty as dir symlink per preference,
# but handle stateful dirs (herdr/opencode) file-by-file to avoid
# polluting the repo with logs/socks/node_modules on sharing
mkdir -p "$HOME/.config"
for dir in "$DOTFILES_DIR"/.config/*/; do
  name=$(basename "$dir")
  case "$name" in
    herdr|opencode) continue ;;
  esac
  link_file "$DOTFILES_DIR/.config/$name" "$HOME/.config/$name"
done

# Stateful dirs — link only shareable config, not runtime state
mkdir -p "$HOME/.config/herdr"
link_file "$DOTFILES_DIR/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"

mkdir -p "$HOME/.config/opencode" "$HOME/.config/opencode/plugin"
link_file "$DOTFILES_DIR/.config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
link_file "$DOTFILES_DIR/.config/opencode/tui.jsonc" "$HOME/.config/opencode/tui.jsonc"
link_file "$DOTFILES_DIR/.config/opencode/package.json" "$HOME/.config/opencode/package.json"
link_file "$DOTFILES_DIR/.config/opencode/package-lock.json" "$HOME/.config/opencode/package-lock.json"
link_file "$DOTFILES_DIR/.config/opencode/herdr-tui-session.js" "$HOME/.config/opencode/herdr-tui-session.js"
# plugin dir is small and shareable — link as dir if not already handled
if [ -d "$DOTFILES_DIR/.config/opencode/plugin" ]; then
  link_file "$DOTFILES_DIR/.config/opencode/plugin" "$HOME/.config/opencode/plugin"
fi

info "Done. Restart your terminal or run: exec zsh"
