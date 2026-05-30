MODDIR=${0%/*}

# Check if power is connected
CHECK_RUNNING=$(cat "/sys/class/power_supply/primary_chg/online" 2>/dev/null)

# Set Standalone for ASH busybox
set +o standalone
unset ASH_STANDALONE

if [ "$CHECK_RUNNING" -eq 2 ]; then
   echo -e "Charger connected"
   echo -e "Verify working:"
   echo -e "Step:- 1. Disconnect Charger"
   echo -e "Step:- 2. Run action again"
   echo -e "Step:- 3. Fails to run, Report to devloper"
   exit 1
fi

if ! sh $MODDIR/custom.sh; then
   echo -e "Action failed to run"
   exit 1
fi

echo -e "Mode change complete!"

# warn and automatically closes dilogue if successful
KSU_ACTIVE=false

if [ "$KSU" = "true" ] || [ "$APATCH" = "true" ]; then
    KSU_ACTIVE=true
fi

if $KSU_ACTIVE && [ "$KSU_NEXT" != "true" ] && [ "$WKSU" != "true" ] && [ "$MMRL" != "true" ]; then
    echo -e "\nClosing dialog in 5 seconds..."
    sleep 5
fi