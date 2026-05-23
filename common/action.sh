MODDIR=${0%/*}

# Set Standalone for ASH busybox
set +o standalone
unset ASH_STANDALONE

if ! sh $MODDIR/custom.sh; then
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