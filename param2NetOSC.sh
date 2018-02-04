#!/bin/bash


pipe=/tmp/cc2parampipe.$$
pipeo=/tmp/cc2outpipe.$$

function finish {
 rm -f $pipe
 rm -f $pipeo
  pkill -P $$
}

trap finish EXIT

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi
if [[ ! -p $pipeo ]]; then
    mkfifo $pipeo
fi

#function finish {
#    pkill -P $$
#}

trap finish EXIT

mididev=$1
xairip=$2


XR18_Command -i $xairip -v 0 -t 0 -f $pipe <> $pipe &
echo "xremote on" | XR18_Command -i $xairip -v 1 > $pipeo &


/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.6667 1.0 "/ch/11/eq/1/g ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.5 0.0 "/ch/14/eq/4/g ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.55 0.1 "/ch/11/mix/02/level ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.55 0.8 "/ch/11/mix/01/level ,f" $pipe &
#/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.0 0.75 "/ch/13/mix/02/level ,f" $pipe &
#/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.75 0.0 "/ch/13/mix/01/level ,f" $pipe &
#/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.375 0.333 "/ch/14/dyn/mgain ,f" $pipe &
#/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.669 0.563 "/ch/13/gate/thr ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.55 0.1 "/ch/14/mix/01/level ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.55 0.6 "/ch/14/mix/02/level ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.7 1.0 "/fx/4/par/05 ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 101 0.5 0.1 "/fx/4/par/06 ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 50 127 0.4 1.0 "/fx/4/par/01 ,f" $pipe &
/Users/tedrippert/XAirUtil/cc2param.a.4 $mididev $xairip 1 28 102 127 0.1 0.25 "/fx/4/par/06 ,f" $pipe &


  while read -a data
    do 
      echo "loop"
      len=${#data[@]}
      echo "$len" 
      echo "${data[*]}";  
    done < "$pipeo"
