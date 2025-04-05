#!/bin/sh

if [ -z "$AWSIP" ]; then
    echo "AWSIP is not set"
    exit 1
fi

if [ -z "$AWSPORT" ]; then
    echo "AWSPORT is not set"
    exit 1
fi

topic=$1

# split topic into final /
last=$(echo $topic | rev | cut -d'/' -f1 | rev)
echo $last
export ${last}=$(mosquitto_sub -h $AWSIP -p $AWSPORT -t $topic -C 1)
echo ${last}
