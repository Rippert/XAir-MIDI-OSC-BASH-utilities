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

mididev=$1
mididevout=$2


sendmidi -- dev $mididevout <> $pipe &

../cc2node.sh $mididev $mididevout 1 28 50 127 7 10 "/fx/4/par/05" $pipe &
../cc2node.sh $mididev $mididevout 1 28 50 101 5 1 "/fx/4/par/06" $pipe &
../cc2node.sh $mididev $mididevout 1 28 50 127 4 10 "/fx/4/par/01" $pipe &
../cc2node.sh $mididev $mididevout 1 28 102 127 1 2.5 "/fx/4/par/06" $pipe &
../cc2toggleNode.sh $mididev $mididevout 2 17 0 127 "/ch/11/insert/on" $pipe &

wait
