#!/bin/bash
# Save this as ~/.config/sway/status.sh
# Make it executable: chmod +x ~/.config/sway/status.sh
# In sway config: status_command ~/.config/sway/status.sh

while true; do
    # Date and time
    datetime=$(date +'%A, %B %d, %Y - %I:%M:%S %p')

    if command -v playerctl &> /dev/null; then
        status=$(playerctl status 2>/dev/null)
        if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
            music=$(playerctl metadata --format "{{ title }} - {{ artist }}" 2>/dev/null)
            if [ -n "$music" ] && [ "$music" != " - " ]; then
                # Truncate if too long
                if [ ${#music} -gt 50 ]; then
                    music="${music:0:47}..."
                fi
                # Add status icon
                if [ "$status" = "Playing" ]; then
                    music="  $music [] |"
                else
                    music="  $music [] |"
                fi
            else
                music=""
            fi
        else
            music=""
        fi
    else
        music=""
    fi
    
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

    # Battery percentage and status
    # Note: may need to change BAT0 to your battery name (e.g., BAT1)
    if [ -f /sys/class/power_supply/BAT0/capacity ]; then
        battery_percent=$(cat /sys/class/power_supply/BAT0/capacity)
        battery_status=$(cat /sys/class/power_supply/BAT0/status)

        if [ "$battery_status" = "Charging" ]; then
            battery_icon="󰂄" # Charging icon
        else
            if [ "$battery_percent" -le 10 ]; then
                battery_icon="󰁎" # Empty
            elif [ "$battery_percent" -le 30 ]; then
                battery_icon="󰁼" # Low
            elif [ "$battery_percent" -le 60 ]; then
                battery_icon="󰁾" # Medium
            elif [ "$battery_percent" -le 90 ]; then
                battery_icon="󰂀" # High
            else
                battery_icon="󰁹" # Full
            fi
        fi
        battery="${battery_icon} ${battery_percent}%"
    else
        battery="N/A" # No battery found
    fi
    
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
    echo "$music [  $cpu //  $ram // $battery // 󰛳 $net //  $datetime ] "
done
