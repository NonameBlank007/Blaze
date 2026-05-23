#!/system/bin/sh

# Created by Noname_Blank
# Build: V2-23-05-2026

CONFIG_FILE="/storage/emulated/0/blazeboost.prop"
LOCK_FILE="/data/adb/blazeboost.lock"
SCRIPT_PATH="/data/adb/service.d/BlazeBoost.sh"

# Dynamic process check
running_pids() {
    pgrep -f "BlazeBoost.sh" | tr '\n' ' '
}

# Kill Blazeboost
kill_blazeboost() {
    # Kill by lockfile
    if [ -f "$LOCK_FILE" ]; then
        pid=$(cat "$LOCK_FILE")
        kill -TERM "$pid" 2>/dev/null
        rm -f "$LOCK_FILE"
    fi

    # Additional cleanup
    pids=$(running_pids)
    if [ -n "$pids" ]; then
        echo "Forcefully killing BlazeBoost process: $pids"
        kill -9 $pids 2>/dev/null
    fi

    # Final cleanup
    pkill -9 -f "BlazeBoost.sh" 2>/dev/null
}

# Change mode
if grep -q "MODE=\"night\"" "$CONFIG_FILE" 2>/dev/null; then
    sed -i 's/MODE="night"/MODE="default"/' "$CONFIG_FILE"
    kill_blazeboost
    nohup sh "$SCRIPT_PATH" >/dev/null 2>&1 &
    echo "Made by Noname_Blank @Telegram"
    echo "- Switched to DEFAULT Mode"
    echo "- Charging Speed are now set to Turbo Mode 21w+"
else
    if [ ! -f "$CONFIG_FILE" ]; then
        echo 'MODE="night"' > "$CONFIG_FILE"
    elif grep -q "MODE=" "$CONFIG_FILE" 2>/dev/null; then
        sed -i 's/MODE=".*"/MODE="night"/' "$CONFIG_FILE"
    else
        echo 'MODE="night"' >> "$CONFIG_FILE"
    fi
    kill_blazeboost
    nohup sh "$SCRIPT_PATH" >/dev/null 2>&1 &
    echo "Made by Noname_Blank @Telegram"
    echo "- Switched to NIGHT Mode"
    echo "- Charging Speed are now set to Normal Mode 13w+"
fi