MODDIR=${0%/*}

# Set Standalone for ASH busybox
set +o standalone
unset ASH_STANDALONE

if ! sh $MODDIR/custom.sh; then
   exit 1
fi

echo -e "Mode change complete!"