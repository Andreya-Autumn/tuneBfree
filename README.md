setBfree
========

A DSP Tonewheel Organ emulator.

setBfree is a MIDI-controlled, software synthesizer designed to imitate the
sound and properties of the electromechanical organs and sound modification
devices that brought world-wide fame to the names and products of Laurens
Hammond and Don Leslie.

*   http://setbfree.org
*   https://github.com/pantherb/setBfree


Quick-start
-----------

 - start jackd [http://jackaudio.org] or configure JACK autostart
 - run `setBfree-start`
 - connect JACK Audio/MIDI ports (using qjackctl or you favorite JACK
   connection manager)


About
-----

setBfree is based on the code of Fredrik Kilander's Beatrix organ emulator. He
gave permission to Will to use the Beatrix code in a GPL app. Robin Gareus
changed the OSS based code to a JACK interface and moved the overdrive, reverb,
and leslie functionality into LV2 plugins. The LV2 plugins allow users to mix
and match any of the components with any other JACK supported app. Robin also
added a TCL/TK GUI for testing and added leslie cabinet simulation using Ken
Restivo's IR sample.

While this works now in its first beta release, we are using this as a starting
point for building a high quality emulator players familiar with the great
Hammond organs of the past will enjoy. There will be two major milestones to
reach this goal. The first is to clean up its first beta functionality
including improving and cleaning up the current code, and adding a slicker GUI
interface. For the second milestone, we will modify much of the code to make
the organ more dynamic. A user will be able to adjust to taste from the 'like a
bird' quality of chill players to the knocking, screaming organ sounds of
gospel vamps, and rock and roll.


Usage
-----

Run `setBfree -h` for a quick overview. `setBfree --help` will output a
lengthy list of available options and properties than can be modified.

`setBfree` is the synthesizer engine. It responds to MIDI messages (JACK-MIDI
or ALSA-sequencer) and outputs audio to JACK and runs from the command-line.
The GUI `vb3kb` is a standalone application that simply sends MIDI messages to
setBfree. `setBfree-start` is a shell-script that launches both and connects
the GUI to the synth.

Examples:

	setBfree midi.driver="alsa" midi.port="129" jack.connect="jack_rack:in_"
	setBfree jack.out.left="system:playback_7" jack.out.left="system:playback_8"
	setBfree-start midi.driver="alsa"


Getting started - standalone app
--------------------------------

You'll want reliable, low-latency, real-time audio. Therefore you want
[JACK](http://jackaudio.org/). On GNU/Linux use `qjackctl` to start the
jack-audio-server, on OSX jack comes with a GUI called JACK-pilot.

To be continued..


Getting started - LV2 plugins
-----------------------------

To be continued..


Internal Signal Flow
--------------------

	     +--------+    /-----------\    /--------\
	     |        |    |           |    |        |
	MIDI | Synth- |    |  Preamp/  |    |        |
	--=->|        +--->|           +--->| Reverb +--\
	     | Engine |    | Overdrive |    |        |  |
	     |        |    |           |    |        |  |
	     +--------+    \-----------/    \--------/  |
	                                                |
	  /---------------------------------------------/
	  |
	  |  /--------\ Horn L/R  /-----------\
	  |  |        +---------->|  Cabinet  +-----*--> Audio-Out Left
	  |  |        +---------->| Emulation +--\  |
	  \->| Leslie |           \-----------/  |  |
	     |        +--------------------------|--/
	     |        +--------------------------*-----> Audio-Out Right
	     \--------/ Drum L/R

Render diagram with http://ditaa.org/
A pre-rendered image is available in the doc/ folder.

Each of the stages - except the synth-engine itself - can be bypassed. The
effects are available as standalone LV2 plugins which provides for creating
custom effect chains and use 3rd party effects.

The preamp/overdrive is disabled by default, reverb is set to 30% (unless
overridden with `reverb.mix`, `reverb.dry` or `reverb.wet`). Note that a
stopped leslie will still modify the sound (horn-speaker characteristics,
angle-dependent reflections). Bypassing the leslie (`whirl.bypass=1`) will mute
the drum-output signals and simply copy the incoming audio-signal to the horn
L/R outputs. The cabinet-emulation is an experimental convolution engine and
bypassed by default.

The LV2-synth includes the first three effects until the Leslie they can be
triggered via MIDI just as the standalone JACK application. The
cabinet-emulation is not included in the LV2-synth, it depends on
impulse-response files which are not shipped with the plugin.

The Vibrato and Chorus effects are built-into the synth-engine itself as are
key-click and percussion modes. They are too much linked with the tone
generation itself to be broken-out.

Summary of Changes since Beatrix
--------------------------------

*   native JACK application (JACK Audio, JACK or ALSA MIDI in)
*   synth engine: variable sample-rate, floating point (beatrix is 22050 Hz, 16bit only)
*   broken-out effects as LV2 plugins; LV2 wrapper around synth-engine
*   built-in documentation

see the ChangeLog and git log for details.


Compile
-------

Install the dependencies and simply call `make` followed by `sudo make install`.

*   libjack-dev - required - http://jackaudio.org - used for audio I/O
*   libasound2-dev - optional, recommended - ALSA MIDI
*   lv2-dev - optional, recommended - build effects as LV2 plugins
*   tcl-dev, tk-dev - optional, recommended - needed for "vb3kb" virtual Keyboard - GUI wrapper for testing and debugging.
*   libzita-convolver-dev - optional - IR leslie speaker-emulation for the standalone organ app
*   libsndfile1-dev - optional - needed to load IR samples for zita-convolver
*   liblo-dev - optional - http://opensoundcontrol.org - used for standalone preamp/overdrive app.
*   help2man - optional - re-create the man pages
*   doxygen - optional - create source-code annotations


If zita-convolver and libsndfile1-dev are available you can use

	make clean
	make ENABLE_CONVOLUTION=yes

to enable a built-in convolution reverb.


The Makefile understands PREFIX and DESTDIR variables:

	make clean
	make ENABLE_CONVOLUTION=yes PREFIX=/usr
	make install ENABLE_CONVOLUTION=yes PREFIX=/usr DESTDIR=mypackage/setbfree/
