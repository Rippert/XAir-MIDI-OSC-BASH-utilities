These utilities allow one to utilize a MIDI controller to change parameter settings on the XAir series of mixers.

This Repository contains BASH shell scripts which utilize the command line programs XAir_Command, sendmidi and receivemidi available at:

https://github.com/pmaillot/X32-Behringer.git

https://github.com/gbevin/SendMIDI.git and https://github.com/gbevin/ReceiveMIDI.git

XAir_Command, sendmidi and receivemidi executables should be placed in the users PATH.

param2NetOSC.sh and node2MIDI-OSC.sh are prototypes that need to be edited and renamed for your particular purpose. 
Examples are given in the Examples folder.

The examples require that a Stereo Guitar Amp FX is set up in FX slot 4. A midi interface (input to computer and output to XAir mixer) is required for Clean2DistAmpfx4_sysex.sh, and a midi interface (input to computer) and network connection to the XAir mixer are required for Clean2DistAmpfx4.sh