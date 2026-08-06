#!/bin/bash

export DAEMON=false
export PARAM="test"

while getopts "ds:p:" arg
do
	case $arg in
		d)
			export DAEMON=true
			;;
		p)
			export PARAM=$OPTARG
			;;
	 	s)
            SERVER=$OPTARG
            ;;
	esac
done

echo "$SERVER"
echo "$PARAM"
./skynet/skynet ./run/config/$SERVER