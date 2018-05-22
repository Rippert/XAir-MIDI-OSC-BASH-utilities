# XAir MIDI OSC BASH utilities
These utilities allow one to utilize a MIDI controller to change parameter settings on the XAir series of mixers.

All software in this repository is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

This Repository contains BASH shell scripts which utilize the command line programs XAir_Interface, sendmidi and receivemidi available at:

https://github.com/Rippert/XAir-Behringer.git

https://github.com/gbevin/SendMIDI.git and https://github.com/gbevin/ReceiveMIDI.git

XAir_Interface, sendmidi and receivemidi executables should be placed in the users PATH.

### Version 0.2
The multiple scripts of version 0.1 have been replaced by two scipts (*NetOSC.sh* and *MidiOSC.sh*). Version 0.1 scripts are still availble in the branch *archive*.

Examples of `prgm` (see below) files are provided in *OSClist1,2,3* for *NetOSC.sh*, and *MOSClist1,2* for *MidiOSC.sh*.

### NetOSC.sh 
**NetOSC.sh**   <u>OSC-server-IPv4-address</u>   <u>OSC-server-Port</u>   <u>MIDI-device-name</u>   [command]

Reads MIDI command input on <u>MIDI-device-name</u> and send OSC commands to OSC server (such as a XAir mixe)r at IP address <u>OSC-server-IPv4-address</u> on port <u>OSC-server-Port</u>. An optional command input can be appended to the command line. Other commands are added interactively.

Once `NetOSC.sh` is invoked, commands are entered via the terminal. All commands remain active until deleted with a `prune` command or until another `prgm` command is entered in the case of `prgm` (see below). 

Currently accepted commands are:

**cc2param**   <u>MIDI-channel#</u>   <u>CC#</u>   <u>CC-lower#</u>   <u>CC-upper#</u>   <u>param-lower#</u>   <u>param-upper#</u>   <u>OSC-address</u>   <u>OSC-format</u>

setup a linear link between the MIDI continuous-controller <u>CC#</u> on MIDI channel <u>MIDI-channel#</u> and the OSC continuous parameter at <u>OSC-address</u>, with format <u>OSC-format</u>.

Example: `cc2param 1 10 0 127 0.0 1.0 /ch/01/mix/fader ,f` - sets up a link between MIDI ontinuous-controller 10 on MIDI channel 1, and the main fader on channel 1 of the XAir mixer. A ontinuous-controller value of 0 will yield a fader value of -oo dB, and a ontinuous-controller value of 127 will yield a fader value of +10 dB. Intermediate ontinuous-controller values will yield intermediate fader settings.

Generally used to tie a MIDI continuous-controller actuator (a foot pedal, knob, slider, etc) to a mixer parameter for realtime control with smooth, continous changes in values.

All continuous parameters on an XAir mixer take a float `,f` format and have a range of 0.0 to 1.0. String, `,s` and integer, `,i` formats are also possible but beyond the scope of this document.

**cc2toggle**   <u>MIDI-channel#</u>   <u>CC#</u>   <u>CC-ON#</u>   <u>CC-OFF#</u>   <u>OSC-address</u>   <u>OSC-format</u>

setup a one-to-one link between the MIDI continuous-controller <u>CC#</u> on MIDI channel <u>MIDI-channel#</u> and the OSC discrete (ON - OFF) parameter at <u>OSC-address</u>, with format <u>OSC-format</u>.

Example: `cc2toggle 2 18 0 127 /ch/11/insert/on ,i` - sets up a link between MIDI continuous-controller 18 on MIDI channel 2, and the FX insert switch on channel 11 of the XAir mixer. A continuous-controller value of 0 will turn ON the FX insert, and a continuous-controller value of 127 will turn OFF the FX insert.

Generally used to tie a MIDI continuous-controller switch (a button) to a mixer parameter for realtime control of ON-OFF state.

**cctapspeed**   <u>MIDI-channel#</u>   <u>CC#</u>   <u>MaxTime</u>    <u>OSC-address</u>   <u>OSC-format</u>   [multiplier]

**noteontapspeed**   <u>MIDI-channel#</u>   <u>Note#</u>   <u>MaxTime</u>    <u>OSC-address</u>   <u>OSC-format</u>   [multiplier]

