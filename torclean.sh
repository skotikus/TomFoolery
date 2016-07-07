#!/bin/bash

# Sript by: Scott Forsyth
# Date Last Modified: 11/15/2015

# Video File type conversion script
# Automatically runs on MKV files to convert to MP4 so they can be played universally. Then Deletes the MKV version.

# Sets the present dir as the working dir
dest=$(pwd);

# Finds and moves all movie files
find . -depth +1 -type f \( -name "*.mkv" -or -name "*.avi" -or -name "*.mp4" \) -exec mv {} $dest \;

wait ${!}

#Move all directories and whats left in them

# Removes blank spaces from Direcotrie names
find . -type d -name "* *" -exec rename "s/\s/_/g" {} \;
# Reomves directories
for b in $(ls -d */); do rm -R $b; done;
# Removes all files with the word sample in them
for s in $(ls | grep -i -e *sample* -e *DS_Store*); do rm -R $s; done;

echo " ----- CONSOLIDATION DONE ------ ";

exit;