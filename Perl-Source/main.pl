#!/usr/bin/perl

# -------------------------------------------------------------------------
# main.pl: PerlWrapper Demo application
# -------------------------------------------------------------------------
# Demonstrates the use of PerlWrapper. This script depends on 
# Mac::Applescript to display an informational message.
# -------------------------------------------------------------------------
# $Id: main.pl 11 2004-10-17 22:19:26Z crenz $
# Copyright (C) 2004 Christian Renz <crenz@web42.com>.
# All rights reserved.

use strict;
use warnings;
use Cwd;
use Mac::AppleScript qw(RunAppleScript);

my $dir = getcwd();
my $msg = <<EOT;

Congratulations! You managed to compile the demo application using PerlWrapper/$PerlWrapper::Version. This dialog box is being displayed using Mac::AppleScript, packaged in this bundle.

See the README file to find out how to create your own application bundles.

The current directory is $dir.

The application bundle path is $PerlWrapper::BundlePath.

The resources path is $PerlWrapper::ResourcesPath.

EOT

RunAppleScript(qq(display dialog "$msg" buttons {"Ok"} default button 1))
    or die "[Wrapped Perl Application] Unable to run AppleScript.\n";

1; # make sure we end with a true value
    
# - eot -------------------------------------------------------------------
