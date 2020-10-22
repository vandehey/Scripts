#!/bin/sh
#
####################################################################################################
#
# JAMF script to setup the dock on a new system (Can be used in Self Service as well)
#
# Jeff Vandehey 7/8/20
#
####################################################################################################
#
# DESCRIPTION
#
# Uses dockutil to make changes to the users dock.
#

# set to the path of dockutil
dockutil="/usr/local/bin/dockutil"

# Check to see if dockutil is already installed. If not, install it

	if [ ! -f $dockutil ]; then
  	  echo "dockutil is not installed. Installing it....."
  	  /usr/local/bin/jamf policy -trigger dock_util
	fi
	
# Delete everything from the dock and replace it with a specific
# selection of apps.

${dockutil} --remove all /Users/$3

# Add a delay so that the dock has time to initialize the removal
sleep 4

${dockutil} --add /Applications/Google\ Chrome.app /Users/$3
${dockutil} --add /Applications/Slack.app /Users/$3
${dockutil} --add /Applications/Zoom.us.app /Users/$3
${dockutil} --add /Applications/Safari.app /Users/$3
${dockutil} --add /Applications/Music.app /Users/$3
${dockutil} --add /Applications/Utilities/Self\ Service.app /Users/$3
${dockutil} --add '/Applications' --view list /Users/$3
${dockutil} --add '~/Downloads' --view list /Users/$3

# Add System Preferences, depending on OS version
os_ver=$(/usr/bin/sw_vers -productVersion)

if [[ "$os_ver" == 10.15.* ]]; then
	echo "Adding System Preferences for Catalina"
	${dockutil} --add /System/Applications/System\ Preferences.app /Users/$3
else [[ "$os_ver" == 10.14.* ]];
	echo "Adding System Preferences for Mojave or earlier"
	${dockutil} --add /Applications/System\ Preferences.app /Users/$3
fi
