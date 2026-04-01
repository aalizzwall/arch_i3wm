#!/bin/bash

# 透過 i3blocks 傳遞進來的 instance 變數來決定要監控哪個服務
# 這樣你就可以用同一個腳本監控多個不同的服務
SERVICE="$BLOCK_INSTANCE"

if [ -z "$SERVICE" ]; then
    echo "未指定服務"
    exit 0
fi

# 處理滑鼠點擊事件 (i3blocks 內建變數 $BLOCK_BUTTON)
# 1 = 左鍵, 3 = 右鍵
case $BLOCK_BUTTON in
    1) 
        # 左鍵：打開終端機並使用 journalctl 查看該服務的即時日誌
        # 注意：請把 alacritty 換成你使用的終端機 (例如 kitty, gnome-terminal 等)
        i3-sensible-terminal -e journalctl --user -u "$SERVICE" -f & 
        ;;
    3) 
        # 右鍵：重新啟動該服務
        systemctl --user restart "$SERVICE" 
        ;;
esac

# 取得服務狀態
STATE=$(systemctl --user is-active "$SERVICE" 2>/dev/null)

# 【新增這段】：如果服務根本不存在 (unknown)，直接退出，什麼都不顯示！
if [ "$STATE" = "unknown" ]; then
    exit 0
fi

# 根據狀態輸出不同的文字與顏色 (i3blocks 格式：第一行完整文字，第二行短文字，第三行顏色)
if [ "$STATE" = "active" ]; then
    # 正常運作：開心的機器人
    echo "🤖 UP"
    echo "UP"
    echo "#a3be8c"
elif [ "$STATE" = "failed" ]; then
    # 故障：爆炸或警告的機器人 (你可以選一個喜歡的： 💥🤖、⚠️🤖、💀🤖、🔧🤖)
    echo "💀 FAILED"
    echo "FAIL"
    echo "#bf616a"
elif [ "$STATE" = "inactive" ]; then
    # 停止/休眠：睡覺的機器人
    echo "💤 STOPPED"
    echo "STOP"
    echo "#ebcb8b"
else
    # 其他狀態 (啟動中/關閉中)：轉動齒輪的機器人
    echo "⚙️ $STATE"
    echo "$STATE"
    echo "#d08770"
fi
