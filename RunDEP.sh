#!/bin/bash
#
# J. Vandehey 8/28/19
#
# This script is triggered from a Launch Agent and will run through various JAMF policies, and reboot at the end.
# DEPNofiy is used to notify the user during the process. 

# Get the logged in user
CURRENTUSER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# Setup Done File
setupDone="/var/db/receipts/com.yourco.provisioning.done.bom"

## If this script has already run, delete the launchd item
if [  -f "${setupDone}" ]; then
        # Remove the Launch Daemon
         /bin/rm /Library/LaunchDaemons/com.jvandehey.launch.plist
        exit
fi

## Check to make sure a user is logged in
if pgrep -x "Finder" \
&& pgrep -x "Dock" \
&& [ "$CURRENTUSER" != "_mbsetupuser" ] \
&& [ ! -f "${setupDone}" ]; then

## Clear out old log
rm /var/log/jamf.log
touch /var/log/jamf.log
rm /var/tmp/depnotify.log

## Set a default progress title
echo "Status: Fetching Software Titles...." >> /var/tmp/depnotify.log
echo "Command: MainTitle: Welcome to Your Company!" >> /var/tmp/depnotify.log
echo "Command: MainText: We are setting up your Mac with Your Company's core tools and settings. This process could take up to 20 minutes. IMPORTANT: PLEASE DO NOT REBOOT UNTIL THIS PROCESS IS COMPLETE." >> /var/tmp/depnotify.log
echo "Command: Image: /var/tmp/logo.png" >> /var/tmp/depnotify.log

## Open DEP Notify
/var/tmp/DEPNotify.app/Contents/MacOS/DEPNotify -jamf &

## Run caffinate to avoid sleep
  /usr/bin/caffeinate -d -i -m -u &
  caffeinatepid=$!

## Advise the user not to reboot
echo "Status: Starting installation of Your Company applications. Please do NOT reboot...." >> /var/tmp/depnotify.log
sleep 3

## Create admin user
echo "Status: Creating Admin Account...." >> /var/tmp/depnotify.log
sleep 2
/usr/local/bin/jamf policy -event CustomTrigger1 -verbose

## Install BlueJeans
echo "Status: Downloading Zoom...." >> /var/tmp/depnotify.log
sleep 3
/usr/local/bin/jamf policy -event CustomTrigger2 -verbose

## Create LaunchAgents folder for CrashPlan
mkdir /Users/$CURRENTUSER/Library/LaunchAgents
chown $CURRENTUSER /Users/$CURRENTUSER/Library/LaunchAgents

## Install Sophos
echo "Status: Downloading Crowdstrike Falcon Sensor...." >> /var/tmp/depnotify.log
sleep 3
/usr/local/bin/jamf policy -event CustomTrigger3 -verbose

## Install Google Chrome
echo "Status: Downloading the latest version of Google Chrome...." >> /var/tmp/depnotify.log
sleep 3
/usr/local/bin/jamf policy -event CustomTrigger4

## Install Chrome Settings, and set the hostname
echo "Status: Configuring Chrome. Please do NOT reboot...." >> /var/tmp/depnotify.log
sleep 3
/usr/local/bin/jamf policy -event CustomTrigger5

## Install CrashPlan
echo "Status: Downloading CrashPlan...." >> /var/tmp/depnotify.log
sleep 3
/usr/local/bin/jamf policy -event CustomTrigger6

## Install Slack
echo "Status: Downloading the latest version of Slack...." >> /var/tmp/depnotify.log
sleep 3
/usr/local/bin/jamf policy -event CustomTrigger7

## Install Google File Stream
echo "Status: Downloading the latest version of Google File Stream...." >> /var/tmp/depnotify.log
sleep 3
/usr/local/bin/jamf policy -event CustomTrigger8

## Enable FileVault
## This will notify the user that the computer will reboot when done
echo "Status: Checking for final installs...." >> /var/tmp/depnotify.log
Sleep 2
/usr/local/bin/jamf policy -event CustomTrigger9

## Customize the Dock
echo "Status: Customizing the user dock...." >> /var/tmp/depnotify.log
sleep 3
/usr/local/bin/jamf policy -event CustomTrigger10

## Notify of recon running
echo "Status: Finishing Installation....Submitting computer info to Your Company" >> /var/tmp/depnotify.log
sleep 5

## Notify of recon running
echo "Status: Installation is complete! Your system will reboot in 15 seconds" >> /var/tmp/depnotify.log
sleep 5

echo "Status: Installation is complete! Your system will reboot in 10 seconds" >> /var/tmp/depnotify.log
sleep 5

echo "Status: Installation is complete! Your system will reboot in 5 seconds" >> /var/tmp/depnotify.log
sleep 5

## Send the quit message to DEP Notify
/usr/local/bin/jamf policy -event DEP_Quit

## Disable Verbose Logging
#sudo defaults delete /Library/Preferences/com.jamfsoftware.jamf.plist global_log_level

## Kill Caffienate 
kill "$caffeinatepid"

Echo "Command: RestartNow:" >> /var/tmp/depnotify.log

## Cleanup
/bin/rm -Rf /var/tmp/DEPNotify.app
/bin/rm -Rf /var/tmp/logo.png

# # Wait a few seconds
#sleep 5
## Create a bom file that allow this script to stop launching DEPNotify after done
/usr/bin/touch /var/db/receipts/com.yourco.provisioning.done.bom

## Remove the Launch Daemon
/bin/rm -Rf /Library/LaunchDaemons/com.jvandehey.launch.plist

fi
exit
