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

#XR18_Command -i $xairip <> $pipe &

receivemidi dev $mididevice channel $ccchannel control-change $ccnumber | 
 while read ch chnum mes typenum dat 
 do 
   if [ $dat -eq $onvalue ]
   then
     echo "$xaircommand 1" > $pipe
   elif [ $dat -eq $offvalue ]
   then
     echo "$xaircommand 0" > $pipe 
   fi
 done
