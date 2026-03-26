#!/bin/bash

# ==========================================
# 1. 硬體探測區 (專為共用 Dotfiles 設計)
# ==========================================
# 檢查 BAT0 目錄是否存在。如果不存在 (例如在 m6s 上)，腳本就直接無聲無息地退出，不佔用任何資源！
if [ ! -d "/sys/class/power_supply/BAT0" ]; then
    exit 0
fi

# ==========================================
# 2. 變數與函數定義
# ==========================================
BAT_STATUS_FILE="/sys/class/power_supply/BAT0/status"
BAT_CAP_FILE="/sys/class/power_supply/BAT0/capacity"

# 閃爍鍵盤的函數
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

    # 低電量警告 (<= 30% 且正在放電)
    if [ "$STATUS" = "Discharging" ] && [ "$CAPACITY" -le 30 ]; then
        flash_keyboard
    fi

    # 過充警告 (>= 80% 且正在充電)
    if [ "$STATUS" = "Charging" ] && [ "$CAPACITY" -ge 80 ]; then
        flash_keyboard
    fi

    # 每 15 秒檢查一次
    sleep 15
done
