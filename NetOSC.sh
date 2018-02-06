#!/bin/bash


function finish {
  rm -f $pipe
  pkill -P $$
}

trap finish EXIT

function cc2param {
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
	
	printf -v paramlow0 "%.4f" $paramlowerbound
	printf -v paramup0 "%.4f" $paramupperbound
	paramlowerbound="$((10#${paramlow0%.*}${paramlow0#*.}))"
	paramupperbound="$((10#${paramup0%.*}${paramup0#*.}))"
	paramlowerbound=${paramlowerbound%.*}
	paramupperbound=${paramupperbound%.*}
	ccspan=$(($ccupperbound-$cclowerbound))
	
	paramspan=$(($paramupperbound-$paramlowerbound))
	
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
	     oldtime=$newtime
	   fi
	 done
}

function cc2toggle {
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
}


pipe=/tmp/cc2parampipe.$$

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi

mididev=$1              # midi device name for Continuous Controller (CC) input(s)
xairip=$2               # ipv4 address of XAir mixer

XR18_Command -i $xairip -v 0 -t 0 -f $pipe <> $pipe &

./cc2param.sh $mididev $xairip <midi channel> <CC#> <CCmin> <CCmax> <parammin> <parammax> "<OSC path and param format>" $pipe &
# multiple calls to cc2node.sh with different paramters can be placed here

wait
