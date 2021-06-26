#
# Executes commands at login pre-zshrc.
#

autoload -Uz compinit && compinit

export ZSH_DOTFILES_DIR="${ZDOTDIR:-$HOME}/.zprofile"

while readlink -sq "$ZSH_DOTFILES_DIR" > /dev/null; do
  ZSH_DOTFILES_DIR="$(readlink -sq "$ZSH_DOTFILES_DIR")"
done

export ZSH_DOTFILES_DIR="$(dirname $ZSH_DOTFILES_DIR)"

export HISTSIZE=10000
export SAVEHIST=$HISTSIZE
export HISTFILE=$HOME/.zhistory

# To be used in combination with systemd user ssh-agent.service
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  ${HOME}/bin
  ${HOME}/opt/node_modules/.bin
  ${HOME}/src/go/bin
  ${HOME}/.cargo/bin
  ${HOME}/.nimble/bin
  /usr/local/{bin,sbin}
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# source .zlocal file if available. this is local configuration that is not to
# be committed to the repository.
if [[ -s "${ZDOTDIR:-$HOME}/.zlocal" ]]; then
  source "${ZDOTDIR:-$HOME}/.zlocal"
fi

export GOPATH="$HOME/src/go"
if command -v rustc >/dev/null; then
  export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/library"
fi
