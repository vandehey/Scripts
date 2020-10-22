#!/bin/zsh
#
# Jeff Vandehey 2/28/20
#
# Use JAMF helper to display a message to the end user regarding some pending updates

# Get the username of the user that is currently logged in, and extract the firstname
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
firstName=`finger $loggedInUser | egrep -o 'Name: [a-zA-Z0-9 ]{1,}' | cut -d ':' -f 2 | xargs echo | /usr/bin/awk '{ print $1 }'`
uid=$(id -u "$loggedInUser")

# Exit if the machine is at the login window, to prevent a hang
currentUser=$(stat -f %Su "/dev/console")

if [[ "$currentUser" == "root" ]]; then
echo "Machine is at the login window. Exiting"
exit
fi

# Some basic definitions
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
heading="macOS Update is Required"
icon="/Library/Application Support/JAMF/yourco/YourcoLogo.png"
message="""Greetings $firstName:
There is a critical update required for macOS.  Please click on the "OK" button to continue, which will open the built-in Software Updater for your system.
You may click "Later" to delay this update, and you will be reminded to run this at a later time.
$(echo -ne '\xe2\x9d\xa4\xef\xb8\x8f') I.T.
"""

## Check to see if the logo is installed already

	if [ ! -f $icon ]; then
  	  echo "Logo is not installed. Installing it....."
  	  /usr/local/bin/jamf policy -trigger logo
	fi
    
# watchdog process
# This will kill the notificaiton window after 3 hours, so it does not hang up JAMF policy if the user does not interact
mainpid=$$
(sleep 10800; kill $mainpid) &
watchdogpid=$!

# Build the helper window display

button=$($jamfHelper -windowType utility -title "Company Software Update" -button1 OK -button2 "Later" -description $message -heading "$heading" -icon $icon &)

kill $watchdogpid

if [[ $button == "0" ]]; then
   launchctl asuser $uid open -n "/System/Library/CoreServices/Software Update.app"
fi
