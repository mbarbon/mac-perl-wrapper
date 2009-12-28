#!/usr/bin/make -f

# TODO
# - copy info strings
# - copy all resource files
# - rename executable, icon in Info.plist

BUNDLE=PerlWrapper
ICON_FILE=PerlWrapperApp
PERL=/usr/bin/perl

BUNDLE_DIR=build/$(BUNDLE).app
BUNDLE_CONTENTS=build/$(BUNDLE).app/Contents
BUNDLE_RESOURCES=build/$(BUNDLE).app/Contents/Resources
BUNDLE_BIN=build/$(BUNDLE).app/Contents/MacOS
BUNDLE_DIRS= \
  $(BUNDLE_CONTENTS) \
  $(BUNDLE_RESOURCES) \
  $(BUNDLE_BIN) \
  $(BUNDLE_RESOURCES)/Perl-Source \
  $(BUNDLE_RESOURCES)/Perl-Libraries \
  $(BUNDLE_RESOURCES)/Libraries
BUNDLE_FILES= \
  $(BUNDLE_CONTENTS)/Info.plist \
  $(BUNDLE_RESOURCES)/$(ICON_FILE).icns \
  $(BUNDLE_BIN)/$(BUNDLE)
C_SOURCES= \
  Source/PerlInterpreter.c \
  Source/main.c
C_HEADERS= \
  Source/PerlInterpreter.h

all: bundle

bundle: $(BUNDLE_DIRS) $(BUNDLE_FILES)
	cp -af Perl-Libraries/ $(BUNDLE_RESOURCES)/Perl-Libraries
	cp -af Libraries/ $(BUNDLE_RESOURCES)/Libraries
	cp -af Perl-Resources/ $(BUNDLE_RESOURCES)
	cp -af Perl-Source/ $(BUNDLE_RESOURCES)/Perl-Source

# resources

$(BUNDLE_CONTENTS)/Info.plist: Info.plist
	cp -f $< $@

$(BUNDLE_RESOURCES)/$(ICON_FILE).icns: Resources/$(ICON_FILE).icns
	cp -f $< $@

# application

$(BUNDLE_BIN)/$(BUNDLE): $(C_SOURCES) $(C_HEADERS)
	$(CC) $(C_SOURCES) -I"Source" -Wall -o $@ \
	    `$(PERL) -MExtUtils::Embed -e ccopts -e ldopts` \
	    -framework CoreFoundation -framework CoreServices

# directories

$(BUNDLE_DIRS):
	for i in $(BUNDLE_DIRS); do \
	    mkdir -p $$i; \
	done
