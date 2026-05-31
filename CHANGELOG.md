# Build Status
```
Fast Charge Module
Name: Blaze
Type: Module
Support: Motorola G54 5G, G64 5G, 73 5G
Build Name: Rikka
Build Version: 2.4.0
```
## Chanagelog

**2.4.0**
- OTA release
- Banner Support for KSUN
- Prevent creating only ```Mode``` blazeboost.prop
- Add check for charger connection in action mode

**2.3.0**
- Change action dialouges and revamp restart in custom.sh
- Prevent instant close of dialouge in KSU and it's like
- Add few permision handlers
- Revamp temprature control and loop logic
  - Less CPU & I/O usage and better temprature
- Revamp uninstall.sh

**2.2.5**
- Remove duplicate BlazeBoost.sh
- Add charge mode toggle through action
- Auto generate config file, Now ```config.txt``` -> ```blzeboost.prop```
- Fix uninstall
- Add custom toggle script for action to execute

**2.2.0**
- Remove unused files
- Upstream scripts to ver.2.2.0
- Fix template for magisk ver.29+
- Revamp device check, install and logo design

**2.1.0**
- Add support for non-power Motorola G54 devices

**2.0.0**
- Support Motorola G73 5G
- Improve temprature control
- Introduce ```config.txt``` file
- Impliment periodic charger status check as loop
- Support configuration file
  - To let users change module configuration without modification directly
- Abort instalation on not supported devices

**1.5.0**
- Convert to module
- Distribute as GPLV2-only, as before
- Module install design
- Intigrate cooldown to maintain charging
- Remove monitoring and use a eroor_log file to write logs

**1.4.0**
- Switch to service.d
- Remove log spams
- Add temprature, current control and necessary paths
- Impliment charger online status check mode from V | tester on leave's info

**1.3.0**
- Skiped

**1.2.0**
- Fix turbo charge disconnection issue
- Add log spam
- Improves background process runs

**1.1.0**
- Some visual improvements
- Adds logging
- Other minor changes

**1.0.0**
- Make a initial script, that runs on ExKernel or FKM by Inspiration of Ñîghtŵølf's version
- Release as GPLV2-only