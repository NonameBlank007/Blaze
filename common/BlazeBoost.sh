#!/system/bin/sh

# Error log file path
ERROR_LOGFILE="/storage/emulated/0/error_log.txt"

# Function to log errors
log_error() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Error: $1" >> "$ERROR_LOGFILE"
}

# Configurable variables
CHARGE_CURRENT_FILE="/sys/devices/platform/soc/soc:odm/soc:odm:mmi_chrg_manager/power_supply/mmi_chrg_manager/constant_charge_current_max"
CHARGER_STATUS_FILE="/sys/class/power_supply/primary_chg/online"
BATTERY_TEMP_FILE="/sys/class/power_supply/battery/temp"
NORMAL_CURRENT="3000000"
TURBO_CURRENT="5000000"  # turbo current
TEMP_THRESHOLD=430  # 43°C in deciCelsius
TEMP_DURATION=30  # Increased cool-down duration

# Function to set charging current based on mode
set_charging_current() {
    local current=$1
    if [ -w "$CHARGE_CURRENT_FILE" ]; then
        echo "$current" > "$CHARGE_CURRENT_FILE" || {
            log_error "Unable to set charging current to $current"
            return 1
        }
    else
        log_error "$CHARGE_CURRENT_FILE is not writable"
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
    else
        log_error "$CHARGE_CURRENT_FILE is not writable"
    fi
}

# Function to maintain BlazeBoost charging based on temperature
maintain_charging_current() {
    local cooldown=false
    local cooldown_start=0
    
    while true; do
        if [ -w "$CHARGE_CURRENT_FILE" ]; then
            local charger_status=$(cat "$CHARGER_STATUS_FILE")
            local battery_temp=$(cat "$BATTERY_TEMP_FILE")
            
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
                        sleep 5  # Short sleep during cooldown period to recheck temperature
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
        sleep 5  # Adjust the interval as needed
    done
}

# Handle termination signals
trap "exit 0" SIGINT SIGTERM

# Initial BlazeBoost charging enable
charger_status=$(cat "$CHARGER_STATUS_FILE")
enable_blazeboost_charging "$charger_status"

# Start maintaining charging current in the background
maintain_charging_current &