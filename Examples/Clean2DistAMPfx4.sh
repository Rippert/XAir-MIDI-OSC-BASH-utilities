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

mididev=$1
xairip=$2

XR18_Command -i $xairip -v 0 -t 0 -f $pipe <> $pipe &

../cc2param.sh $mididev $xairip 1 28 50 127 0.7 1.0 "/fx/4/par/05 ,f" $pipe &
../cc2param.sh $mididev $xairip 1 28 50 101 0.5 0.1 "/fx/4/par/06 ,f" $pipe &
../cc2param.sh $mididev $xairip 1 28 50 127 0.4 1.0 "/fx/4/par/01 ,f" $pipe &
../cc2param.sh $mididev $xairip 1 28 102 127 0.1 0.25 "/fx/4/par/06 ,f" $pipe &

wait
