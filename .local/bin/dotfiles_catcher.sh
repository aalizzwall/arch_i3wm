#!/bin/bash

# ==========================================
# Dotfiles 同步腳本 (結合 Rofi 與 Notify-send)
# ==========================================

GIT_DIR="$HOME/.dotfiles/"
WORK_TREE="$HOME"
GIT_CMD="/usr/bin/git --git-dir=$GIT_DIR --work-tree=$WORK_TREE"
BRANCH="main"

notify-send "Dotfiles" "🔄 開始檢查遠端同步狀態..." -t 2000

# 1. 檢查本地追蹤檔案是否有變更
if ! $GIT_CMD diff-index --quiet HEAD --; then
    # 偵測到變更，呼叫 rofi 讓使用者決定如何處理
    CHOICE=$(echo -e "1. 自動 Commit 並雙向同步\n2. 暫存修改 (Stash) 並拉取遠端\n3. 取消本次同步" | rofi -dmenu -i -p "⚠️ 偵測到本地設定檔已修改:")

    case "$CHOICE" in
        *"自動 Commit"*)
            notify-send "Dotfiles" "📝 正在自動 Commit 本地變更..." -t 2000
            $GIT_CMD add -u
            $GIT_CMD commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
            ;;
        *"暫存修改"*)
            notify-send "Dotfiles" "📦 正在暫存本地變更..." -t 2000
            $GIT_CMD stash push -m "auto-stash-before-sync"
            STASHED=true
            ;;
        *)
            notify-send "Dotfiles" "🛑 已取消同步操作。" -t 2000
            exit 0
            ;;
    esac
fi

# 2. 執行拉取 (Pull)
notify-send "Dotfiles" "⬇️ 正在拉取遠端最新設定..." -t 2000
if ! $GIT_CMD pull origin $BRANCH --rebase; then
    notify-send "Dotfiles Error" "❌ 拉取失敗！請開啟終端機檢查衝突。" -u critical
    exit 1
fi

# 3. 處理剛才的暫存 (如果有選 Stash 的話)
if [ "$STASHED" = true ]; then
    notify-send "Dotfiles" "📤 正在還原剛才暫存的變更..." -t 2000
    $GIT_CMD stash pop
    # 這裡不自動 push，因為如果是 stash 模式，代表使用者還在改東西
    notify-send "Dotfiles" "✅ 遠端已拉取，本地變更已還原！" -t 3000
    exit 0
fi

# 4. 執行推送 (Push) - 只有在剛才是選擇自動 Commit 時才會走到這裡
notify-send "Dotfiles" "⬆️ 正在推送至遠端..." -t 2000
if $GIT_CMD push origin $BRANCH; then
    notify-send "Dotfiles" "🎉 同步完美結束！" -u normal
else
    notify-send "Dotfiles Error" "❌ 推送失敗！請檢查網路或權限。" -u critical
fi
