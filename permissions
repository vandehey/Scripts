set this_folder to (choose folder with prompt "Pick the folder containing the files to process:") as string
tell application "System Events"
	set these_files to every file of folder this_folder
end tell
set DIR to quoted form of the POSIX path of this_folder
do shell script "/bin/tcsh -c 'chmod  775 '" & quoted form of DIR
--Find any sub-directories, and set them to 775 (watching out for spaces)
do shell script "find " & DIR & " -type d -print0 | xargs -0 chmod 775"
--Find all files recursively, and set them to 644
do shell script "find " & DIR & " -type f -print0 | xargs -0 chmod 644"
