# XAir MIDI OSC BASH utilities
These utilities allow one to utilize a MIDI controller to change parameter settings on the XAir series of mixers.

This Repository contains BASH shell scripts which utilize the command line programs XAir_Interface, sendmidi and receivemidi available at:

https://github.com/Rippert/XAir-Behringer.git

https://github.com/gbevin/SendMIDI.git and https://github.com/gbevin/ReceiveMIDI.git

XAir_Command, sendmidi and receivemidi executables should be placed in the users PATH.

### Version 0.2
The multiple scripts of version 0.1 have been replaced by two scipts (*NetOSC.sh* and *MidiOSC.sh*). Version 0.1 scripts are still availble in the branch *archive*.

Examples of `prgm` (see below) files are provided in *OSClist1,2,3* for *NetOSC.sh*, and *MOSClist1,2* for *MidiOSC.sh*.

#### NetOSC.sh 
**NetOSC.sh**   <u>XAir-IPv4-address</u>   <u>MIDI-device-name</u>   [command]

Reads MIDI command input on <u>MIDI-device-name</u> and send OSC commands to XAir mixer at IP address <u>XAir-IPv4-address</u>. An optional command input can be appended to the command line. Other commands are added interactively.

Once `NetOSC.sh` is invoked, commands are entered via the terminal. All commands remain active until deleted with a `prune` command or until another `prgm` command is entered in the case of `prgm` (see below). 

Currently accepted commands are:

**cc2param**   <u>MIDI-channel#</u>   <u>CC#</u>   <u>CC-lower#</u>   <u>CC-upper#</u>   <u>param-lower#</u>   <u>param-upper#</u>   <u>OSC-address</u>   <u>OSC-format</u>

setup a linear link between the MIDI ontinuous-controller <u>CC#</u> on MIDI channel <u>MIDI-channel#</u> and the OSC continuous parameter at <u>OSC-address</u>, with format <u>OSC-format</u>.

Example: `cc2param 1 10 0 127 0.0 1.0 /ch/01/mix/fader ,f` - sets up a link between MIDI ontinuous-controller 10 on MIDI channel 1, and the main fader on channel 1 of the XAir mixer. A ontinuous-controller value of 0 will yield a fader value of -oo dB, and a ontinuous-controller value of 127 will yield a fader value of +10 dB. Intermediate ontinuous-controller values will yield intermediate fader settings.

Generally used to tie a MIDI ontinuous-controller actuator (a foot pedal, knob, slider, etc) to a mixer parameter for realtime control with smooth, continous changes in values.

All continuous parameters on an XAir mixer take a float `,f` format and have a range of 0.0 to 1.0. String, `,s` and integer, `,i` formats are also possible but beyond the scope of this document.

**cc2ptoggle**   <u>MIDI-channel#</u>   <u>CC#</u>   <u>CC-ON#</u>   <u>CC-OFF#</u>   <u>OSC-address</u>   <u>OSC-format</u>

setup a one-to-one link between the MIDI ontinuous-controller <u>CC#</u> on MIDI channel <u>MIDI-channel#</u> and the OSC discrete (ON - OFF) parameter at <u>OSC-address</u>, with format <u>OSC-format</u>.

Example: `cc2toggle 2 18 0 127 /ch/11/insert/on ,i` - sets up a link between MIDI ontinuous-controller 18 on MIDI channel 2, and the FX insert switch on channel 11 of the XAir mixer. A ontinuous-controller value of 0 will turn ON the FX insert, and a ontinuous-controller value of 127 will turn OFF the FX insert.

Generally used to tie a MIDI ontinuous-controller switch (a button) to a mixer parameter for realtime control of ON-OFF state.

**prgm**   <u>file</u>

Load a list of commands from a file on disk named <u>file</u> (use a full path if not in working directory). commands can be any valid coomand accepted by the script.

WHen multiple `prgm` commands are loaded, only the most recent one remains active. Thus loading `prgm OSClist1` will load all the commands from the file named *OSClist1* in the current directory. Loading `prgm OSClist2` will remove all *OSClist1* commands and load all *OSClist2* commands.

Example: `prgm OSClist1`

Loads all commands from the file *OSClist1*. Unloads any other `prgm` files previously loaded. teh file is a plain text file with a list of commands (one command per line).

**list**

List all running commands. Commands are preceeded by a number to be used for the `prune` command

**prune**   <u>command#</u>   [addition-space-seperated-command#s ...]

Removes one or more commands from operation. Commands are specified by their listing number from a `list` command.

#### MidiOSC.sh 
**MidiOSC.sh**   <u>MIDI-input-device-name</u>   <u>MIDI-output-device-name</u>   [command]

Reads MIDI command input on <u>MIDI-input-device-name</u> and send sysex-OSC commands to XAir mixer on MIDI device <u>MIDI-output-device-name</u>. An optional command input can be appended to the command line. Other commands are added interactively.

Once `NetOSC.sh` is invoked, commands are entered via the terminal. All commands remain active until deleted with a `prune` command or until another `prgm` command is entered in the case of `prgm` (see below).

Commands are the same as NetOSC.sh, except that there is no <u>OSC-format</u> in the sysex-OSC protocol. All continuous values are the same as what is seen on the XAir Edit app. So a fader goes from -90 dB to +10 dB, not form 0.0 to 1.0.