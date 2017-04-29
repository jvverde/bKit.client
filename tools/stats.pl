#!/usr/bin/env perl
use Data::Dumper;
use utf8;
use strict;

$\ = "\n";
$, = ' ';
my @logfile = <>;

my @lines = map{s/^"|"$//g;chomp;$_} grep {/^".+"$/ && !m#/run/manifest-segment\.\d+\|#} @logfile;

my $string = q#send|#;
my @sends = grep {/^\Q$string\E/} @lines;
my @files = grep {/^send\|.f/} @sends;

print 'Number of files touched:', scalar @files;

my @dirs = grep {/^send\|.d/} @sends;
print 'Number of dirs touched:', scalar @dirs;

{ #compute number of tranfered bytes
	my @bytes = map{my @fields = split /\|/; $fields[4]} @files;
	my $bytes = 0;
	$bytes += $_ foreach (@bytes);
	my $u = 'B';
	$bytes = 0 | $bytes / 1024 and $u = 'Kb' if $bytes > 2048;
	$bytes = 0 | $bytes / 1024 and $u = 'Mb' if $bytes > 2048;
	$bytes = 0 | $bytes / 1024 and $u = 'Gb' if $bytes > 2048;
	print "Total of bytes sent: $bytes$u";
}

{	#compute size of files touched
	my @bytes = map{my @fields = split /\|/; $fields[5]} @files;
	my $bytes = 0;
	$bytes += $_ foreach (@bytes);	
	my $u = 'B';
	$bytes = 0 | $bytes / 1024 and $u = 'Kb' if $bytes > 2048;
	$bytes = 0 | $bytes / 1024 and $u = 'Mb' if $bytes > 2048;
	$bytes = 0 | $bytes / 1024 and $u = 'Gb' if $bytes > 2048;
	print "Total size of backed up files: $bytes$u";
} 

my $string = q#send|<f+++++++++|#; 
my @newfiles = grep {/^\Q$string\E/} @sends;
print 'Number of new files:', scalar @newfiles;

my @updfiles = grep {/^send\|<f[^+]{9}\|/} @sends;
print 'Number updated existing files:', scalar @updfiles;

my @permfiles = grep {/^send\|\.f[^+]{9}\|/} @sends;
print 'Number of files updated with permissions/attributes only:', scalar @permfiles;

my $string = q#send|cd+++++++++|#; 
my @newdirs = grep {/^\Q$string\E/} @sends;
print "Number of created directories:", scalar @newdirs;

my @dels = grep {/^del\./} @lines;
print "Number of deleted files or directories:", scalar @dels;

{
	my @tmp = split /\|/, $lines[0];
	my $start = pop @tmp;
	my @tmp = split /\|/, $lines[$#lines];
	my $stop = pop @tmp;
	my $start = 0 | qx/date +%s -d "$start"/;
	my $stop = 0 | qx/date +%s -d "$stop"/;
	my $delta = $stop - $start;
	my ($sec,$min,$hour) = ("${delta}s", '0m', '0h');
	$sec = ($delta % 60) . 's' and $delta = 0 | $delta / 60 and $min = "${delta}m" if $delta > 59;
	$min = ($delta % 60) . 'm' and $delta = 0 | $delta / 60 and $hour = "${delta}h" if $delta > 59;
	print "Total time spent: $hour$min$sec";
}
