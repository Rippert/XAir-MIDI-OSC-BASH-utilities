#!/bin/bash

#pipe=/tmp/cc2parampipe.$$

function finish {
 # rm -f $pipe
  pkill -P $$
}

trap finish EXIT

#if [[ ! -p $pipe ]]; then
#    mkfifo $pipe
#fi

mididevice=$1
xairip=$2
ccchannel=$3
ccnumber=$4
cclowerbound=$5
ccupperbound=$6
paramlowerbound=$7
paramupperbound=$8
xaircommand=$9
pipe=${10}
#echo $pipe

printf -v paramlow0 "%.4f" $paramlowerbound
printf -v paramup0 "%.4f" $paramupperbound
paramlowerbound="$((10#${paramlow0%.*}${paramlow0#*.}))"
paramupperbound="$((10#${paramup0%.*}${paramup0#*.}))"
#paramlowerbound=`echo "scale=1;$paramlowerbound*10000" | bc`
#paramupperbound=`echo "scale=1;$paramupperbound*10000" | bc`
paramlowerbound=${paramlowerbound%.*}
paramupperbound=${paramupperbound%.*}
ccspan=$(($ccupperbound-$cclowerbound))

paramspan=$(($paramupperbound-$paramlowerbound))
#echo "$paramlowerbound $paramupperbound $paramspan"

#XR18_Command -i $xairip -v 0 -t 0 -f $pipe  <> $pipe &
oldtime=0

receivemidi ts dev $mididevice channel $ccchannel control-change $ccnumber | 
 while IFS=":. " read hr min sec msec ch chnum type typenum dat 
 do 
   newtime="$((10#$msec+10#$sec*1000+10#$min*60000+10#$hr*3600000))"
   if [ $dat -ge $cclowerbound -a $dat -le $ccupperbound ] && [ $(($newtime - $oldtime)) -ge 20 -o $newtime -lt $oldtime -o $dat -eq $cclowerbound -o $dat -eq $ccupperbound ]
   then
     param10k=$(($paramlowerbound + $paramspan * ($dat - $cclowerbound)/$ccspan))
     printf -v param0k "%05d" $param10k
     param=${param0k%????}.${param0k: -4}
     echo "$xaircommand $param" > $pipe
     #echo "$xaircommand $param"
     oldtime=$newtime
   fi
 done
