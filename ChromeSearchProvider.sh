#!/bin/zsh

# Installs Google Chrome from a drag an drop .dmg file
#
# J. Vandehey 5/20/19
#
####################################################################################################
#
# Chrome Search Provider
#
####################################################################################################
#
# DESCRIPTION
#
# Quits Chrome, uses sqlite3 to create a new search provider, then launches Chrome
#

## Nab the current user
CURRENTUSER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

## Check to see if Chrome is running....If so, kill it (the user has been warned)

if pgrep -x "Google Chrome" ; then

/usr/bin/killall "Google Chrome"

sleep 2

fi

/usr/bin/sqlite3 "/Users/$CURRENTUSER/Library/Application Support/Google/Chrome/Default/Web Data" "INSERT INTO keywords VALUES(57,'Title','SearchTrigger','https://faviconURL.com/images/favicon.ico','https://searchsource.net/index.html?q={searchTerms}',0,'',13186107241098619,0,'','',0,0,13186107241098619,'a47a7305-9bb7-423d-a25c-7bd908b4e3af','[]','','','','','',0);"

open /Applications/"Google Chrome.app"

exit
