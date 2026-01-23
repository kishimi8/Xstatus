#! /bin/sh

sudo launchctl unload /Library/LaunchDaemons/ng.kishimi8.XStatus.SMC.Helper.plist
sudo rm /Library/LaunchDaemons/ng.kishimi8.XStatus.SMC.Helper.plist
sudo rm /Library/PrivilegedHelperTools/ng.kishimi8.XStatus.SMC.Helper
sudo rm $HOME/Library/Application Support/Stats
