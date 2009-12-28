#!/usr/bin/perl

# -------------------------------------------------------------------------
# update_dylib_references.pl: PerlWrapper dylib references helper
# -------------------------------------------------------------------------
# If you bundle dynamic libraries with your application, the references
# inside these libraries and the XS bundles using them should be changed
# to relative paths pointing inside the library. This tool helps you
# to do that.
# -------------------------------------------------------------------------
# $Id: update_dylib_references.pl 5 2004-06-11 23:45:52Z crenz $
# Copyright (C) 2004 Christian Renz <crenz@web42.com>.
# All rights reserved.

use File::Find;

my $install_name_tool = 'install_name_tool';
my $otool = 'otool';

my $dir_dylib = '../Libraries/';
my $dir_perllib = '../Perl-Libraries/';

my $prefix_dylib = 'Contents/Resources/Libraries';

my @dylibs = ();
my %dylib_refs = ();

sub wanted_dylibs {
    next unless /\.dylib$/;
    next unless -r && -f;
    
    my $out = `$otool -L $_`;
    my @libs = ($out =~ m|^\s+(/[^ ]+)|mg);
    
    foreach my $l (@libs) {
        push @{$dylib_refs{$l}}, $_;
    }

    s/^$dir_dylib//;    
    push @dylibs, $_;
}

sub wanted_dylib_refs {
    next unless /\.bundle$/;
    next unless -r && -f;

    my $out = `$otool -L $_`;
    my @libs = ($out =~ m|^\s+(/[^ ]+)|mg);
    
    foreach my $l (@libs) {
        push @{$dylib_refs{$l}}, $_;
    }
}

print "\nSearching for bundled dylibs in $dir_dylib ...\n";
find({wanted => \&wanted_dylibs, no_chdir => 1}, $dir_dylib);
print scalar @dylibs, " dylibs found.\n";

print "Searching for XS bundles in $dir_perllib ...\n";
find({wanted => \&wanted_dylib_refs, no_chdir => 1}, $dir_perllib);
print scalar keys %dylib_refs, " different dylibs references found.\n";

print "Changing references...\n";
my $c = 0;
foreach my $ref (sort keys %dylib_refs) {
    my ($newref) = grep { $ref =~ /$_$/ } @dylibs;
    
    unless ($newref) {
        print "References to $ref remain unchanged\n";
        next;
    }
    
    print "Changing '$ref'\n      to '$prefix_dylib$newref'\n";
    foreach my $lib (@{$dylib_refs{$ref}}) {
        print "      in $lib\n";
        `$install_name_tool -change $ref $prefix_dylib$newref $lib`;
        $c++;
    }
}
print "$c references changed.\n\n";
    
# - eot -------------------------------------------------------------------

