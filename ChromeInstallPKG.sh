#!/bin/zsh

# Installs Google Chrome from a drag an drop .dmg file
#
# J. Vandehey 5/20/20
#
####################################################################################################
#
# Google Chrome Installation Script
#
####################################################################################################
#
# DESCRIPTION
#
# Automatically download and install Google Chrome
#

packageName="GoogleChrome.pkg"

processName="Google Chrome"

tmpDir=$(mktemp -d )

expectedTeamID="EQHXZ8M8AV"

chromeURL="https://dl.google.com/chrome/mac/stable/gcem/GoogleChrome.pkg"

# Download vendor supplied DMG file into /tmp/
curl --location "$chromeURL" -o "$tmpDir/$packageName"

#Path for debugging
#echo "$tmpDir/$VendorDMG"

# Test the newly downloaded app with GateKeeper to ensure that it is signed and notarized.
# verify with spctl
echo "Verifying: $processName"
if ! teamID=$(spctl -a -vv -t install "$tmpDir/$packageName" 2>&1 | awk '/origin=/ {print $NF }' | tr -d '()' ); then
echo "GateKeeper verification has failed.....Exiting"
exit 1
fi

echo "Team ID: $teamID (expected: $expectedTeamID )"
if [ "$expectedTeamID" != "$teamID" ]; then
echo "Gatekeeper verification has failed......Exiting"
exit 1
fi

echo "Team ID matches spctl output"

# If the app is running, kill it
if pgrep -xq "$processName"; then
echo "$processName is running. Killing the process"
pkill $processName
else
echo "$processName is not running. Proceed w/ the install"
fi

# Install the app into to /Applications/
installer -pkg "$tmpDir/$packageName" -tgt /Applications

# Remove the downloaded vendor supplied DMG file
rm -f $tmpDir/$packageName&
