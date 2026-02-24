#!/usr/bin/env bash

# Pomodoro Timer Script
# State file to track timer
STATE_FILE="/tmp/pomodoro_state"
LOCK_FILE="/tmp/pomodoro.lock"
ENV_FILE="/tmp/pomodoro_env"

# Save environment for background processes
save_env() {
    cat > "$ENV_FILE" << EOF
export DISPLAY="$DISPLAY"
export DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS"
export XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR"
EOF
}

# Pomodoro settings (in minutes)
WORK_TIME=1
SHORT_BREAK=5
LONG_BREAK=15
POMODOROS_UNTIL_LONG_BREAK=4

# Initialize state if it doesn't exist
init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "status=stopped" > "$STATE_FILE"
        echo "mode=work" >> "$STATE_FILE"
        echo "remaining=0" >> "$STATE_FILE"
        echo "pomodoro_count=0" >> "$STATE_FILE"
    fi
    # Always save environment for background processes
    save_env
}

# Read state
read_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    fi
}

# Write state
write_state() {
    cat > "$STATE_FILE" << EOF
status=$status
mode=$mode
remaining=$remaining
pomodoro_count=$pomodoro_count
EOF
}

# Start timer
start_timer() {
    init_state
    read_state
    
    if [ "$status" = "stopped" ]; then
        status="running"
        
        case $mode in
            work)
                remaining=$((WORK_TIME * 60))
                ;;
            short_break)
                remaining=$((SHORT_BREAK * 60))
                ;;
            long_break)
                remaining=$((LONG_BREAK * 60))
                ;;
        esac
        
        write_state
        notify-send -i appointment-soon -a "Pomodoro" "Pomodoro Started" "Focus for ${WORK_TIME} minutes!" -t 3000
        
        # Start the countdown in background
        (countdown_timer) &
    fi
}

# Stop timer
stop_timer() {
    init_state
    read_state
    status="stopped"
    remaining=0
    write_state
    
    # Kill any running countdown
    pkill -f "pomodoro.sh countdown" 2>/dev/null
    
    notify-send -i process-stop -a "Pomodoro" "Pomodoro Stopped" "Timer has been stopped" -t 2000
}

# Pause/Resume timer
toggle_pause() {
    init_state
    read_state
    
    if [ "$status" = "running" ]; then
        status="paused"
        notify-send -i media-playback-pause -a "Pomodoro" "Pomodoro Paused" "Timer paused at $(format_time $remaining)" -t 2000
    elif [ "$status" = "paused" ]; then
        status="running"
        notify-send -i media-playback-start -a "Pomodoro" "Pomodoro Resumed" "Continuing..." -t 2000
        (countdown_timer) &
    fi
    
    write_state
}

# Countdown timer (runs in background)
countdown_timer() {
    # Load environment for notifications
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    fi
    
    # Use lock file to prevent multiple countdowns
    exec 200>"$LOCK_FILE"
    flock -n 200 || exit 1
    
    while true; do
        read_state
        
        if [ "$status" != "running" ]; then
            break
        fi
        
        if [ $remaining -le 0 ]; then
            timer_complete
            break
        fi
        
        remaining=$((remaining - 1))
        write_state
        sleep 1
    done
    
    flock -u 200
}

# Timer complete
timer_complete() {
    # Load environment for notifications
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    fi
    
    read_state
    
    case $mode in
        work)
            pomodoro_count=$((pomodoro_count + 1))
            
            if [ $((pomodoro_count % POMODOROS_UNTIL_LONG_BREAK)) -eq 0 ]; then
                mode="long_break"
                notify-send -u critical -i emblem-default -a "Pomodoro" "Work Complete!" "Great job! Take a ${LONG_BREAK} minute break.\nCompleted: ${pomodoro_count} pomodoros" -t 10000
            else
                mode="short_break"
                notify-send -u critical -i emblem-default -a "Pomodoro" "Work Complete!" "Time for a ${SHORT_BREAK} minute break.\nCompleted: ${pomodoro_count} pomodoros" -t 10000
            fi
            ;;
        short_break|long_break)
            mode="work"
            notify-send -u critical -i alarm-symbolic -a "Pomodoro" "Break Over!" "Ready for another ${WORK_TIME} minute focus session?" -t 10000
            ;;
    esac
    
    status="stopped"
    remaining=0
    write_state
    
    # Play a sound (if available)
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || \
    pw-play /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || \
    aplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || true
}

# Format time for display
format_time() {
    local seconds=$1
    local mins=$((seconds / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d" $mins $secs
}

# Get status for waybar
get_status() {
    init_state
    read_state
    
    local text=""
    local tooltip=""
    
    case $status in
        running)
            text="$(format_time $remaining)"
            tooltip="Pomodoro - ${mode}\nRemaining: $(format_time $remaining)\nCompleted: ${pomodoro_count}"
            ;;
        paused)
            text="⏸ $(format_time $remaining)"
            tooltip="Pomodoro - PAUSED\nMode: ${mode}\nRemaining: $(format_time $remaining)"
            ;;
        stopped)
            text=""
            tooltip="Pomodoro - Ready\nCompleted today: ${pomodoro_count}\nClick to start ${WORK_TIME}min focus"
            ;;
    esac
    
    # Output for waybar
    echo "{\"text\":\"$text\",\"tooltip\":\"$tooltip\",\"class\":\"$status\",\"alt\":\"$mode\"}"
}

# Reset pomodoro count
reset_count() {
    init_state
    read_state
    
    # Kill any running countdown
    pkill -f "pomodoro.sh countdown" 2>/dev/null
    
    # Reset everything to initial state
    status="stopped"
    mode="work"
    remaining=0
    pomodoro_count=0
    
    write_state
    notify-send -i view-refresh -a "Pomodoro" "Pomodoro Reset" "Reset to work mode. Ready to start!" -t 2000
}

# Main command handler
case "${1:-status}" in
    start)
        start_timer
        ;;
    stop)
        stop_timer
        ;;
    toggle)
        toggle_pause
        ;;
    countdown)
        countdown_timer
        ;;
    status)
        get_status
        ;;
    reset)
        reset_count
        ;;
    *)
        echo "Usage: $0 {start|stop|toggle|status|reset}"
        exit 1
        ;;
esac
