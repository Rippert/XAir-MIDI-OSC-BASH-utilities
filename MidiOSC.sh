#!/bin/bash



function finish {
  rm -f $pipe
  kill -- -$(ps -o pgid= $$ | grep -o '[0-9]*')
}

trap finish EXIT

function cc2param {
	ccchannel=$1
	ccnumber=$2
	cclowerbound=$3
	ccupperbound=$4
	paramlowerbound=$5
	paramupperbound=$6
	oscpath=$7
	
	
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
	     a="$oscpath $param"
	     b=$(
	     	for ((i=0;i<${#a};i++));do printf "%02X " \'"${a:$i:1}";
	     	done
	     	)
	     echo "hex raw F0 00 20 32 32 $b F7" > $pipe 
	     oldtime=$newtime
	   fi
	done &
}

function cc2toggle {
	ccchannel=$1
	ccnumber=$2
	onvalue=$3
	offvalue=$4
	oscpath=$5
		
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
	     a="$oscpath OFF"
	     b=$(
	     	for ((i=0;i<${#a};i++));do printf "%02X " \'"${a:$i:1}";
	     	done
	     	)
	     echo "hex raw F0 00 20 32 32 $b F7" > $pipe
	   fi
	done &
}

function prgm {
	fn=$1
	
	prgmpids="/tmp/prgm.$fn.$$"
    tmpfiles+=("$prgmpids")
    
    activeprgm=-1
    for i in ${!proctree[@]} ; do
		prgmlist=($((i+1)) ${proctree[i]} ${pausetree[i]})
		if [ "${prgmlist[1]}" = "prgm" -a "${prgmlist[2]}" = "$fn" ]
		then
			activeprgm="${prgmlist[0]}"
		elif [ "${prgmlist[1]}" = "prgm" ]
		then
			pause "${prgmlist[0]}"
		fi
	done
    if [ $activeprgm = -1 ]; then
		while read -r pcmd
		do
			if [ "$pcmd" != "" ]; 
			then 
				$pcmd 
				echo -n "$! " >> "$prgmpids"			
			fi
		done < "$fn"
	else
		resume $activeprgm
	fi
}
	
function list {
	echo "Number of commands running: ${#proctree[@]} "
	echo "A \"P\" in the second column indicates command is paused."
	for i in ${!proctree[@]} ; do
		echo "$((i+1)) ${pausetree[i]} ${proctree[i]}"
	done
}

function prune {
	while [ $# -ge 1 ]
	do
		prnarray=( ${proctree[(($1-1))]} )
		case ${prnarray[0]} in
		prgm)
			kill $(cat "/tmp/prgm.${prnarray[1]}.$$")
			wait $(cat "/tmp/prgm.${prnarray[1]}.$$") 2>/dev/null
			unset 'proctree[(($1-1))]' 'pausetree[(($1-1))]'
			;;
		*)
			kill "${prnarray[0]}"
			wait "${prnarray[0]}" 2>/dev/null
			unset 'proctree[(($1-1))]' 'pausetree[(($1-1))]'
			;;
		esac
		shift
	done
}

function pause {
	while [ $# -ge 1 ]
	do
		prnarray=( ${proctree[(($1-1))]} )
		case ${prnarray[0]} in
		prgm)
			kill -STOP $(cat "/tmp/prgm.${prnarray[1]}.$$")
			pausetree[(($1-1))]="P"
			;;
		*)
			kill -STOP "${prnarray[0]}"
			pausetree[(($1-1))]="P"
			;;
		esac
		shift
	done
}

function resume {
	while [ $# -ge 1 ]
	do
		prnarray=( ${proctree[(($1-1))]} )
		case ${prnarray[0]} in
		prgm)
			kill -CONT $(cat "/tmp/prgm.${prnarray[1]}.$$")
			pausetree[(($1-1))]=" "
			;;
		*)
			kill -CONT "${prnarray[0]}"
			pausetree[(($1-1))]=" "
			;;
		esac
		shift
	done
}

pipe=/tmp/MidiOSCpipe.$$

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi

mididevice=$1
mididevout=$2              # midi device for sysex OSC output


sendmidi -- dev $mididevout <> $pipe &

if [ $# -gt 2 ]
  then
	shift 2
	"$@"
	proctree+=( "$! $cmd" )
	pausetree+=( " " )
fi
	
HISTFILE=~/.NetOSC_hist
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
  $cmd
  cmdarray=( $cmd )
  case ${cmdarray[0]} in
  	list|prune|pause|resume)
  		;;
  	prgm)
  		exists=0
  		for i in ${!proctree[@]} ; do
  			if [ "${proctree[i]}" = "$cmd" ]; then exists=1; fi
  		done
  		if [ $exists = 0 ]; then
  			proctree+=( "$cmd" )
  			pausetree+=( " " )
  		fi
  		;;
  	*)
  		proctree+=( "$! $cmd" )
  		pausetree+=( " " )
  		;;
  esac
  
done


exit 0
