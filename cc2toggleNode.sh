#!/bin/bash

function finish {
  pkill -P $$
}

trap finish EXIT

mididevice=$1
xairip=$2
ccchannel=$3
ccnumber=$4
onvalue=$5
offvalue=$6
xaircommand=$7
pipe=$8

XR18_Command -i $xairip <> $pipe &

receivemidi dev $mididevice channel $ccchannel control-change $ccnumber | 
 while read ch chnum type typenum dat 
 do 
   if [ $dat -eq $onvalue ]
   then
    a="$xaircommand ON"
     b=$(for ((i=0;i<${#a};i++));do printf "%02X " \'"${a:$i:1}";done)
     echo "hex raw F0 00 20 32 32 $b F7" > $pipe
   else if [ $dat -eq $offvalue ]
     a="$xaircommand OFF"
     b=$(for ((i=0;i<${#a};i++));do printf "%02X " \'"${a:$i:1}";done)
     echo "hex raw F0 00 20 32 32 $b F7" > $pipe
   fi
 done
