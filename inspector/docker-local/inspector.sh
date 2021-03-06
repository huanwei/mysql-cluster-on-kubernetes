#!/bin/bash

message="Please run 'set global max_allowed_packet=1073741824;' on 150.223.23.21"

function sendMessageToDingding(){
    curl 'https://oapi.dingtalk.com/robot/send?access_token=67cbf102552257c0cd45a10855589048a83cb012077a3e13a4f4a7fefc6ef4eb' \
            -H 'Content-Type: application/json' \
            -d "
           {\"msgtype\": \"text\",
             \"text\": {
                 \"content\": \"MySQL告警:$message\"
              }
           }"
    #echo $res
}

function check(){
    mysqladmin --protocol tcp -h192.168.31.95 -uroot -p123456 variables|grep max_allowed_packet |awk '{print $4}'|sed -n 1p
    #mysqladmin --protocol tcp -h150.223.23.21 -uroot -p123456 variables|grep max_allowed_packet |awk '{print $4}'|sed -n 1p
}

function fix(){
    mysql -h 192.168.31.95 -P 3306 -u root -p123456 <<EOF
    set global max_allowed_packet=1073741824;
EOF
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
            #echo 'Current minute is '$currentMinutes''
            echo 'Program running...'
            max_allowed_packet=$(check)
            if [ $max_allowed_packet -ne 1073741824 ]
            then
                echo "$(date "+%Y%m%d%H%M") max_allowed_packet is $max_allowed_packet"
                echo "$(date "+%Y%m%d%H%M") max_allowed_packet is $max_allowed_packet" >> /tmp/inspector.log
                echo $message
                #sendMessageToDingding $message
                fix
                echo "$(date "+%Y%m%d%H%M") fixed max_allowed_packet is $(check)"
                echo "$(date "+%Y%m%d%H%M") fixed max_allowed_packet is $(check)" >> /tmp/inspector.log
                #sendMessageToDingding "$(date "+%Y%m%d%H%M") fixed max_allowed_packet is $(check)"
                echo 'Program stopped...'
                onceFlag=1
            fi
        fi
    else
        onceFlag=0
    fi

    sleep 10
done