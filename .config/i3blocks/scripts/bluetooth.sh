#!/bin/bash

# 接收 i3blocks 傳來的滑鼠點擊事件
case "$BLOCK_BUTTON" in
    1) rofi-bluetooth & ;; # 左鍵：呼叫選單
    3) if rfkill list bluetooth | grep -q 'Soft blocked: yes'; then
           rfkill unblock bluetooth
       else
           rfkill block bluetooth
       fi ;; # 右鍵：切換電源
esac

# 判斷硬體狀態與連線數並動態變色
if rfkill list bluetooth | grep -q 'Soft blocked: yes'; then
    echo "<span color='#5c6370'>󰂲</span>"
else
    connected=$(bluetoothctl devices Connected | wc -l)
    if [ "$connected" -gt 0 ]; then
        echo "<span color='#98c379'>󰂱 $connected</span>"
    else
        echo "<span color='#61afef'>󰂯</span>"
    fi
fi
