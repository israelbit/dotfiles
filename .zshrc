# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

eval "$(starship init zsh)"



bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/i5r431/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
fastfetch



source /home/i5r431/Code/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_HIGHLIGHT_STYLES[default]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=magenta,under'

alias vi="nvim"
alias vim="nvim"
alias update="doas pacman -Syu" 
alias list="exa -la --icons"
alias tree="exa -Rlah --icons"
