#
# ~/.bashrc
#

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

# --- 備份常用環境參數 ---
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# --- SSH Agent 自動化設定 ---
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -s > "$HOME/.ssh/ssh-agent.env"
fi

if [[ ! "$SSH_AUTH_SOCK" ]]; then
    eval "$(<"$HOME/.ssh/ssh-agent.env")" > /dev/null
fi

# 檢查是否已經加入鑰匙，若無則加入
ssh-add -l > /dev/null || ssh-add ~/.ssh/id_ed25519 2> /dev/null