**pchtapspeed**   <u>MIDI-channel#</u>   <u>PCH#</u>   <u>MaxTime</u>    <u>OSC-address</u>   <u>OSC-format</u>   [multiplier]

Send the reciprocal of the time between succesive taps (speed in Hz) on the given midi control to the speed parameter of a FX module. The <u>MaxTime</u> paramter sets the maximum tap interval (in milliseconds) that will be evaluated. The optional multiplier input allows the time interval to be multiplied by an integer to yield a slower speed for use when multi-measure cycle times of the effect are desired.

Tap controls can be a MIDI conintuous controller message, a NoteON message, or a program change message.

Notes: the MIDI CC version interprets any value of the given CC# as a tap. The NoteOn version only reads notes with a velocity value greater than 0 as a tap. Note values must be provided as a decimal integer between 1 and 127. The <u>OSC-format</u> parameter whould be ",s" in order to input the value in Hz. All single (stereo) FX modules have the speed parameter as the first parameter. Multi-module FX such as Delay-Chorus may have the speed parameter on a hogher number parameter (Delay-chorus has SPEED on parameter 7). The Rotary Speaker FX module has a low speed (parameter 1) and a high speed (parameter 2). This control can also be used with any other parameter that has units of Hz.

Example: `noteontapspeed 1 75 20000 /fx/2/par/07 ,s 2` - send the reciprocal of the interval (multiplied by 2)  between succesive NoteOn messages for Note 75 to the FX module in FX slot 2. Where paramter 7 of that module is the speed control (Delay-Chourus FX module).

**cctaptime**   <u>MIDI-channel#</u>   <u>CC#</u>   <u>MaxTime</u>    <u>OSC-address</u>   <u>OSC-format</u>   [divisor]

**noteontaptime**   <u>MIDI-channel#</u>   <u>Note#</u>   <u>MaxTime</u>    <u>OSC-address</u>   <u>OSC-format</u>   [divisor]

**pchtaptime**   <u>MIDI-channel#</u>   <u>PCH#</u>   <u>MaxTime</u>    <u>OSC-address</u>   <u>OSC-format</u>   [divisor]

Send the time between succesive taps (time in ms) on the given midi control to the speed parameter of a FX module. The <u>MaxTime</u> paramter sets the maximum tap interval (in milliseconds) that will be evaluated. The optional divisor input allows the time interval to be divided by an integer to yield a smaller time interval for use when sub-measure repeat times of the effect are desired.

Tap controls can be a MIDI conintuous controller message, a NoteON message, or a program change message.

Notes: the MIDI CC version interprets any value of the given CC# as a tap. The NoteOn version only reads notes with a velocity value greater than 0 as a tap. Note values must be provided as a decimal integer between 1 and 127. The <u>OSC-format</u> parameter whould be ",s" in order to input the value in ms. All FX modules have the time parameter as the first parameter except the Stereo Delay which has time as parameter 2. The time parameter in the Fair compressor FX modules will not work with these controls. This control can also be used with any other parameter that has units of ms.

Example: `noteontaptime 1 75 3000 /fx/2/par/01 ,s 2` - send the time interval (divided by 2)  between succesive NoteOn messages for Note 75 to the FX module in FX slot 2.

**global**   <u>file</u>

Load a list of commands from a file on disk named <u>file</u> (use a full path if not in working directory). commands can be any valid coomand accepted by the script except **load** or **prgm**.

Multiple `global` commands can be loaded simultaneously. Global commands occupy a single line in the "list"

Example: `global OSClist1`

Loads all commands from the file *OSClist1*. The file is a plain text file with a list of commands (one command per line).

**prgm**   <u>file</u>

Load a list of commands from a file on disk named <u>file</u> (use a full path if not in working directory). Commands can be any valid coomand accepted by the script except **load** or **global**.

When multiple `prgm` commands are loaded, only the most recent one remains active. Thus loading `prgm OSClist1` will load all the commands from the file named *OSClist1* in the current directory. Loading `prgm OSClist2` will remove all *OSClist1* commands and load all *OSClist2* commands. Prgm commands occupy a single line in the "list"

Example: `prgm OSClist1`

Loads all commands from the file *OSClist1*. Unloads any other `prgm` files previously loaded. the file is a plain text file with a list of commands (one command per line).

