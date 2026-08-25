# Enable Powerlevel10k instant prompt. Keep this near the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Safe base PATH first
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="Powerlevel10k/Powerlevel10k"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Solana
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# NVM (lazy-loaded for faster startup)
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  _load_nvm() {
    unset -f nvm node npm npx corepack
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  }
  nvm()  { _load_nvm; nvm "$@"; }
  node() { _load_nvm; node "$@"; }
  npm()  { _load_nvm; npm "$@"; }
  npx()  { _load_nvm; npx "$@"; }
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# VS Code CLI
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# fzf
eval "$(fzf --zsh)"

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza --tree --level=3 --color=always {} | head -100; else bat --color=always --style=numbers --line-range=:500 {}; fi'"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=3 --color=always {} | head -100'"

# Use fd for fzf tab completion (**<TAB>) instead of find
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# Aliases
alias nv="nvim"
alias ala="aerospace list-apps"
alias cr="cargo run"
alias ct="cargo test"
alias c="cargo"
alias s="solana"
# eza as ls (icons + readability)
alias ls="eza --group-directories-first --icons=auto --hyperlink"
alias ll="eza -la --header --git --group-directories-first --icons=auto --time-style=relative --hyperlink"
alias la="eza -a --group-directories-first --icons=auto --hyperlink"
alias lt="eza -a --tree --level=3 --icons=auto --git-ignore --hyperlink"

# Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# eza 
export EZA_CONFIG_DIR="$HOME/dotfiles/eza"

# zsh-autosuggestions
[[ -r "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Yazi set up
export EDITOR="nvim"

function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}


# zoxide setup
eval "$(zoxide init zsh --cmd cd)"
