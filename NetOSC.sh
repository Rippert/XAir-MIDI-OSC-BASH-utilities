#!/bin/bash

# NetOSC.sh
#  
#   This file is part of the XAir-MIDI-OSC-BASH-utilities.
#
#    XAir-MIDI-OSC-BASH-utilities is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    XAir-MIDI-OSC-BASH-utilities is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with XAir-MIDI-OSC-BASH-utilities.  If not, see <http://www.gnu.org/licenses/>.
#    
#    Copyright 2018 Ted Rippert
# 
#    Links a MIDI controller to an XAir mixer via OSC over a network connection
# 
#       Author: Ted Rippert

tmpfiles=()
proctree=()
pausetree=()
prgmlist=()
activeprgm=""

list_descendants ()
{
  local children=$(pgrep -P "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children"
}


function finish {
  rm -f $pipe $cpipe "${tmpfiles[@]}" /tmp/prgm.*.$$
#  kill $(list_descendants $$)
  pkill -P $todie
  pkill -P $$
  wait
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
    format=$8

    tmppipe=$(mktemp -u /tmp/cc2p.SS.XXXX)
	tmpfiles+=("$tmppipe")
	mkfifo $tmppipe
	receivemidi ts dev $mididevice channel $ccchannel control-change $ccnumber > $tmppipe &
	
	printf -v paramlow0 "%.4f" $paramlowerbound
	printf -v paramup0 "%.4f" $paramupperbound
	paramlowerbound="$((10#${paramlow0%.*}${paramlow0#*.}))"
	paramupperbound="$((10#${paramup0%.*}${paramup0#*.}))"
	paramlowerbound=${paramlowerbound%.*}
	paramupperbound=${paramupperbound%.*}
	ccspan=$(($ccupperbound-$cclowerbound))
	
	paramspan=$(($paramupperbound-$paramlowerbound))
	
	oldtime=0
	
	 while IFS=":. " read hr min sec msec ch chnum type typenum dat
	 do 
		   newtime="$((10#$msec+10#$sec*1000+10#$min*60000+10#$hr*3600000))"
		   if [ $dat -ge $cclowerbound -a $dat -le $ccupperbound ] && [ $(($newtime - $oldtime)) -ge 20 -o $newtime -lt $oldtime -o $dat -eq $cclowerbound -o $dat -eq $ccupperbound ]
		   then
			 param10k=$(($paramlowerbound + $paramspan * ($dat - $cclowerbound)/$ccspan))
			 printf -v param0k "%05d" $param10k
			 param=${param0k%????}.${param0k: -4}
			 echo "$oscpath $format $param" > $pipe
			 oldtime=$newtime
		   fi
	done < $tmppipe &
	}

function cc2toggle {
	ccchannel=$1
	ccnumber=$2
	onvalue=$3
	offvalue=$4
	oscpath=$5
	format=$6
	
	tmppipe=$(mktemp -u /tmp/cc2p.SS.XXXX)
	tmpfiles+=("$tmppipe")
	mkfifo $tmppipe
	receivemidi dev $mididevice channel $ccchannel control-change $ccnumber > $tmppipe &

	 while IFS=":. " read hr min sec msec ch chnum type typenum dat 
	 do 
		   if [ $dat -eq $onvalue ]
		   then
			 echo "$oscpath $format 1" > $pipe
		   elif [ $dat -eq $offvalue ]
		   then
			 echo "$oscpath $format 0" > $pipe 
		   fi
	done < $tmppipe &
}

function prgm {
	fn=$1
	pn=$(basename $fn)
	
	prgmpids="/tmp/prgm.$pn.$$"
    
    activeprgm=-1
    for i in ${!proctree[@]} ; do
		prgmlist=($((i+1)) ${proctree[i]} ${pausetree[i]})
		if [ "${prgmlist[1]}" = "prgm" -a "${prgmlist[2]}" = "$pn" ]
		then
			activeprgm="${prgmlist[0]}"
			break
		elif [ "${prgmlist[1]}" = "prgm" ]
		then
			prune "${prgmlist[0]}"
			rm "/tmp/prgm.${prgmlist[2]}.$$"
			break
		fi
	done
    if [ $activeprgm = -1 ]; then
    		tmpfiles+=("$prgmpids")
		while read -r pcmd
		do
			if [ "$pcmd" != "" ]; 
			then 
				$pcmd 
				echo -n "$(list_descendants $!) $!" >> "$prgmpids"			
			fi
		done < "$fn"
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
			tokill="$(list_descendants ${prnarray[0]}) ${prnarray[0]}"
			echo $tokill
			kill $tokill
			wait $tokill 2>/dev/null
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

pipe=/tmp/NetOSCpipe.$$
cpipe=/tmp/NetOSCcmd.$$

if [[ ! -p $pipe ]]; then
	mkfifo $pipe
fi

if [[ ! -p $cpipe ]]; then
	mkfifo $cpipe
fi

xairip=$1               # ipv4 address of XAir mixer
mididevice=$2

XAir_Interface -i $xairip -v 0 -t 0 -f $pipe <> $pipe &

if [ $# -gt 2 ]
  then
	shift 2
	"$@"
cmdarray=( "$@" )
case ${cmdarray[0]} in
  	list|prune|pause|resume)
  		;;
  	prgm)
  		exists=0
  		for i in ${!proctree[@]} ; do
  		if [ "${proctree[i]}" = "${cmdarray[0]} $pn" ]; then exists=1; fi
  		done
  		if [ $exists = 0 ]; then
  			proctree+=( "${cmdarray[0]} $pn" )
  			pausetree+=( " " )
  		fi
  		;;
  	*)
  		proctree+=( "$! $cmd" )
  		pausetree+=( " " )
  		;;
  esac
fi
	
HISTFILE=~/.NetOSC_hist
HISTFILESIZE=200
history -r

while IFS= read -r cmd 
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
  		if [ "${proctree[i]}" = "${cmdarray[0]} $pn" ]; then exists=1; fi
  		done
  		if [ $exists = 0 ]; then
  			proctree+=( "${cmdarray[0]} $pn" )
  			pausetree+=( " " )
  		fi
  		;;
  	*)
  		proctree+=( "$! $cmd" )
  		pausetree+=( " " )
  		;;
  esac
  
done <> $cpipe &

todie=$!

while IFS= read -e -r cmd 
do 
	if [ "$cmd" = "exit" ] || [ "$cmd" = "quit" ]
	then 
		break
	fi
	echo $cmd > $cpipe
done


exit 0