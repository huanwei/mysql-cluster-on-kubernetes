#!/bin/bash

function check(){
    #mysqladmin --protocol tcp -h10.100.100.7 -uroot -p123456 variables|grep max_allowed_packet |awk '{print $4}'|sed -n 1p
    mysqladmin --protocol tcp -h150.223.23.21 -uroot -p123456 variables|grep max_allowed_packet |awk '{print $4}'|sed -n 1p
}

#once per 5min
onceFlag=0

echo 'Program waiting to run(once per 5min)...'

while true ; do
    currentMinutes=$(date "+%M")

    if [ `expr $currentMinutes % 5` -eq 0 ]
    then
        if [ $onceFlag -eq 0 ]
        then
            echo 'Current minute is '$currentMinutes''
            echo 'Program running...'
            echo "$(date "+%Y%m%d%H%M") max_allowed_packet is $(check)"
            echo "$(date "+%Y%m%d%H%M") max_allowed_packet is $(check)" >> /tmp/inspector.log
            echo 'Program stopped...'
            onceFlag=1
        else
            continue
        fi
    else
        onceFlag=0
    fi

    sleep 10
done