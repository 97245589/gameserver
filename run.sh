#!/bin/bash

export DAEMON=false

while getopts "ds:" arg
do
	case $arg in
	 	s)
            SERVER=$OPTARG
            ;;
		d)
			export DAEMON=true
			;;
	esac
done

./skynet/skynet ./run/config/$SERVER