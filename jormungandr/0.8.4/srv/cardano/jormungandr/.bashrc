# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

PS1="$(tput bold)(${SERVICE_NAME})$(tput sgr0)[$(id -un)@$(hostname -s) \$(pwd)]$ "
