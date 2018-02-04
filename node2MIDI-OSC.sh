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

#function finish {
#    pkill -P $$
#}

trap finish EXIT

mididev=$1
mididevout=$2


sendmidi -- dev $mididevout <> $pipe &

/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh  $mididev $mididevout 1 28 50 127 3 15 "/ch/11/eq/1/g" $pipe &
/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 0 -15 "/ch/14/eq/4/g" $pipe &
#/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 -8 -50 "/ch/11/mix/02/level" $pipe &
#/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 -8 -3 "/ch/11/mix/01/level" $pipe &
#/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 -8 -50 "/ch/13/mix/02/level" $pipe &
#/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 -8 -3 "/ch/13/mix/01/level" $pipe &
#/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 -8 -50 "/ch/14/mix/01/level" $pipe &
#/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 -8 -6 "/ch/14/mix/02/level" $pipe &
/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 7 10 "/fx/4/par/05" $pipe &
/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 101 5 1 "/fx/4/par/06" $pipe &
/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 50 127 4 10 "/fx/4/par/01" $pipe &
/Users/tedrippert/XAirUtil/cc2midi-oscpipe.sh $mididev $mididevout 1 28 102 127 1 2.5 "/fx/4/par/06" $pipe &

wait
