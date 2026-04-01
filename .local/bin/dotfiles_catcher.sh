#!/bin/bash

# 定義你的 Git Bare Repo 指令
DOT="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# ==========================================
# 1. 先同步遠端的最新變更 (新增的關鍵步驟)
# ==========================================
notify-send "Dotfiles" "正在檢查雲端更新..."

# 嘗試拉取更新，如果失敗 (通常是因為兩台電腦改了同一個檔案產生衝突)，就終止腳本
if ! $DOT pull --rebase origin main; then
    notify-send "Dotfiles 錯誤" "拉取雲端更新失敗！可能發生衝突，請打開終端機手動處理。"
    exit 1
fi

# ==========================================
# 2. 檢查本地是否有「完全沒被追蹤過」的新檔案
# ==========================================
WATCH_DIRS=(
    "$HOME/.config/i3"
    "$HOME/.config/i3blocks/scripts"
    "$HOME/.config/dunst"
    "$HOME/.local/bin"
)

NEW_FILES=$($DOT ls-files --others --exclude-standard "${WATCH_DIRS[@]}")

if [ -n "$NEW_FILES" ]; then
    SELECTED=$(echo "$NEW_FILES" | rofi -dmenu -multi-select -p "發現新的設定檔！要加入追蹤嗎？(Shift+Enter 多選)")

    if [ -n "$SELECTED" ]; then
        echo "$SELECTED" | while read -r file; do
            $DOT add "$file"
        done
        notify-send "Dotfiles" "已將新檔案加入追蹤名單！"
    else
        notify-send "Dotfiles" "你忽略了新檔案，下次還會再問你。"
        # 這裡不 exit，讓後續的已追蹤檔案還是能正常 commit
    fi
fi

# ==========================================
# 3. 將「已經追蹤但有修改」的檔案 Commit 並推送
# ==========================================
if ! $DOT diff-index --quiet HEAD --; then
    $DOT add -u
    $DOT commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
    $DOT push origin main
    notify-send "Dotfiles 同步完成" "本地設定已更新至雲端！"
else
    notify-send "Dotfiles" "目前設定已是最新狀態，無需推送。"
fi
