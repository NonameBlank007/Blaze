#!/system/bin/sh

# Created by Noname_Blank
# File path
CONFIG_FILE="/storage/emulated/0/blazeboost.prop"
LOCK_FILE="/data/adb/blazeboost.lock"

# Dynamic process check
running_pids() {
    pgrep -f "BlazeBoost.sh" | tr '\n' ' '
}

# Kill Blazeboost
kill_blazeboost() {
    # Kill by lockfile
    if [ -f "$LOCK_FILE" ]; then
        pid=$(cat "$LOCK_FILE")
        kill -9 "$pid" 2>/dev/null
        rm -f "$LOCK_FILE"
    fi

    # Additional cleanup if exist
    # Kill by process name
    pids=$(running_pids)
    [ -n "$pids" ] && kill -9 $pids 2>/dev/null
    
    # Final cleanup
    pkill -9 -f "BlazeBoost.sh" 2>/dev/null
}

# Change mode
if grep -q "MODE=\"night\"" "$CONFIG_FILE" 2>/dev/null; then
    sed -i 's/MODE="night"/MODE="default"/' "$CONFIG_FILE"
    kill_blazeboost
    nohup sh /data/adb/service.d/BlazeBoost.sh >/dev/null 2>&1 &
    echo -e " Made by Noname_Blank @Telegram"
    echo -e "- Switched to DEFAULT Mode"
    echo -e "- Charging Speed are now set to Turbo Mode 20w+"
else
    if [ ! -f "$CONFIG_FILE" ]; then
        echo 'MODE="night"' > "$CONFIG_FILE"
    elif grep -q "MODE=" "$CONFIG_FILE"; then
        sed -i 's/MODE=".*"/MODE="night"/' "$CONFIG_FILE"
    else
        echo 'MODE="night"' >> "$CONFIG_FILE"
    fi
    kill_blazeboost
    echo -e " Made by Noname_Blank @Telegram"
    echo -e "- Switched to NIGHT Mode"
    echo -e "- Charging Speed are now set to Normal Mode 11w+"
fi

# Verify termination
sleep 0.5
if [ -n "$(running_pids)" ]; then
    echo "! Failed to stop services" >&2
    exit 1
fi

echo "Operation completed"
exit 0