**load**   <u>file</u>

Load a list of commands from a file on disk named <u>file</u> (use a full path if not in working directory). Commands can be any valid coomand accepted by the script.

Unlike the `global` or `prgm` commands, the `load` command loads each command from <u>file</u> individually, as if they had been typed into the command line seperately. Each line from the file loaded occpies a sepereate line in the "list" The `load` command does not unload any other commands.

Example: `load OSClist1`

Loads all commands from the file *OSClist1*. All commands from *OSClist1* are loaded seperately, and must be unloaded (via a `prune` command) individually.

**list**

List all running commands. Commands are preceeded by a number to be used for the `prune` command

**snapload** <u>snapshot#</u>

load snapshot number <u>snapshot#</u> on the XAir mixer.

**sendMIDI** <u>any-valid-sendmidi-command</u>

send an arbitrary MIDI command on interface <u>MIDI-device-name</u>.

Example: `sendMIDI ch 1 cc 2 3` - Send a Continous controller message of "3" on CC 2 over MIDI channel 1.

**sendOSC** <u>any-valid-OSC-command</u>

send an arbitrary OSC command to the server at <u>OSC-server-IPv4-address</u>.

Example: `sendOSC /ch/01/mix/fader ,f 0.5` - Set the Main fader of channel 1 on an XAIR mixer to it's midpoint.

**syscmd** <u>any-valid-shell-command</u>

run an arbitrary sytem shell command in a subshell.

Example: `syscmd ls -l` - lists the contents of the present working directory.

**pch2** <u>midichannel#</u>  <u>pch#</u>  <u>any-valid-command</u>

When a program change message,<u>pch#</u>, is recieved on MIDI channel <u>midichannel#</u>, execute the NetOSC.sh command <u>any-valid-command</u> as if it had been typed into the terminal. 

Example: `pch2 1 22 snapload 12` - When a program change #22 is recieved on MIDI channel 22, load snapshot 12 on the XAir mixer.

**setlist** <u>file1</u>  <u>file2</u>  <u>file3</u> ...

Create a set list from a space sepearated list of filenames. Only one setlist can be used at a time. Whenever the setlist command is invoked any previous detlist is deleted and replaced with the new list.

Example: `setlist OSClist1 OSClist2 OSClist3` - load OSClist1, OSClist2,and OSClist3 as a setlist.

**next**

Load the next setlist program file. Starts at the first entry in the list after each setlist command.

**previous**

Load the previous setlist program file. Loads the first entry in the setlist if invoked after a setlist command with no next command invoked in between.

**prune**   <u>command#</u>   [addition-space-seperated-command#s ...]

Removes one or more commands from operation. Commands are specified by their listing number from a `list` command. If <u>command#</u> is "all", all commands are removed.

**save**   <u>filename</u>  <u>command#</u>   [addition-space-seperated-command#s ...]

Saves a list of cammands to a file called <u>filename</u>. commands are taken from the current "list" and are designated by their "list" command numbers. If <u>command#</u> is "all", all commands are saved to <u>filename</u>. <u>filename</u> is overwritten with each invokation.

**append**   <u>filename</u>  <u>command#</u>   [addition-space-seperated-command#s ...]

Saves a list of cammands to a file called <u>filename</u>. commands are taken from the current "list" and are designated by their "list" command numbers. If <u>command#</u> is "all", all commands are saved to <u>filename</u>. <u>filename</u> is created if it does not exist and is appended to if it does exist.

### MidiOSC.sh 

**MidiOSC.sh**   <u>MIDI-input-device-name</u>   <u>MIDI-output-device-name</u>   [command]

Reads MIDI command input on <u>MIDI-input-device-name</u> and send sysex-OSC commands to XAir mixer on MIDI device <u>MIDI-output-device-name</u>. An optional command input can be appended to the command line. Other commands are added interactively.

Once `MidiOSC.sh` is invoked, commands are entered via the terminal. All commands remain active until deleted with a `prune` command or until another `prgm` command is entered in the case of `prgm` (see below).

Commands are the same as NetOSC.sh, except that there is no <u>OSC-format</u> in the sysex-OSC protocol. All continuous values are the same as what is seen on the XAir Edit app. So a fader goes from -90 dB to +10 dB, not form 0.0 to 1.0.


