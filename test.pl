#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($RealBin);
use lib "$RealBin/lib-perl";
use BKITVariables;
use BKITDirs;

print "BKITUSER=$ENV{BKITUSER}\n";
print "OS=$ENV{OS}\n";
print "RSYNCOPTIONS=$ENV{RSYNCOPTIONS}\n";
print "BKITCYGWIN=$ENV{BKITCYGWIN}\n" if $ENV{BKITCYGWIN};
print "BKITISADMIN=$ENV{BKITISADMIN}\n" if $ENV{BKITISADMIN};
