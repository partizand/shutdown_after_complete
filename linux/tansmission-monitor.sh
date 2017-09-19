#!/bin/bash

# Monitor for powernap
# create proccess in memory while transmission is downloading
# need transmission-remote

# auth if needed
auth="" #"--auth username:password"
sleep_delay = 60 
#-----------------------------------------------------

# lock status

me=`basename "$0"`


# is me already?
count_me=` ps ax | grep $me | wc -l`
if [ $count_me -gt 0 ]; then
	exit 1
fi 


# Transmission status
# Wait for downloading

while : ; do

	torrentlist="transmission-remote --list "$auth

	count=$($torrentlist | cut -c25-31 | sed -e '/^Done/ d; /^Unknown/ d; 1d; $d')
	if [ -z "$count" ]; then
		echo "No active downloads. Quit"
		exit 0
		
	fi
	
	sleep $sleep_delay

done

