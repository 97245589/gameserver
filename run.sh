#!/bin/bash

export DAEMON=false
export PARAM="test"
export PRIIP=`ip route get 1 | awk '{print $7}'`

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

./skynet/skynet ./run/config/$SERVER