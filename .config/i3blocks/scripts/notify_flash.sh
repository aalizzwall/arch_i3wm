#!/bin/bash

# 使用 pgrep 檢查 i3lock 是否正在背景執行
# -x 代表完全匹配進程名稱
if pgrep -x "i3lock" > /dev/null; then
    
    # 既然螢幕鎖著，我們讓鍵盤背光「呼吸」兩次來提醒你
    for i in {1..2}; do
        # 瞬間亮起
        brightnessctl --device='smc::kbd_backlight' set 100%
        sleep 0.2
        # 瞬間熄滅
        brightnessctl --device='smc::kbd_backlight' set 0%
        sleep 0.2
    done
    
    # 閃完之後，保持微光 (或者你可以設為 0% 完全關閉)
    brightnessctl --device='smc::kbd_backlight' set 10%
fi
