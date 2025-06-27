#!/system/bin/sh

# BlazeBoost Charging Script for /data/adb/service.d
# This script enables BlazeBoost charging and monitors for charging events and temperature.
# Created by Noname_Blank
# Version: 2.2.0
# Build: 27:06:2025 10:15PM

# Check Device name
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

CHARGER_STATUS_FILE="/sys/class/power_supply/primary_chg/online"
BATTERY_TEMP_FILE="/sys/class/power_supply/battery/temp"
CONFIG_FILE="/storage/emulated/0/config.txt"
DEFAULT_NORMAL_CURRENT="3000000"
DEFAULT_TURBO_CURRENT="6000000"
DEFAULT_TEMP_THRESHOLD=430
DEFAULT_TEMP_DURATION=30
DEFAULT_INTERVAL=15

# Function to load settings from the configuration file
load_blazeboost_config() {
    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE" || return 1
        NORMAL_CURRENT="${NORMAL_CURRENT:-$DEFAULT_NORMAL_CURRENT}"
        TURBO_CURRENT="${TURBO_CURRENT:-$DEFAULT_TURBO_CURRENT}"
        TEMP_THRESHOLD="${TEMP_THRESHOLD:-$DEFAULT_TEMP_THRESHOLD}"
        TEMP_DURATION="${TEMP_DURATION:-$DEFAULT_TEMP_DURATION}"
        INTERVAL="${INTERVAL:-$DEFAULT_INTERVAL}"
    else
        NORMAL_CURRENT="$DEFAULT_NORMAL_CURRENT"
        TURBO_CURRENT="$DEFAULT_TURBO_CURRENT"
        TEMP_THRESHOLD="$DEFAULT_TEMP_THRESHOLD"
        TEMP_DURATION="$DEFAULT_TEMP_DURATION"
        INTERVAL="$DEFAULT_INTERVAL"
    fi
}

# Function to set charging current based on mode
set_charging_current() {
    local current=$1
    if [ -w "$CHARGE_CURRENT_FILE" ]; then
        echo "$current" > "$CHARGE_CURRENT_FILE" || return 1
    else
        return 1
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
    local cooldown=false
    local cooldown_start=0
    
    while true; do
        if [ -w "$CHARGE_CURRENT_FILE" ]; then
            local charger_status=$(cat "$CHARGER_STATUS_FILE" 2>/dev/null)
            local battery_temp=$(cat "$BATTERY_TEMP_FILE" 2>/dev/null)
            
            if [ -z "$charger_status" ] || [ -z "$battery_temp" ]; then
                sleep "$INTERVAL"
                continue
            fi
            
            if [ "$battery_temp" -ge "$TEMP_THRESHOLD" ]; then
                set_charging_current "$NORMAL_CURRENT"
                cooldown=true
                cooldown_start=$(date +%s)
                sleep "$TEMP_DURATION"
            else
                if [ "$cooldown" = true ]; then
                    local current_time=$(date +%s)
                    local elapsed_time=$((current_time - cooldown_start))
                    
                    if [ "$elapsed_time" -ge "$TEMP_DURATION" ]; then
                        cooldown=false
                    else
                        sleep "$INTERVAL"  # Short sleep during cooldown period to recheck temperature
                        continue
                    fi
                fi

                if [ "$charger_status" -eq 2 ]; then
                    set_charging_current "$TURBO_CURRENT"
                else
                    set_charging_current "$NORMAL_CURRENT"
                fi
            fi
        fi
        sleep "$INTERVAL" # Adjust the interval as needed
    done
}

# Function to periodically check charger status and reload config if necessary
check_charger_status() {
    local previous_status=""
    
    while true; do
        local current_status=$(cat "$CHARGER_STATUS_FILE" 2>/dev/null)
        if [ -z "$current_status" ]; then
            sleep 10
            continue
        fi
        
        if [ "$current_status" != "$previous_status" ]; then
            previous_status="$current_status"
            load_blazeboost_config
            enable_blazeboost_charging "$current_status"
        fi
        sleep 10  # Check every 10 seconds, adjust as needed
    done
}

# Handle termination signals
trap "exit 0" SIGINT SIGTERM

# Initial BlazeBoost charging enable
load_blazeboost_config
charger_status=$(cat "$CHARGER_STATUS_FILE" 2>/dev/null)
enable_blazeboost_charging "$charger_status"

# Start maintaining charging current in the background
maintain_charging_current &

# Start checking charger status in the background
check_charger_status &

# End of script