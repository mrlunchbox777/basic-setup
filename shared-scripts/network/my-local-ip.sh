#! /usr/bin/env bash

device=$(network-my-default-network-device)
echo "$device" | xargs -I % sh -c "ip addr show | awk \"/%/ {print}\" | tr \" \" \"\\\n\" | awk '/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)|(([a-f0-9:]+:+)+[a-f0-9]+)/ {print;exit}' | xargs echo %"
