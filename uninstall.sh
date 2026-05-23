#!/system/bin/sh
# Don't modify anything after this

LOCK_FILE="/data/adb/blazeboost.lock"
SERVICE_SCRIPT="/data/adb/service.d/BlazeBoost.sh"

# Kill running services
if [ -f "$LOCK_FILE" ]; then
    pid=$(cat "$LOCK_FILE")
    if [ -d "/proc/$pid" ]; then
        kill -TERM "$pid" 2>/dev/null
        timeout=10
        elapsed=0
        while [ -f "$LOCK_FILE" ] && [ $elapsed -lt $timeout ]; do
            sleep 0.1
            elapsed=$((elapsed + 1))
        done
    fi
fi

# Remove service script
[ -f "$SERVICE_SCRIPT" ] && rm -f "$SERVICE_SCRIPT"

# Clean up lock file
[ -f "$LOCK_FILE" ] && rm -f "$LOCK_FILE"

exit 0