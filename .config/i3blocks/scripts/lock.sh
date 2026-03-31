#!/bin/bash

# 取得目前的靜音狀態 (yes 或 no)
MUTE_STATE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o 'yes\|no')

# 強制靜音
pactl set-sink-mute @DEFAULT_SINK@ 1

# 鎖定螢幕
i3lock -n -c 000000

# 解鎖後，依照原本的狀態恢復
if [ "$MUTE_STATE" = "no" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ 0
fi
