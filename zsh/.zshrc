#
# Executes commands at the start of an interactive session.
#

__fsel() {
  # set -o nonomatch
  # command git rev-parse --show-cdup > /dev/null || exit
  command rg --hidden --files $(git rev-parse --show-cdup) | fzf
}

__gdsel() {
  set -e
  set -o nonomatch
  command git rev-parse --show-cdup > /dev/null || exit
  command git diff --name-only | fzf
}

__cur_dir_sel() {
  command rg --hidden --files | fzf
}

__git_branch_sel() {
  command git branch --format='%(refname:short)' -a | sed 's/^origin\///g' | sort | uniq | fzf
}

file-widget() {
  if [[ "$LBUFFER" != "" ]]; then
      LBUFFER="$LBUFFER$(__fsel)"
  else
      LBUFFER="vim $(__fsel)"
  fi

  zle redisplay
}

git-branch-widget() {
  LBUFFER="$LBUFFER$(__git_branch_sel)"
  zle redisplay
}

changed-file-widget() {
  LBUFFER="${LBUFFER}$(__gdsel)"
  zle redisplay
}

current-dir-widget() {
  if [[ "$LBUFFER" != "" ]]; then
      LBUFFER="$LBUFFER$(__cur_dir_sel)"
  else
      LBUFFER="vim $(__cur_dir_sel)"
  fi
  zle redisplay
}

zle -N file-widget
zle -N changed-file-widget
zle -N current-dir-widget
zle -N git-branch-widget
bindkey '^P' file-widget
# bindkey '^O' changed-file-widget
bindkey '^O' current-dir-widget
bindkey '^G' git-branch-widget

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  LBUFFER="$LBUFFER${$(command fd -t d | sed 's/^/.\//' | sed 's/$/\//' | fzf +m):-.}"
  zle redisplay
}
zle     -N    fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected
  if selected=$(fc -l 1 | fzf +s --tac +m -n2..,.. --toggle-sort=ctrl-r -q "$LBUFFER"); then
    num=$(echo "$selected" | head -1 | awk '{print $1}' | sed 's/[^0-9]//g')
    LBUFFER=!$num
    zle expand-history
  fi
  zle redisplay
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

unsetopt cdablevars

setopt alwaystoend
setopt autocd
setopt autopushd
setopt autoresume
setopt nobgnice
setopt nocaseglob
setopt nocheckjobs
setopt noclobber
setopt combiningchars
setopt completeinword
setopt extendedglob
setopt extendedhistory
setopt noflowcontrol
setopt histexpiredupsfirst
setopt histfindnodups
setopt histignorealldups
setopt histignoredups
setopt histignorespace
setopt histsavenodups
setopt histverify
setopt nohup
setopt interactive
setopt interactivecomments
setopt longlistjobs
setopt monitor
setopt pathdirs
setopt promptsubst
setopt pushdignoredups
setopt pushdsilent
setopt pushdtohome
setopt rcquotes
setopt sharehistory
# setopt shinstdin
setopt zle

alias ssh="TERM=xterm ssh"
# alias tig="tig --all"
alias gst="git status"
alias ga="git add"
alias gd="git diff"
alias gcmsg="git commit -m"
alias gc!="git commit --amend"
alias gc@="gc! --no-edit"
alias tmux-id="tmux display-message -p '#S:#I'"

alias gcmsg='git commit -m'
alias gco='git checkout'
alias gpc='git push --set-upstream origin "$(git symbolic-ref HEAD 2>/dev/null)"'
alias ls='ls --group-directories-first --color=auto'

#
# PROMPT
# 
autoload -U colors && colors

local ret_status="%(?:%{$fg_bold[green]%}$:%{$fg_bold[green]%}$)"
PROMPT='
$fg[yellow]%n@%m:$fg[green]%~%f%{$reset_color%} $(git_prompt_info)$fg[yellow]
$ %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%} ●"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Outputs current branch info in prompt format
function git_prompt_info() {
  local ref
  if [[ "$(command git config --get customzsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

# Checks if working tree is dirty
function parse_git_dirty() {
  local STATUS=''
  local FLAGS
  FLAGS=('--porcelain')

  if [[ "$(command git config --get customzsh.hide-dirty)" != "1" ]]; then
    FLAGS+='--ignore-submodules=dirty'
    STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  fi

  if [[ -n $STATUS ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

# Done

alias c='jump'

if [[ "$OSTYPE" == linux* ]]; then
  # dir colors
  eval $(dircolors ~/.dircolors)
fi
alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'
alias cal='gcal --starting-day=1'
alias rg='rg --smart-case'
alias npx='npx --no-install'
alias tmux='tmux -2'

if [[ -n $VIRTUAL_ENV ]]; then
  source "$VIRTUAL_ENV/bin/activate"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use  # This loads nvm

# load direnv
if which direnv >/dev/null 2>/dev/null; then
  eval "$(direnv hook zsh)"
fi

if [[ -s "${ZDOTDIR:-$HOME}/.zlocal.zsh" ]]; then
  source ~/.zlocal.zsh
fi

syntax_highlighting_file="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [[ -f "$syntax_highlighting_file" ]]; then
  source "$syntax_highlighting_file"
fi

source "$ZSH_DOTFILES_DIR/zshmarks.plugin.zsh"

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu yes select
