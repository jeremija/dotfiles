#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

if [[ "$OSTYPE" == linux* ]]; then
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
