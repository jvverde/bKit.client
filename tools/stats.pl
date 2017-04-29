#!/usr/bin/env perl
use Data::Dumper;
use utf8;
use strict;

$\ = "\n";
my @logfile = <>;
my @lines = map{s/^"|"$//g;chomp;$_} grep {/^".+"$/ && !m#cygdrive/.+/manifest-segment#} @logfile;
my $start = q#send|#;
my @sends = grep {/^\Q$start\E/} @lines;
my $start = q#del.|#;
my @dels = grep {/^\Q$start\E/} @lines;
my @files = grep {/^send\|.f/} @sends;
my @bytes = map{my @fields = split /\|/; $fields[4]} @files;
my $bytes = 0;
$bytes += $_ foreach (@bytes);
my @sbytes = map{my @fields = split /\|/; $fields[5]} @files;
my $sbytes = 0;
$sbytes += $_ foreach (@sbytes);
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
my $u = 'B';
$bytes = 0 | $bytes / 1024 and $u = 'Kb' if $bytes > 2048;
$bytes = 0 | $bytes / 1024 and $u = 'Mb' if $bytes > 2048;
$bytes = 0 | $bytes / 1024 and $u = 'Gb' if $bytes > 2048;
print "Total of bytes sent $bytes$u";
my $u = 'B';
$sbytes = 0 | $sbytes / 1024 and $u = 'Kb' if $sbytes > 2048;
$sbytes = 0 | $sbytes / 1024 and $u = 'Mb' if $sbytes > 2048;
$sbytes = 0 | $sbytes / 1024 and $u = 'Gb' if $sbytes > 2048;
print "Total size of backed up files $sbytes$u";
print "Sent $#newfiles New Files";
print "Updated $#updfiles existing Files";
print "Changed only permissions/attributes in $#permfiles Files";
print "Created $#newdirs new Directories";
print "Deleted $#dels Files/Directories";
my @tmp = split /\|/, $lines[0];
my $start = pop @tmp;
my @tmp = split /\|/, $lines[$#lines-1];
my $stop = pop @tmp;
my $start = 0 | qx/date +%s -d "$start"/;
my $stop = 0 | qx/date +%s -d "$stop"/;
my $delta = $stop - $start;
my ($sec,$min,$hour) = ("${delta}s", '0m', '0h');
$sec = ($delta % 60) . 's' and $delta = 0 | $delta / 60 and $min = "${delta}m" if $delta > 59;
$min = ($delta % 60) . 'm' and $delta = 0 | $delta / 60 and $hour = "${delta}h" if $delta > 59;
print "Total time spent: $hour$min$sec";
print "";


