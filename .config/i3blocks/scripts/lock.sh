#!/bin/bash

# 1. 取得目前的靜音狀態 (yes 或 no)
MUTE_STATE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes\|no')

# 2. 強制靜音
pactl set-sink-mute @DEFAULT_SINK@ 1

# 3. 判斷是否有傳入 --dpms 參數
# 只有在手動鎖定時，才執行關閉螢幕的動作
if [ "$1" = "--dpms" ]; then
    (sleep 1 && xset dpms force off) &
fi

# 4. 鎖定螢幕 (-n 留在前景)
i3lock -n -c 000000

# 5. 解鎖後恢復音量
if [ "$MUTE_STATE" = "no" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ 0
fi
