#!/bin/bash

message="Please run 'set global max_allowed_packet=1073741824;' on 150.223.23.21"

function sendMessageToDingding(){
    echo $message
}


sendMessageToDingding $message

message="fixed"

sendMessageToDingding $message

message="Please run 'set global max_allowed_packet=1073741824;' on 150.223.23.21"

sendMessageToDingding $message
