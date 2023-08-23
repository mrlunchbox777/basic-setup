#! /usr/bin/env bash

device=$(network-my-default-network-device)
echo "$device" | xargs -I % sh -c "ip addr show | awk \"/%/ {print}\""
