export FF_LOGO="$(printf "%s\n" ~/.config/fastfetch/logos/* | shuf -n 1)"

# --- Options ---
setopt no_beep
setopt autocd
setopt correct
setopt share_history
setopt hist_ignore_all_dups
setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

# --- History file ---
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE="${HISTSIZE:-50000}"
SAVEHIST="${SAVEHIST:-10000}"

# --- Plugins (lightweight) ---
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# --- Starship prompt ---
eval "$(starship init zsh)"

# --- Completion setup ---
zmodload -i zsh/complist
WORDCHARS=''
unsetopt menu_complete flowcontrol
setopt auto_menu complete_in_word always_to_end
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR:-$HOME/.zsh_cache}"
zstyle ':completion:*' list-colors ''

# Case-insensitive completion (adjust toggle via env vars)
if [[ "$CASE_SENSITIVE" = true ]]; then
    zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
else
    if [[ "$HYPHEN_INSENSITIVE" = true ]]; then
        zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'
    else
        zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
    fi
fi
unset CASE_SENSITIVE HYPHEN_INSENSITIVE

# Completion menu selection
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# Fuzzy history search
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -M emacs "^[[A" up-line-or-beginning-search
bindkey -M emacs "^[[B" down-line-or-beginning-search
bindkey -M viins "^[[A" up-line-or-beginning-search
bindkey -M viins "^[[B" down-line-or-beginning-search
bindkey -M vicmd "^[[A" up-line-or-beginning-search
bindkey -M vicmd "^[[B" down-line-or-beginning-search

# Terminal keybindings
bindkey -e  # emacs keybindings
bindkey -M emacs '^?' backward-delete-char
bindkey -M viins '^?' backward-delete-char
bindkey -M vicmd '^?' backward-delete-char

bindkey '^r' history-incremental-search-backward
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Ctrl/Alt movement
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M emacs '^[[1;5D' backward-word
bindkey -M viins '^[[1;5C' forward-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M vicmd '^[[1;5C' forward-word
bindkey -M vicmd '^[[1;5D' backward-word

# Special key combos
bindkey '\ew' kill-region
bindkey -s '\el' '^q ls\n'
bindkey "^[m" copy-prev-shell-word
bindkey ' ' magic-space

# Auto-load bash completion functions
autoload -U +X bashcompinit && bashcompinit

# History wrapper (omz_history)
omz_history() {
    local clear list stamp REPLY
    zparseopts -E -D c=clear l=list f=stamp E=stamp i=stamp t:=stamp
    if [[ -n "$clear" ]]; then
        print -nu2 "Delete history? [y/N] "
        builtin read -E
        [[ "$REPLY" = [yY] ]] || return 0
        print -nu2 >| "$HISTFILE"
        fc -p "$HISTFILE"
        print -u2 History file deleted.
    elif [[ $# -eq 0 ]]; then
        builtin fc "${stamp[@]}" -l 1
    else
        builtin fc "${stamp[@]}" -l "$@"
    fi
}
alias history='omz_history'

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

fastfetch
