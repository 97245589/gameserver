localip=`ifconfig | grep inet | head -1 | awk '{print $2}'`
export IP="0.0.0.0"

./skynet/skynet ./server_config/config.$1