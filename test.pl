#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($RealBin);
use lib "$RealBin/lib-perl";
use BKITVariables;
use BKITDirs;

$\ ="\n";
print "BKITUSER=$ENV{BKITUSER}";
print "OS=$ENV{OS}";
print "RSYNCOPTIONS=$ENV{RSYNCOPTIONS}";
print "BKITCYGWIN=$ENV{BKITCYGWIN}" if $ENV{BKITCYGWIN};
print "BKITISADMIN=$ENV{BKITISADMIN}" if $ENV{BKITISADMIN};
print "VARDIR=$ENV{VARDIR}";
print "ETCDIR=$ENV{ETCDIR}";
print "HOMEDIR=$ENV{BKIT_HOMEDIR}";
print "HOMEDIRWINDOWS=$ENV{BKIT_HOMEDIR_WINDOWS}" if $ENV{BKITCYGWIN};
