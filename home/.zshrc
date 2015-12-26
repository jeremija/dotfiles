UNAME=$(uname -s)
IS_MAC=""
IS_LINUX=""
if [[ "$UNAME" == 'Linux' ]]; then
  IS_LINUX=1
elif [[ "$UNAME" == 'Darwin' ]]; then
  IS_MAC=1
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="gentoo"
ZSH_THEME="amuse-jerko"

# Uncomment the following line to use case-sensitive completion.
 CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# User configuration

if [[ -n $IS_LINUX ]]; then
  export PATH="$HOME/bin:$HOME/opt/jdk1.8.0_05/bin:$HOME/opt/node_modules/.bin:$HOME/opt/android-sdk-linux/platform-tools:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$HOME/android-sdk-linux/tools:$HOME/opt/groovy-2.3.0/bin:$HOME/opt/grails-2.4.0/bin:$HOME/src/linux/fzf/bin"
elif [[ -n $IS_MAC ]]; then
  export PATH="$HOME/bin:$HOME/opt/node_modules/.bin:$PATH"
fi
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


__fsel() {
  # set -o nonomatch
  # command git rev-parse --show-cdup > /dev/null || exit
  command ag '^' -l $(git rev-parse --show-cdup) | fzf
}

__gdsel() {
  set -e
  set -o nonomatch
  command git rev-parse --show-cdup > /dev/null || exit
  command git diff --name-only | fzf
}

file-widget() {
  if [[ "$LBUFFER" != "" ]]; then
      LBUFFER="$LBUFFER $(__fsel)"
  else
      LBUFFER="vim $(__fsel)"
  fi

  zle redisplay
}

changed-file-widget() {
  LBUFFER="${LBUFFER}$(__gdsel)"
  zle redisplay
}

zle -N file-widget
zle -N changed-file-widget
bindkey '^P' file-widget
bindkey '^O' changed-file-widget

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  cd "${$(command find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
    -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf +m):-.}"
  zle reset-prompt
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

source $HOME/.local/bin/bashmarks.sh
unsetopt cdablevars
setopt HIST_IGNORE_DUPS

alias ssh="TERM=xterm ssh"
alias tig="tig --all"

source $HOME/.profile
source ~/.local/bin/bashmarks.sh

if [[ -n $IS_LINUX ]]; then
  # dir colors
  eval `dircolors ~/.dircolors`

  export LANG="en_US.UTF-8"
  export LC_CTYPE="en_US.UTF-8"
  export LC_NUMERIC="en_US.UTF-8"
  export LC_COLLATE="en_US.UTF-8"
  export LC_MONETARY="en_US.UTF-8"
  export LC_MESSAGES="en_US.UTF-8"
  export LC_PAPER="en_US.UTF-8"
  export LC_NAME="en_US.UTF-8"
  export LC_ADDRESS="en_US.UTF-8"
  export LC_TELEPHONE="en_US.UTF-8"
  export LC_MEASUREMENT="en_US.UTF-8"
  export LC_IDENTIFICATION="en_US.UTF-8"
  # make monday first day of the week
  export LC_TIME="en_GB.UTF-8"
fi

if [[ -n $IS_MAC ]]; then

  ### fix autocomplete for ssh
  autoload bashcompinit
  bashcompinit

  _complete_ssh_hosts() {
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    comp_ssh_hosts=$(cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | \
      grep -v ^# | sed -e 's/,.*//g' | sed -e 's/^\[//g' | \
      sed -e 's/\].*//g' | \
      cat ~/.ssh/config | grep "^Host " | \
      sed -e 's/^Host //g ' | grep -v '\*' | uniq)

    COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
    return 0
  }
  complete -F _complete_ssh_hosts ssh
fi
