#!/usr/bin/env perl
use Data::Dumper;
use utf8;
use strict;

$\ = "\n";

my @lines = map{s/^"|"$//g;chomp;$_} grep {/^".+"$/ && !m#cygdrive/.+/manifest-segment#} <>;
my $start = q#send|#;
my @sends = grep {/^\Q$start\E/} @lines;
my $start = q#del.|#;
my @dels = grep {/^\Q$start\E/} @lines;
my @files = grep {/^send\|.f/} @sends;
my @bytes = map{my @fields = split /\|/; $fields[4]} @files;
my $bytes = 0;
$bytes += $_ foreach (@bytes);
my @dirs = grep {/^send\|.d/} @sends;
my $start = q#send|<f+++++++++|#; 
my @newfiles = grep {/^\Q$start\E/} @sends;
my @updfiles = grep {/^send\|<f[^+]{9}\|/} @sends;
my @permfiles = grep {/^send\|\.f[^+]{9}\|/} @sends;
my $start = q#send|cd+++++++++|#; 
my @newdirs = grep {/^\Q$start\E/} @sends;
# foreach my $line (@bytes){
# 	print $line;
# }
print "Total of files touched $#files";
print "Total of dirs touched $#dirs";
print "Total of bytes sent $bytes";
print "Sent $#newfiles New Files";
print "Updated $#updfiles existing Files";
print "Changed permissions/attributes in $#permfiles Files";
print "Created $#newdirs new Directories";
print "Deleted $#dels Files/Directories";


