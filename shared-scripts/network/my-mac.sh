#! /usr/bin/env bash

network-my-default-network-device | xargs -I % sh -c "cat /sys/class/net/%/address | sed -E ':a;N;\$!ba;s/\r{0,1}\n/\n/g' | xargs echo %"
