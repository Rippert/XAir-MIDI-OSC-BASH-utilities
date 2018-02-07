#!/bin/bash



function finish {
  rm -f $pipe
  kill -- -$(ps -o pgid= $$ | grep -o '[0-9]*')
}

trap finish EXIT

function cc2param {
	mididevice=$1
	ccchannel=$2
	ccnumber=$3
	cclowerbound=$4
	ccupperbound=$5
	paramlowerbound=$6
	paramupperbound=$7
	xaircommand=$8
	pipe=$9
	
	
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
	   if [ $dat -ge $cclowerbound -a $dat -le $ccupperbound ] && [ $(($newtime - $oldtime)) -ge 40 -o $newtime -lt $oldtime -o $dat -eq $cclowerbound -o $dat -eq $ccupperbound ]
	   then
	     param10k=$(($paramlowerbound + $paramspan * ($dat - $cclowerbound)/$ccspan))
	     printf -v param0k "%05d" $param10k
	     param=${param0k%????}.${param0k: -4}
	     a="$xaircommand $param"
	     b=$(
	     	for ((i=0;i<${#a};i++));do printf "%02X " \'"${a:$i:1}";
	     	done
	     	)
	     echo "hex raw F0 00 20 32 32 $b F7" > $pipe 
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
	 while read ch chnum type typenum dat 
	 do 
	   if [ $dat -eq $onvalue ]
	   then
	    a="$xaircommand ON"
	     b=$(
	     	for ((i=0;i<${#a};i++));do printf "%02X " \'"${a:$i:1}";
	     	done
	     	)
	     echo "hex raw F0 00 20 32 32 $b F7" > $pipe
	   elif [ $dat -eq $offvalue ]
	   	then
	     a="$xaircommand OFF"
	     b=$(
	     	for ((i=0;i<${#a};i++));do printf "%02X " \'"${a:$i:1}";
	     	done
	     	)
	     echo "hex raw F0 00 20 32 32 $b F7" > $pipe
	   fi
	 done
}

function prgm {
	fn=$1
	pipe=$2
	while read -r cmd
	do
		if [ "$cmd" != "" ]; 
		then 
			bash -c "$0 child $cmd $pipe &" 
		fi
	done < "$fn"
}


if [ $1 = "child" ]; 
then
	trap - EXIT
	shift
	"$@"
else
	pipe=/tmp/cc2midioscpipe.$$
	
	if [[ ! -p $pipe ]]; then
	    mkfifo $pipe
	fi
	
	
	mididevout=$1              # midi device for sysex OSC output
	
	
	sendmidi -- dev $mididevout <> $pipe &

	if [ $# -gt 1 ]
	  then
	    shift
	    $@ $pipe
	fi
		
	HISTFILE=~/.MidiOSC_hist
	HISTFILESIZE=200
	history -r
	while IFS= read -e -r cmd 
	do
		if [ "$cmd" = "exit" ] || [ "$cmd" = "quit" ]
  		then 
    			break
  		fi
	  [ -n "$cmd" ] && history -s "$cmd"
	  [ -n "$cmd" ] && history -w
	  bash -c "$0 child $cmd $pipe &"
	done
fi

finish

exit 0
