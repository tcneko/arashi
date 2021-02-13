## cd
alias ..="cd .."
alias ...="cd ../.."
alias cdsd='cd /lib/systemd/system'
alias cdmnt='cd /mnt'
alias cdtmp='cd /tmp'
alias cdsh='cd /opt/sh/'
alias cdgit='cd /opt/git'

## sudo
alias apt='sudo apt'
alias systemctl='sudo systemctl'
alias journalctl='sudo journalctl'
alias vim='sudo vim'
alias iptables='sudo iptables'
alias ip6tables='sudo ip6tables'
alias htop='sudo htop'
alias vtysh='sudo vtysh'
alias ps='sudo ps'
alias pstree='sudo pstree'
alias ss='sudo ss'

## default args
alias free='free -h'
alias df='df -h'
alias du='du -h'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'

## quick ops
alias ll='ls -alhF --color --group-directories-first'
alias l='ll'
alias ee='exit'
alias quit='exit'
alias ns='ss -tunp'
alias pst='pstree -g'
alias g='egrep -i --color=auto'
alias v='vim'
alias c='clear'
alias p='pwd'

## tmux
tmuxa() {
  if [[ -z "${TMUX}" ]]; then
    tmux attach -t rena || (sleep 1 && tmux new -s rena)
  fi
}

tmux_rz() {
  if [[ -z "${TMUX}" ]]; then
    rz $@
  else
    echo 'Please detach tmux first'
  fi
}

tmux_sz() {
  if [[ -z "${TMUX}" ]]; then
    sz $@
  else
    echo 'Please detach tmux first'
  fi
}

alias rz='tmux_rz'
alias sz='tmux_sz'
