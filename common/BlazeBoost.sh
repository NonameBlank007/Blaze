#!/system/bin/sh

# BlazeBoost Charging Script for /data/adb/service.d
# This script enables BlazeBoost charging and monitors for charging events and temperature.
# Created by Noname_Blank
# Version: 2.3.0
# Build: 23:05:2026 12:05PM

# Lock file management
LOCK_FILE="/data/adb/blazeboost.lock"
if [ -f "$LOCK_FILE" ]; then
    pid=$(cat "$LOCK_FILE")
    if [ -d "/proc/$pid" ]; then
        echo "BlazeBoost is already running (PID $pid)"
        exit 0
    else
        rm -f "$LOCK_FILE"
    fi
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"; exit 0' EXIT TERM

# Device configuration
Device=$(cat /proc/device-tree/mot,model)
if [ "$Device" = "cancunf" ]; then
    if [ -f /sys/devices/platform/soc/soc:odm/soc:odm:mmi_chrg_manager/power_supply/mmi_chrg_manager/constant_charge_current_max ]; then
        CHARGE_CURRENT_FILE="/sys/devices/platform/soc/soc:odm/soc:odm:mmi_chrg_manager/power_supply/mmi_chrg_manager/constant_charge_current_max"
    elif [ -f /sys/devices/platform/charger/power_supply/mtk-master-charger/constant_charge_current_max ]; then
        CHARGE_CURRENT_FILE="/sys/devices/platform/charger/power_supply/mtk-master-charger/constant_charge_current_max"
    else
        exit 1
    fi
elif [ "$Device" = "devonf" ]; then
    CHARGE_CURRENT_FILE="/sys/devices/platform/charger/power_supply/mtk-master-charger/constant_charge_current_max"
else
    exit 1
fi

# File paths
if [ -f /sys/class/power_supply/primary_chg/online ]; then
    CHARGER_STATUS_FILE="/sys/class/power_supply/primary_chg/online"
elif [ -f /sys/class/power_supply/11b20000.i2c:mt6375@34:chg/online ]; then
    CHARGER_STATUS_FILE="/sys/class/power_supply/11b20000.i2c:mt6375@34:chg/online"
else
    exit 1
fi
BATTERY_TEMP_FILE="/sys/class/power_supply/battery/temp"
CONFIG_FILE="/storage/emulated/0/blazeboost.prop"

# Default values
DEFAULT_NORMAL_CURRENT="3000000"
DEFAULT_TURBO_CURRENT="5000000"
DEFAULT_TEMP_THRESHOLD=430
DEFAULT_TEMP_DURATION=30
DEFAULT_INTERVAL=15
DEFAULT_MODE="default"

# Load configuration
load_blazeboost_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "NORMAL_CURRENT=\"$DEFAULT_NORMAL_CURRENT\"" > "$CONFIG_FILE"
        echo "TURBO_CURRENT=\"$DEFAULT_TURBO_CURRENT\"" >> "$CONFIG_FILE"
        echo "TEMP_THRESHOLD=$DEFAULT_TEMP_THRESHOLD" >> "$CONFIG_FILE"
        echo "TEMP_DURATION=$DEFAULT_TEMP_DURATION" >> "$CONFIG_FILE"
        echo "INTERVAL=$DEFAULT_INTERVAL" >> "$CONFIG_FILE"
        echo "MODE=\"$DEFAULT_MODE\"" >> "$CONFIG_FILE"
        chmod 0666 "$CONFIG_FILE"
    fi
    
    . "$CONFIG_FILE"
    NORMAL_CURRENT="${NORMAL_CURRENT:-$DEFAULT_NORMAL_CURRENT}"
    TURBO_CURRENT="${TURBO_CURRENT:-$DEFAULT_TURBO_CURRENT}"
    TEMP_THRESHOLD="${TEMP_THRESHOLD:-$DEFAULT_TEMP_THRESHOLD}"
    TEMP_DURATION="${TEMP_DURATION:-$DEFAULT_TEMP_DURATION}"
    INTERVAL="${INTERVAL:-$DEFAULT_INTERVAL}"
    MODE="${MODE:-$DEFAULT_MODE}"
}

# Set charging current
set_charging_current() {
    echo "$1" > "$CHARGE_CURRENT_FILE" 2>/dev/null
}

# Set current based on mode
set_current_based_on_mode() {
    charger_status=$1
    if [ "$MODE" = "night" ]; then
        set_charging_current "$NORMAL_CURRENT"
    else
        if [ "$charger_status" -eq 2 ]; then
            set_charging_current "$TURBO_CURRENT"
        else
            set_charging_current "$NORMAL_CURRENT"
        fi
    fi
}

# Main charging function
maintain_charging() {
    load_blazeboost_config
    charger_status=$(cat "$CHARGER_STATUS_FILE" 2>/dev/null)
    battery_temp=$(cat "$BATTERY_TEMP_FILE" 2>/dev/null)

    if [ -z "$charger_status" ] || [ -z "$battery_temp" ]; then
        return
    fi

    if [ "$battery_temp" -ge "$TEMP_THRESHOLD" ]; then
        set_charging_current "$NORMAL_CURRENT"
        sleep "$TEMP_DURATION"
    else
        set_current_based_on_mode "$charger_status"
    fi
}

# Initialize
load_blazeboost_config
set_current_based_on_mode "$(cat "$CHARGER_STATUS_FILE" 2>/dev/null)"

# Start main process
while true; do
    charger_status=$(cat "$CHARGER_STATUS_FILE" 2>/dev/null)

    if [ "$charger_status" -eq 2 ]; then
        maintain_charging
    else
        echo "Charger not connected. Waiting..."
    fi

    sleep "$INTERVAL"
done