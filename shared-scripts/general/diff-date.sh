#! /usr/bin/env bash

# TODO: support more than just iso dates

date1=$(date +%s -d $1)
date2=$(date +%s -d $2)
DIFF=$(( $date1-$date2 ))
echo $DIFF
