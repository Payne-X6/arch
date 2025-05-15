# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Console name
if [[ -z "${BASHRCSOURCED}" ]]; then
  BASHRCSOURCED="Y"
  # the check is bash's default value
  case ${TERM} in
    Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*)
      PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
      ;;
    screen*)
      PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
      ;;
  esac
fi

# Enable bash completion
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

# Shell prompt setup
##   username          @                hostname          :                cwd               $/#                clear
PS1="\[\e[38;5;160m\]\u\[\e[38;5;166m\]@\[\e[38;5;172m\]\h\[\e[38;5;178m\]:\[\e[38;5;184m\]\w\[\e[38;5;190m\]\\$\[\033[0m\] "

# Aliases
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias sudo='sudo -E'

# Startup
if [[ -n `which neofetch` ]]; then
  neofetch
fi
