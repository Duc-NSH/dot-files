# =============================================================================
# CUSTOM ZSH CONFIGURATION
# =============================================================================
# This file contains custom zsh configurations that will be appended to .zshrc
# Edit this file to customize your zsh environment
# =============================================================================

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

# Set default editor
export EDITOR='vim'
export VISUAL='vim'

# Increase history size
HISTSIZE=999
SAVEHIST=1000

# History settings
HISTFILE=$HOME/.zhistory
setopt share_history 
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# =============================================================================
# ALIASES
# =============================================================================

# ---- Eza (better ls) -----
if command -v eza &> /dev/null; then
    alias ls='eza --icons=always --color=auto --group-directories-first'
    alias ll='eza --icons=always -la --color=auto --group-directories-first'
    alias la='eza --icons=always -a --color=auto --group-directories-first'
    alias lt='eza --icons=always -T --color=auto --group-directories-first'
    alias l='eza --icons=always -l -F --color=auto --group-directories-first'
else
    alias ll='ls -la'
    alias la='ls -A'
    alias l='ls -CF'
fi

# ---- Zoxide (better cd) ----
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

#NOTE: Uncomment the following lines if you want to use more aliases

# # Git aliases
# alias gs='git status'
# alias ga='git add'
# alias gc='git commit'
# alias gp='git push'
# alias gl='git pull'
# alias gd='git diff'
# alias gb='git branch'
# alias gco='git checkout'
#
# # Docker aliases (if docker is available)
# if command -v docker &> /dev/null; then
#     alias dps='docker ps'
#     alias dpa='docker ps -a'
#     alias di='docker images'
#     alias drm='docker rm'
#     alias drmi='docker rmi'
#     alias dstop='docker stop $(docker ps -q)'
#     alias dclean='docker system prune -af'
# fi
#
# # Tmux aliases
# alias tm='tmux'
# alias tma='tmux attach -t'
# alias tml='tmux list-sessions'
# alias tmn='tmux new -s'

# NOTE: Uncomment the following lines if you want to use advanced functions

# # =============================================================================
# # FUNCTIONS
# # =============================================================================
#
# # Create directory and cd into it
# mkcd() {
#     mkdir -p "$1" && cd "$1"
# }
#
# # Extract various archive types
# extract() {
#     if [ -f $1 ] ; then
#         case $1 in
#             *.tar.bz2)   tar xjf $1     ;;
#             *.tar.gz)    tar xzf $1     ;;
#             *.bz2)       bunzip2 $1     ;;
#             *.rar)       unrar e $1     ;;
#             *.gz)        gunzip $1      ;;
#             *.tar)       tar xf $1      ;;
#             *.tbz2)      tar xjf $1     ;;
#             *.tgz)       tar xzf $1     ;;
#             *.zip)       unzip $1       ;;
#             *.Z)         uncompress $1  ;;
#             *.7z)        7z x $1        ;;
#             *)     echo "'$1' cannot be extracted via extract()" ;;
#         esac
#     else
#         echo "'$1' is not a valid file"
#     fi
# }
#
# # Find and kill process by name
# killp() {
#     ps aux | grep -v grep | grep "$1" | awk '{print $2}' | xargs kill -9
# }
#
# # =============================================================================
# # PATH ADDITIONS
# # =============================================================================
#
# # Add local bin to PATH if it exists
# if [ -d "$HOME/.local/bin" ]; then
#     export PATH="$HOME/.local/bin:$PATH"
# fi
#
# # Add cargo bin to PATH if it exists
# if [ -d "$HOME/.cargo/bin" ]; then
#     export PATH="$HOME/.cargo/bin:$PATH"
# fi
#
