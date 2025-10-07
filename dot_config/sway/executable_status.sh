#!/bin/bash
# Save this as ~/.config/sway/status.sh
# Make it executable: chmod +x ~/.config/sway/status.sh
# In sway config: status_command ~/.config/sway/status.sh

while true; do
    # Date and time
    datetime=$(date +'%A, %B %d, %Y | %I:%M:%S %p')
    
    # CPU usage
    cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    
    # GPU usage (tries multiple methods)
    if command -v nvidia-smi &> /dev/null; then
        gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1)
        gpu="${gpu}%"
    elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
        gpu=$(cat /sys/class/drm/card0/device/gpu_busy_percent)"%"
    else
        gpu="N/A"
    fi
    
    # RAM usage
    ram=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
    
    # Network usage (current speed)
    rx_bytes_before=$(cat /sys/class/net/*/statistics/rx_bytes | awk '{sum+=$1} END {print sum}')
    tx_bytes_before=$(cat /sys/class/net/*/statistics/tx_bytes | awk '{sum+=$1} END {print sum}')
    sleep 1
    rx_bytes_after=$(cat /sys/class/net/*/statistics/rx_bytes | awk '{sum+=$1} END {print sum}')
    tx_bytes_after=$(cat /sys/class/net/*/statistics/tx_bytes | awk '{sum+=$1} END {print sum}')
    
    rx_rate=$(( ($rx_bytes_after - $rx_bytes_before) / 1024 ))
    tx_rate=$(( ($tx_bytes_after - $tx_bytes_before) / 1024 ))
    
    net="↓${rx_rate}KB/s ↑${tx_rate}KB/s"
    
    # Output with Nerd Font icons and separators
    echo "  $cpu | 󱄄 $gpu |  $ram | 󰛳 $net |  $datetime"
done
