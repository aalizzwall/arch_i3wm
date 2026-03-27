#!/bin/bash

# ==========================================
# 1. 硬體探測區 (沒有電池的設備會直接安靜退出)
# ==========================================
if [ ! -d "/sys/class/power_supply/BAT0" ]; then
    exit 0
fi

BAT_STATUS_FILE="/sys/class/power_supply/BAT0/status"
BAT_CAP_FILE="/sys/class/power_supply/BAT0/capacity"

# ==========================================
# 2. 記憶標籤 (0 代表還沒通知，1 代表已通知)
# ==========================================
NOTIFIED_LOW=0
NOTIFIED_FULL=0

# 閃爍鍵盤函數
flash_keyboard() {
    for i in {1..3}; do
        brightnessctl --device='smc::kbd_backlight' set 100% > /dev/null
        sleep 0.2
        brightnessctl --device='smc::kbd_backlight' set 0% > /dev/null
        sleep 0.2
    done
    brightnessctl --device='smc::kbd_backlight' set 10% > /dev/null
}

# ==========================================
# 3. 核心監控迴圈
# ==========================================
while true; do
    STATUS=$(cat "$BAT_STATUS_FILE")
    CAPACITY=$(cat "$BAT_CAP_FILE")

    # ⚡ 狀態 A：放電中 (拔除電源)
    if [ "$STATUS" = "Discharging" ]; then
        # 既然拔掉電源了，就把「充飽通知」的標籤撕掉 (重置)
        NOTIFIED_FULL=0

        # 檢查：低於 30% 且「還沒通知過」
        if [ "$CAPACITY" -le 30 ] && [ "$NOTIFIED_LOW" -eq 0 ]; then
            # 發送紅色嚴重警告與鍵盤閃爍
            notify-send -u critical "🔋 低電量警告" "電量僅剩 $CAPACITY%，請立即接上電源！"
            flash_keyboard

            # 貼上標籤！下次就不會再吵你了
            NOTIFIED_LOW=1
        fi

    # 🔌 狀態 B：充電中 (接上電源)
    elif [ "$STATUS" = "Charging" ]; then
        # 既然接上電源了，就把「低電量通知」的標籤撕掉 (重置)
        NOTIFIED_LOW=0

        # 檢查：大於等於 80% 且「還沒通知過」
        if [ "$CAPACITY" -ge 80 ] && [ "$NOTIFIED_FULL" -eq 0 ]; then
            # 充飽電的通知可以用 normal 等級，配上鍵盤閃爍提醒
            notify-send -u normal "🔌 充電達標" "電量已達 $CAPACITY%，可以移除電纜以保護電池！"
            flash_keyboard

            # 貼上標籤！
            NOTIFIED_FULL=1
        fi
    fi

    # 檢查間隔維持 15 秒，因為有了記憶標籤，它不會再狂閃了
    sleep 15
done
