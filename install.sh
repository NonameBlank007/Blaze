##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
# for debugging
# set -x
##########################################################################################
#
# Instructions:
#
# 1. Place your files into the system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount any files for you.
# Most modules would NOT want to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
# REPLACE_EXAMPLE="
# /system/app/Youtube
# /system/priv-app/SystemUI
# /system/priv-app/Settings
# /system/framework
# "

# Construct your own list here
# REPLACE="
# "

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary; the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor are properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non-public APIs are not guaranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of the current installed Magisk
# MAGISK_VER_CODE (int): the version code of the current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Available functions:
#
# ui_print <msg>
#     Print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     Print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     If [context] is empty, it will default to "u:object_r:system_file:s0"
#     This function is a shorthand for the following commands:
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     If [context] is empty, it will default to "u:object_r:system_file:s0"
#     For all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     For all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to do when installing your module
on_install(){
  # Magisk
  if [ -d /data/adb ]; then
      mkdir -p /data/adb/service.d
      cp -af $TMPDIR/BlazeBoost.sh /data/adb/service.d/BlazeBoost.sh
      cp -af $TMPDIR/action.sh $MODPATH/action.sh 
      cp -af $TMPDIR/custom.sh $MODPATH/custom.sh
  fi
}

# print modname if magisk
mod_magisk(){
    ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ui_print "    ██████╗ ██╗        █████╗  ███████╗███████╗"
    ui_print "    ██╔══██╗██║      ██╔══██╗ ╚══███╔╝██╔════╝"
    ui_print "    ██████╔╝██║      ███████║   ███╔╝ █████╗"
    ui_print "    ██████╔╝██║      ███████║  ███╔╝  █████╗"
    ui_print "    ██╔══██╗██║      ██╔══██║ ███╔╝   ██╔══╝"
    ui_print "    ██████╔╝███████╗██║   ██║███████╗███████╗"
    ui_print "    ╚═════╝ ╚══════╝╚═╝   ╚═╝╚══════╝╚══════╝"
    ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ui_print " "
    sleep 1
    ui_print "                Made by @Noname_Blank"
    ui_print " "
    ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ui_print "             🚀 Turbo Charge Script 🚀"
    ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    sleep 0.5
}

# print modname if ksu
mod_ksu(){
    ui_print " "
    ui_print "     +-+-+-+-+-+"
    ui_print "     |B|l|a|z|e|"
    ui_print " +-+-+-+-+-+-+-+-+-+-+-+"
    ui_print " |K|S|U| |E|d|i|t|i|o|n|"
    ui_print " +-+-+-+ +-+-+-+-+-+-+-+"
    ui_print " "
    ui_print "  Turbo Charge Script"
    sleep 0.5
    ui_print " Made by @Noname_Blank"
}

# Set what you want to display when installing your module
print_modname() {
  # Supported devices
  supported_devices="cancunf devonf"
  device_supported=false
  device_ksu=false

  # Get the current device name
  device=$(getprop ro.product.device)

  # Check for ksu
  if [ -d /data/adb/ksu ]; then
    device_ksu=true
  fi

  # Device not supported, abort installation
  for supported_device in $supported_devices; do
    if [ "$supported_device" = "$device" ]; then
        ui_print "- Device '$device' is supported."
        if [ "$device_ksu" = true ]; then
            mod_ksu
        else
            mod_magisk
        fi
        device_supported=true
        break
    fi
  done

  # check for device support
  if [ "$device_supported" = false ]; then
    ui_print "- Device '$device' is not supported."
    ui_print "! This Magisk module is not compatible with your device."
    exit 1
  fi
}

# Copy/extract your module files into $MODPATH in on_install.
# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases
set_permissions() {

  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 2000 0755 0644

  # Magisk
  if [ -d /data/adb ]; then
      set_perm /data/adb/service.d/BlazeBoost.sh 0 0 0755
  fi

  sleep 1
  ui_print "- Permission set..."
  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code