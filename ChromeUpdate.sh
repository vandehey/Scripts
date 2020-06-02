#!/bin/zsh

# Updates Chrome when it is already installed
#
# J. Vandehey 6/2/20
#
####################################################################################################
#
# Google Chrome Update Script
#
####################################################################################################
#
# DESCRIPTION
#
# Use Chrome's built-in updater to update the app
#

# Get the username of the user that is currently logged in
CURRENTUSER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

UpdateCommand="/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Resources/GoogleSoftwareUpdateAgent.app/Contents/MacOS/GoogleSoftwareUpdateAgent"

CommandArguments="-runMode oneshot -userInitiated YES"

if [[ $currentUser != "loginwindow" ]]; then
	uid=$(id -u "$CURRENTUSER")
	launchctl asuser 501 sudo -u $CURRENTUSER "$UpdateCommand" ${updateToolArguments}
fi

