#
# ~/.bashrc
#

# If not running interactively, don't do anything
#[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
#alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

# --- 1. 智慧 Prompt (顯示 Git 分支) ---
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\[\e[32m\][\u@\h \[\e[33m\]\W\[\e[36m\]\$(parse_git_branch)\[\e[32m\]]\[\e[0m\] \$ "

# --- 3. 系統管理強化 ---
alias ls='ls --color=auto'
alias ll='ls -alF'
alias v='vim'
alias ..='cd ..'
alias ...='cd ../..'

# 快速查看當前消耗資源最多的前 5 個行程 (適合監控 m6s 負載)
alias topcpu='ps -eo pcpu,pid,user,args | sort -k 1 -r | head -5'

# --- 4. 歷史紀錄優化 ---
export HISTSIZE=10000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
