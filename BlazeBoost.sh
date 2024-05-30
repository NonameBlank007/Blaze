#!/system/bin/sh

# BlazeBoost Charging Script

# Blaze ASCII Art Logo
cat << "EOF"
  ____     _                
 | __ )  | | __ _ _______  
 |  _ \  | |/ _` |_   /  _   \ 
 | |_)  | | (_| |/  /    __/ 
 |____/|_|\__,_/___\___| 
                                  
EOF

# Function to enable BlazeBoost charging
enable_blazeboost_charging() {
    echo "5500000" > /sys/devices/platform/soc/soc:odm/soc:odm:mmi_chrg_manager/power_supply/mmi_chrg_manager/constant_charge_current_max
    echo "BlazeBoost charging enabled."
    echo "Modified by Noname_Blank (ZCXCUID)"
}

# Initial BlazeBoost charging enable
enable_blazeboost_charging

# Monitor charging events
while true; do
    ueventd --verbose | while read -r event; do
        if echo "$event" | grep -q "POWER_SUPPLY"; then
            enable_blazeboost_charging
        fi
    done
    sleep 1
done
