#!/bin/sh
#
# Modified by Jeff Vandehey 8/14/18
#
#
# Purpose: This script uses Adobe RUM to update a single component to CC.
# In this instance, it's updating Acrobat Pro
#
#

rumlog=/var/tmp/RUMupdate.log
rum=/usr/local/bin/RemoteUpdateManager
jamf_bin=/usr/local/bin/jamf

# Installer function
installUpdates ()
{
    # Let's caffinate the mac because this can take long
    caffeinate -d -i -m -u &
    caffeinatepid=$!

    # do all of your work here
    $rum --action=install --productVersions=APRO

    # Kill Caffienate
    kill "$caffeinatepid"

    exit 0
}


#############
#  Script   #
#############

# new/current RUM installed?
if [ ! -f $rum ] ; then
	echo "Installing RUM from JSS"
	$jamf_bin policy -event RUM_Install
	if [ ! -f $rum ] ; then
		echo "Couldn't install RUM! Exiting."
		exit 1
	fi
fi

# Remove the old log file if it exists
if [ -f $rumlog ] ; then
    rm $rumlog
fi

# Run the list output from RUM, and throw it in the log
touch $rumlog
$rum --action=list --productVersions=APRO > $rumlog

if [ "$(grep "updates are applicable on the system" $rumlog)" ] ; then
        installUpdates
else
    echo "No applicable Acrobat updates were found"
fi
