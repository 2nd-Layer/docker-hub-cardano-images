# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

PS1="$(tput bold)(${SERVICE_NAME})$(tput sgr0)[$(id -un)@$(hostname -s) \$(pwd)]$ "
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll="ls -l"

# User specific environment and startup programs
if [ -f /usr/local/lib/jcli-set-env-variables.sh ]; then
    source /usr/local/lib/jcli-set-env-variables.sh
fi

if [ -f $HOME/etc/jcli.bash ]; then
  source $HOME/etc/jcli.bash
fi
