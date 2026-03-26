#!/bin/bash

# 定義你的 Git Bare Repo 指令 (請替換成你的 dotfiles 路徑)
# 這裡假設你的 bare repo 放在 ~/.dotfiles
DOT="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# 【關鍵白名單】：你只在乎這幾個資料夾裡的新檔案，其他垃圾檔不管
WATCH_DIRS=(
    "$HOME/.config/i3"
    "$HOME/.config/i3blocks/scripts"
    "$HOME/.config/dunst"
    "$HOME/.local/bin"
)

# 找出這些資料夾裡，有哪些是「完全沒被追蹤過」的新檔案
# ls-files --others 專門抓 untracked 檔案
NEW_FILES=$($DOT ls-files --others --exclude-standard "${WATCH_DIRS[@]}")

# 如果發現新檔案，觸發 Rofi 攔截！
if [ -n "$NEW_FILES" ]; then
    # 用 rofi 彈出一個多選選單 (-multi-select)，讓你打勾要加入的檔案
    SELECTED=$(echo "$NEW_FILES" | rofi -dmenu -multi-select -p "發現新的設定檔！要加入追蹤嗎？(Shift+Enter 多選)")
    
    if [ -n "$SELECTED" ]; then
        # 把你選中的新檔案加入 Git
        echo "$SELECTED" | while read -r file; do
            $DOT add "$file"
        done
        notify-send "Dotfiles" "已將新檔案加入追蹤名單！"
    else
        notify-send "Dotfiles" "你忽略了新檔案，下次還會再問你。"
        exit 0
    fi
fi

# 處理完新檔案後，順便幫你把「已經追蹤但有修改」的檔案一起 Commit 推送
if ! $DOT diff-index --quiet HEAD --; then
    $DOT add -u
    $DOT commit -m "Auto-sync: $(date +'%Y-%m-%d')"
    $DOT push origin main
    notify-send "Dotfiles 同步完成" "設定檔已更新至雲端！"
fi
