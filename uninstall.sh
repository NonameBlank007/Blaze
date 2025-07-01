#!/system/bin/sh

# Force termination
pkill -9 -f "BlazeBoost.sh" 2>/dev/null
pkill -9 -f "custom.sh" 2>/dev/null

# Remove lockfiles
rm -f /data/adb/blazeboost.lock

# Service script removal
rm -f "/data/adb/service.d/BlazeBoost.sh"

# Zombie process cleanup
for pid in $(pgrep -f "BlazeBoost.sh"); do
    kill -9 $pid 2>/dev/null
done

exit 0