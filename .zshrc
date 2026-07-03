# Enable Powerlevel10k instant prompt. Keep this near the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Safe base PATH first
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git fzf)
source "$ZSH/oh-my-zsh.sh"

# Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Solana
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# VS Code CLI
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_DEFAULT_COMMAND='fd --type f --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden'

# Aliases
alias nv="nvim"
alias ala="aerospace list-apps"
alias cr="cargo run"
alias ct="cargo test"
alias c="cargo"
alias s="solana"

# Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# bun completions
[ -s "/Users/akash/.bun/_bun" ] && source "/Users/akash/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
