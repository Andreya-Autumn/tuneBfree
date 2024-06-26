tuneBfree
=========

Fork of setBfree with microtuning added using
[MTS-ESP](https://github.com/ODDSound/MTS-ESP).

Built LV2 plugins are available for Mac, Windows, and Linux on the github
[releases page](https://github.com/narenratan/tuneBfree/releases).

Tuning
------
The tuning can be set using an MTS-ESP master like [MTS-ESP
Mini](https://oddsound.com/mtsespmini.php).

[Arseniiv](https://github.com/arseniiv) wrote a great guide to tuning tuneBfree
which is in the repo
[here](https://github.com/narenratan/tuneBfree/blob/main/guide.md) - thanks
very much for that!


Building
--------
On Linux, install libjack-dev, libopengl-dev, libglu1-mesa-dev, libftgl-dev, libwebp-dev and xxd
(package names for Ubuntu).

On Mac, use Homebrew to install jack, freeglut, ftgl, bzip2, webp, and pkg-config.

On Windows, install [MSYS2](https://www.msys2.org/), open the MSYS2 UCRT64
shell, and run
```
$ pacman -S \
    git \
    make \
    vim \
    mingw-w64-ucrt-x86_64-gcc \
    mingw-w64-ucrt-x86_64-jack2 \
    mingw-w64-ucrt-x86_64-freeglut \
    mingw-w64-ucrt-x86_64-ftgl \
    mingw-w64-ucrt-x86_64-pkg-config
```

Then on Linux, Mac, or Windows run
```
$ git clone --recurse-submodules https://github.com/narenratan/tuneBfree
$ cd tuneBfree
$ make
```

This creates the LV2 plugin in build/tuneBfree.lv2.

To build the experimental tuneBfree CLAP you can run
```
$ cd src
$ cmake -B build
$ cmake --build build
```
To build the CLAP with the Cycfi Elements GUI, you can run
```
$ cd src
$ cmake -B build -D CLAP_GUI=true
$ cmake --build build
```
To install the build dependencies for the Elements GUI on Windows you can run
```
$ ./libs/vcpkg/bootstrap-vcpkg.bat
$ ./libs/vcpkg/vcpkg.exe install pkgconf:x64-windows-static cairo:x64-windows-static libwebp:x64-windows-static
```
(this may take fifteen minutes or so).

Original README follows.


setBfree
========

A DSP Tonewheel Organ emulator.

setBfree is a MIDI-controlled, software synthesizer designed to imitate the
sound and properties of the electromechanical organs and sound modification
devices that brought world-wide fame to the names and products of Laurens
Hammond and Don Leslie.

*   http://setbfree.org
*   https://github.com/pantherb/setBfree

Download
--------

Binaries for GNU/Linux, OSX and Windows are available from

*   http://x42-plugins.com/x42/setBfree

setBfree is also available on most Linux distributions.

Quick-start
-----------

 - start jackd (see http://jackaudio.org, more below)
 - run `setBfreeUI` for the GUI version
 - run `setBfree` for the headless commandline application
 - or load the LV2 plugin "setBfree DSP Tonewheel Organ" in your favorite DAW

Screenshots
-----------

![screenshot](https://raw.githubusercontent.com/pantherb/setBfree/master/doc/b_synth.png "setBfree GUI")


[Demo Video](https://vimeo.com/130633814)


Usage
-----

setBfree is available as 3 different variants:

*   standalone JACK application with graphical user interface
*   LV2 plugin (with optional GUI)
*   commandline application

Run `setBfree -h` for a quick overview. `setBfree --help` will output a
lengthy list of available options and properties than can be modified.

`setBfree` is the synthesizer engine. It responds to MIDI messages (JACK-MIDI
or ALSA-sequencer) and outputs audio to JACK. The engine does not have any
graphical user interface (GUI). It is usually started from the commandline.

The GUI `setBfreeUI` is a standalone application that wraps the synth engine.
It provides both visual feedback about the current synth state as well as allows
to reconfigure and control numerous aspects of the organ.

The complete organ (incl. GUI), as well as individual parts (leslie, reverb,
overdrive) are also available as LV2 plugins.

Examples:

	setBfree jack.out.left="system:playback_7" jack.out.right="system:playback_8"
	setBfreeUI
	jalv.gtk http://gareus.org/oss/lv2/b_synth # LV2 in jalv-host


Getting started - standalone app
--------------------------------

You'll want reliable, low-latency, real-time audio. Therefore you want
[JACK](http://jackaudio.org/). On GNU/Linux we recommend `qjackctl` to start the
jack-audio-server, on OSX jack comes with a GUI called JACK-pilot. On Windows use the
Jack Control GUI.

An excellent tutorial to get started with JACK can be found on the
[libremusicproduction](http://libremusicproduction.com/articles/demystifying-jack-%E2%80%93-beginners-guide-getting-started-jack)
website.

Detailed documentation
----------------------

For a detailed documentation, run:

	setBfree -H

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

Render diagram with http://ditaa.sourceforge.net/
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

The LV2-synth includes the first three effects until and including the Leslie.
The effects can be triggered via MIDI just as with the standalone JACK
application. The cabinet-emulation is not included in the LV2-synth because it
depends on impulse-response files which are not shipped with the plugin.

The Vibrato and Chorus effects are built into the synth-engine itself, as are
key-click and percussion modes. These features are linked to the tone
generation itself and can not be broken-out to standalone effects.

Summary of Changes since Beatrix
--------------------------------

*   native JACK application (JACK Audio, JACK MIDI)
*   synth engine: variable sample-rate, floating point (beatrix is 22050 Hz, 16bit only)
*   broken-out effects as LV2 plugins; LV2 wrapper around synth-engine
*   built-in documentation
*   Graphical User Interface, with MIDI-feedback and dynamically bound MIDI-CC
*   fixed leslie aliasing noise
*   state save/restore
*   numerous bug fixes

see the ChangeLog and git log for details.


Compile
-------

Install the dependencies and simply call `make` followed by `sudo make install`.

*   libjack-dev - **required** - [JACK](http://jackaudio.org/) is used for audio and MIDI I/O
*   libftgl-dev, libglu1-mesa-dev, ttf-bitstream-vera - optional, **recommended** - openGL GUI
*   lv2-dev - optional, **recommended** - [LV2](http://lv2plug.in/) plugins and GUI
*   libcairo and libpango - optional, **recommended** - GUI for standalone Leslie/Whirl-speaker LV2
*   libasound2-dev - optional - ALSA MIDI support
*   help2man - optional - re-create the man pages
*   doxygen - optional - create source-code annotations
*   liblo-dev - optional - [OSC](http://opensoundcontrol.org/) used only in standalone preamp/overdrive app, mainly useful for testing.
*   libzita-convolver-dev - optional, deprecated - [libzita-convolver](http://kokkinizita.linuxaudio.org/linuxaudio/downloads/index.html) is used for cabinet-emulation
*   libsndfile1-dev - optional, deprecated - [libsndfile](http://www.mega-nerd.com/libsndfile/) is needed to load IR samples for zita-convolver


Since version 0.8, alsa-sequencer support is deprecated and no longer enabled by
default (even if libasound is found), It is still available via `ENABLE_ALSA=yes`.

The Makefile understands PREFIX and DESTDIR variables: e.g.

	make clean
	make PREFIX=/usr ENABLE_ALSA=yes
	make install ENABLE_ALSA=yes PREFIX=/usr DESTDIR=mypackage/setbfree/

**Packagers**: see debian/rules in the git-repository. LDFLAGS can be passed as is,
CFLAGS should be specified by overriding the OPTIMIZATIONS variable.
The packaging also includes a desktop-file to launch setBfree from the
application-menu which is not included in the release.

Thanks
------

Many thanks to all who contributed ideas, bug-reports, patches and feedback. In
Particular (in alphabetical order): Dominique Michel, Fons Adriaensen, Jean-Luc
Nest, Jeremy Jongepier, Julien Claasen and Ken Restivo.
