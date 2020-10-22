#!/bin/bash
#
# Jeff Vandehey 2/28/20
# 
# Yo is a simple application that posts notifications via the built in apple notification center. 
# This script will check to see if Yo is installed. If Yo is found, it will send a message to the end user. 
# If Yo is not found, it will install it

YoApp='/Applications/Utilities/yo.app/Contents/MacOS/yo'

## Check to see if Yo is installed already

	if [ ! -f $YoApp ]; then
  	  echo "Yo is not installed. Installing it....."
  	  /usr/local/bin/jamf policy -trigger InstallYo
	fi
		
## Path to the script to run
scriptRunDir="/private/var/scripts/"

## Create the directory to house the script if not present
if [ ! -d "$scriptRunDir" ]; then
    mkdir -p "$scriptRunDir"
fi
	
## Get Logged in User name
loggedInUser=$(stat -f%Su /dev/console)

## Get Logged in User UID
loggedInUID=$(id -u "$loggedInUser")

## Make sure someone is logged in or no message display is possible
if [[ "$loggedInUser" == "root" ]] && [[ "$loggedInUID" == 0 ]]; then
    echo "No user is logged in. Skipping display of notification until next run."
    exit 0
fi

cat << EOD > /private/var/scripts/Yo_run.sh
#!/bin/bash

/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Update Required" -s "Your OS is out of date" -b "Open Updater" -o "Remind Me Later" -a "macappstore://itunes.apple.com/us/app/macos-catalina/id1466841314?ls=1&mt=12" -n "$(echo -ne '\xe2\x9d\xa4\xef\xb8\x8f') IT"

EOD

## Make the newly created script executable
/bin/chmod +x /private/var/scripts/Yo_run.sh
	

/bin/launchctl asuser "$loggedInUID" /private/var/scripts/Yo_run.sh
	
	
## Display a short message to the end user, with hyperlinks to launch Apple's SoftwareUpdate mechanism

#/Applications/Utilities/yo.app/Contents/MacOS/yo -t "Update Required" -s "Your OS is out of date" -b "Open Updater" -o "Remind Me Later" -a "macappstore://itunes.apple.com/us/app/macos-catalina/id1466841314?ls=1&mt=12" -n "$(echo -ne '\xe2\x9d\xa4\xef\xb8\x8f') IT"
