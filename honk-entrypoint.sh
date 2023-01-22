#!/bin/ash

if [ -z ${HONK_USERNAME+x} ] && [ -z ${HONK_PASSWORD+x} ] && [ -z ${HONK_LISTEN_ADDRESS+x} ] && [ -z ${HONK_SERVER_NAME+x} ];
then 
    echo "Environment variables are not set, please see README.md"
    exit 1
fi

# check if we have a config, if not, create one based on ENV
if [ ! -f /config/honk.db ]
then
    ./honk-init.exp
fi

# handle difference cases
# run is set in Dockerfile; CMD
if [ "$1" == "run" ]
then
    ./honk -datadir /config/
elif [ "$1" == "upgrade" ]
then
    ./honk -datadir /config/ upgrade
elif [ "$1" == "backup" ]
then
    ./honk -datadir /config/ backup /config/$(date +backup-%F)
fi
