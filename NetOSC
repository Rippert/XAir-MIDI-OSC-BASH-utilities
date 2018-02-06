#!/bin/bash


pipe=/tmp/cc2parampipe.$$

function finish {
  rm -f $pipe
  pkill -P $$
}

trap finish EXIT

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi

trap finish EXIT

mididev=$1              # midi device name for Continuous Controller (CC) input(s)
xairip=$2               # ipv4 address of XAir mixer

XR18_Command -i $xairip -v 0 -t 0 -f $pipe <> $pipe &

./cc2param.sh $mididev $xairip <midi channel> <CC#> <CCmin> <CCmax> <parammin> <parammax> "<OSC path and param format>" $pipe &
# multiple calls to cc2node.sh with different paramters can be placed here

wait
