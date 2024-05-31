#!/system/bin/sh

# BlazeBoost Charging Script for /data/adb/service.d
# This script enables BlazeBoost charging and monitors for charging events and temperature.
# Created by Noname_Blank (ZCXCUID)
# Version: 1.4
# Build: 31|05|24 2:10PM

# Configurable variables
CHARGE_CURRENT_FILE="/sys/devices/platform/soc/soc:odm/soc:odm:mmi_chrg_manager/power_supply/mmi_chrg_manager/constant_charge_current_max"
CHARGER_STATUS_FILE="/sys/class/power_supply/primary_chg/online"
BATTERY_TEMP_FILE="/sys/class/power_supply/battery/temp"
NORMAL_CURRENT="3000000"
TURBO_CURRENT="6000000"
DEFAULT_CURRENT="$NORMAL_CURRENT"
TEMP_THRESHOLD=430  # 43°C in deciCelsius
TEMP_DURATION=20 # seconds

# Function to set charging current based on mode
set_charging_current() {
    local current=$1
    if [ -w "$CHARGE_CURRENT_FILE" ]; then
        echo "$current" > "$CHARGE_CURRENT_FILE"
    fi
}

# Function to enable BlazeBoost charging based on mode
enable_blazeboost_charging() {
    if [ -w "$CHARGE_CURRENT_FILE" ]; then
        local mode=$1
        if [ "$mode" -eq 2 ]; then
            set_charging_current "$TURBO_CURRENT"
        else
            set_charging_current "$NORMAL_CURRENT"
        fi
    fi
}

# Function to maintain BlazeBoost charging based on temperature
maintain_charging_current() {
    while true; do
        if [ -w "$CHARGE_CURRENT_FILE" ]; then
            local charger_status=$(cat "$CHARGER_STATUS_FILE")
            local battery_temp=$(cat "$BATTERY_TEMP_FILE")
            if [ "$battery_temp" -ge "$TEMP_THRESHOLD" ]; then
                set_charging_current "$NORMAL_CURRENT"
                sleep "$TEMP_DURATION"
            else
                if [ "$charger_status" -eq 2 ]; then
                    set_charging_current "$TURBO_CURRENT"
                else
                    set_charging_current "$NORMAL_CURRENT"
                fi
            fi
        fi
        sleep 10  # Adjust the interval as needed
    done
}

# Function to monitor charging events
monitor_charging_events() {
    while true; do
        ueventd --verbose | while read -r event; do
            if echo "$event" | grep -q "POWER_SUPPLY"; then
                local charger_status=$(cat "$CHARGER_STATUS_FILE")
                enable_blazeboost_charging "$charger_status"
            fi
        done
        sleep 1
    done
}

# Handle termination signals
trap "exit 0" SIGINT SIGTERM

# Initial BlazeBoost charging enable
charger_status=$(cat "$CHARGER_STATUS_FILE")
enable_blazeboost_charging "$charger_status"

# Start monitoring charging events in the background
monitor_charging_events &

# Start maintaining charging current in the background
maintain_charging_current &