#!/bin/bash


pipe=/tmp/cc2midioscpipe.$$

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
mididevout=$2           # midi device name for sysex-OSC output


sendmidi -- dev $mididevout <> $pipe &

./cc2node.sh $mididev $mididevout <midi channel> <CC#> <CCmin> <CCmax> <parammin> <parammax> "<node formatted path>" $pipe &
# multiple calls to cc2node.sh with different paramters can be placed here

wait
