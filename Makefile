EXPORTED_VERSION=0.8.12
export EXPORTED_VERSION

FONTFILE ?= verabd.h
export FONTFILE

ifneq ($(wildcard robtk/robtk.mk),)
  ROBTK ?= robtk/
endif

ifneq ($(ROBTK),)
RW=$(abspath $(ROBTK))/
export RW
endif

# Make LV2, CLI, and GUI
SUBDIRS = b_synth src ui

default: all

$(SUBDIRS)::
	$(MAKE) -C $@ $(MAKECMDGOALS)

all clean install uninstall: $(SUBDIRS)

doc:
	help2man -N --help-option=-H -n 'DSP tonewheel organ' -o doc/setBfree.1 src/setBfree
	help2man -N -n 'The B Whirl Speaker' -o doc/x42-whirl.1 b_whirl/x42-whirl
	-help2man -N -n 'The B Preamp/Overdrive Emulator' -o doc/jboverdrive.1 b_overdrive/jboverdrive

dist:
	git archive --format=tar --prefix=setbfree-$(EXPORTED_VERSION)/ HEAD | gzip -9 > setbfree-$(EXPORTED_VERSION).tar.gz

.PHONY: clean all subdirs install uninstall dist doc
