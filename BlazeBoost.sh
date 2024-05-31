#!/system/bin/sh

# BlazeBoost Charging Script
# This script enables BlazeBoost charging and monitors for charging events.
# Created by Noname_Blank (ZCXCUID)
# Version: 1.2
# Build: 31|05|24 7:00AM

LOG_FILE="/storage/emulated/0/blazeboost.log"
CHARGE_CURRENT_FILE="/sys/devices/platform/soc/soc:odm/soc:odm:mmi_chrg_manager/power_supply/mmi_chrg_manager/constant_charge_current_max"
DEFAULT_CURRENT="6000000" # if heating replace 6 with 5

# Function to display the Blaze ASCII Art Logo
display_logo() {
    cat << "EOF"
  +-+-+-+-+
  |B|l|a|z|e|
  +-+-+-+-+
EOF
}

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to enable BlazeBoost charging
enable_blazeboost_charging() {
    if [ -w "$CHARGE_CURRENT_FILE" ]; then
        echo "$DEFAULT_CURRENT" > "$CHARGE_CURRENT_FILE"
        log_message "⚡ Blaze Boost ⚡"
        log_message "**********************************"
        log_message "Made by Noname_Blank (ZCXCUID)"
        log_message "**********************************"
        log_message "BlazeBoost charging enabled."
        log_message "Version: 1.2"
        log_message "Build: 31|05|24 7:00AM"
    else
        log_message "Error: Cannot write to $CHARGE_CURRENT_FILE"
    fi
}

# Function to maintain BlazeBoost charging
maintain_charging_current() {
    while true; do
        if [ -w "$CHARGE_CURRENT_FILE" ]; then
            echo "$DEFAULT_CURRENT" > "$CHARGE_CURRENT_FILE"
            log_message "Maintaining BlazeBoost charging at $DEFAULT_CURRENT mA."
        else
            log_message "Error: Cannot write to $CHARGE_CURRENT_FILE"
        fi
        sleep 60  # Adjust the interval as needed
    done
}

# Function to monitor charging events
monitor_charging_events() {
    while true; do
        ueventd --verbose | while read -r event; do
            if echo "$event" | grep -q "POWER_SUPPLY"; then
                enable_blazeboost_charging
            fi
        done
        sleep 1
    done
}

# Handle termination signals
trap "log_message 'Script terminated'; exit 0" SIGINT SIGTERM

# Display the logo
display_logo

# Initial BlazeBoost charging enable
enable_blazeboost_charging

# Start monitoring charging events in the background
monitor_charging_events &

# Start maintaining charging current in the background
maintain_charging_current &
