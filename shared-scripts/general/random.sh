#! /usr/bin/env bash

tempminvar=$1
if [ -z "$tempminvar" ]; then
  tempminvar=0
fi
tempmaxvar=$2
if [ -z "$tempmaxvar" ]; then
  tempmaxvar=10
fi
tempmaxvar=$(($tempmaxvar-$tempminvar+1))
randomvalvar=$((RANDOM))
echo $(($tempminvar + ($randomvalvar % $tempmaxvar)))
