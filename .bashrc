# ==============================================================================
# 🐧 Pascal's Ultimate Arch Linux .bashrc (MacBook Pro & m6s)
# ==============================================================================

# 如果不是互動式 Shell，則直接退出
[[ $- != *i* ]] && return

# ==============================================================================
# 1. 系統環境與 Bash 選項 (Shopt)
# ==============================================================================
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Bash 行為優化
shopt -s cdspell         # 自動修正 cd 時的輕微拼字錯誤
shopt -s checkwinsize    # 調整視窗大小後自動更新行數與欄數
shopt -s cmdhist         # 將多行指令儲存為單一歷史紀錄
shopt -s dotglob         # 讓 * 也能匹配隱藏檔案
shopt -s expand_aliases  # 允許 alias 展開
shopt -s extglob         # 啟用延伸的模式匹配特徵
shopt -s histappend      # 歷史紀錄用追加的，不要覆蓋
shopt -s hostcomplete    # 嘗試補齊主機名稱

set -o vi                # 啟用 Vi 編輯模式的命令列

# X11 權限：允許本地端 Root 執行圖形介面程式
xhost +local:root > /dev/null 2>&1
complete -cf sudo

# ==============================================================================
# 2. 環境變數設定 (Exports)
# ==============================================================================
export EDITOR=vim
export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}
export HISTCONTROL=ignoreboth

# [Java 與開發環境]
# Arch Linux 現代做法：建議使用 `archlinux-java` 指令來切換預設 Java 版本
# 預設路徑通常為 /usr/lib/jvm/default
# 以下保留你的舊設定並註解，若有手動安裝 Oracle JDK 可解除註解
# export JAVA_FONTS=/usr/share/fonts/TTF
# export JRE_HOME=/home/pascal/workspace/software/oracle_jdk/jdk1.8.0_65/jre
# export JAVA_HOME=/home/pascal/workspace/software/oracle_jdk/jdk1.8.0_65
# export PATH=$JRE_HOME/../bin:$PATH
# export M2_HOME=/opt/maven

# ==============================================================================
# 3. 智慧型 Prompt (整合 Git 狀態與時間差)
# ==============================================================================
function git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
    echo "("${ref#refs/heads/}") ";
}

function git_since_last_commit {
    now=`date +%s`;
    last_commit=$(git log --pretty=format:%at -1 2> /dev/null) || return;
    seconds_since_last_commit=$((now-last_commit));
    minutes_since_last_commit=$((seconds_since_last_commit/60));
    hours_since_last_commit=$((minutes_since_last_commit/60));
    minutes_since_last_commit=$((minutes_since_last_commit%60));
    echo "${hours_since_last_commit}h${minutes_since_last_commit}m ";
}

PS1="[\u@\h \[\033[1;32m\]\w\[\033[0m\]] \[\033[0m\]\[\033[1;36m\]\$(git_branch)\[\033[0;33m\]\$(git_since_last_commit)\[\033[0m\]$ " 

# ==============================================================================
# 4. 別名 (Aliases)
# ==============================================================================
# --- 檔案操作與顯示 (保留你的習慣) ---
alias vi='vim'
alias cp='cp -i'
alias df='df -h'
alias free='free -m'
alias grep='grep --color=tty -d skip'
alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias ll='ls -l --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'
alias la='ls -la --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto -F'

# --- 系統維護與 Arch 專屬 ---
alias np='nano PKGBUILD'
# 升級版 fixit：解鎖 pacman 並使用 yay 一鍵更新所有系統與 AUR 套件
alias fixit='sudo rm -f /var/lib/pacman/db.lck && yay -Syyuu'

# --- Yay (AUR) 快捷鍵 ---
alias y='yay'
alias yu='yay -Syu'              # 一鍵更新
alias yi='yay -S'                # 安裝
alias yr='yay -Rns'              # 徹底移除
alias yq='yay -Ss'               # 搜尋
alias yc='yay -Yc'               # 清理無用依賴
alias yclean='yay -Scc'          # 清除快取釋放空間

# --- Git 裸倉庫同步 ---
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# --- 其他 ---
alias bird="streamlink rtmp://193.40.133.138/live/kalakotkas2 live"

# ==============================================================================
# 5. 實用函式 (Functions)
# ==============================================================================
# 萬用解壓縮
ex () {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.tbz2)      tar xjf "$1"   ;;
      *.tgz)       tar xzf "$1"   ;;
      *.zip)       unzip "$1"     ;;
      *.Z)         uncompress "$1";;
      *.7z)        7z x "$1"      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# 解決 Big5 亂碼壓縮檔 (需安裝 p7zip 與 convmv)
exB5() {
  file=$(basename "$1")
  filename=${file%.*}
  LANG=zh_TW.BIG-5 7z x "$1" -o"$filename"
  cd "$filename" && convmv -f big5 -t utf8 -r --notest *
}

# 解決 GBK 簡體亂碼壓縮檔 (需安裝 p7zip 與 convmv)
exCN() {
  file=$(basename "$1")
  filename=${file%.*}
  LANG=zh_CN.GBK 7z x "$1" -o"$filename"
  cd "$filename" && convmv -f gbk -t utf8 -r --notest *
}

# ==============================================================================
# 6. TTY 自動啟動 X11 (i3wm)
# ==============================================================================
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec startx
fi
