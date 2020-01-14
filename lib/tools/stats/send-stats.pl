#!/usr/bin/env perl
use Data::Dumper;
use utf8;
use strict;

my $SIZELIMIT = 0; #Size limit for output directores usage
my $DIRSLIMIT = 50;
my $SEP = '/';
$SEP = '\\' if $^O eq 'cygwin' or $^O eq 'MSWin32';
my $RESEP= qr/\Q$SEP\E/;

$\ = "\n";
$, = ' ';
my @logfile = <>;

my @lines = map{s/^"|"$//g;s!/!$SEP!g;chomp;$_} grep {/^".+"$/ && !m#/run/manifest-segment\.\d+\|#} @logfile;

my $string = q#send|#;
my @sends = grep {/^\Q$string\E/} @lines;
my @files = grep {/^send\|.f/} @sends;

{ #compute number of transfered bytes
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
	print "Total size of assessed files: $bytes$u";
}

print 'Number of assessed files:', scalar @files;

my @dirs = grep {/^send\|.d/} @sends;
print 'Number of assessed dirs:', scalar @dirs;

my $string = q#send|<f+++++++++|#;
my @newfiles = grep {/^\Q$string\E/} @sends;
print 'Number of new files:', scalar @newfiles;

my @updfiles = grep {/^send\|<f[^+]{9}\|/} @sends;
print 'Number of updated files:', scalar @updfiles;

my @permfiles = grep {/^send\|\.f[^+]{9}\|/} @sends;
print 'Number of updated permissions/attributes only :', scalar @permfiles;

my $string = q#send|cd+++++++++|#;
my @newdirs = grep {/^\Q$string\E/} @sends;
print "Number of created directories:", scalar @newdirs;

my @dels = grep {/^del\./} @lines;
print "Number of deleted files or directories:", scalar @dels;

# {
# 	my @tmp = split /\|/, $lines[0];
# 	my $start = pop @tmp;
# 	my @tmp = split /\|/, $lines[$#lines];
# 	my $stop = pop @tmp;
# 	my $start = 0 | qx/date +%s -d "$start"/;
# 	my $stop = 0 | qx/date +%s -d "$stop"/;
# 	my $delta = $stop - $start;
# 	my ($sec,$min,$hour) = ("${delta}s", '0m', '0h');
# 	$sec = ($delta % 60) . 's' and $delta = 0 | $delta / 60 and $min = "${delta}m" if $delta > 59;
# 	$min = ($delta % 60) . 'm' and $delta = 0 | $delta / 60 and $hour = "${delta}h" if $delta > 59;
# 	print "Total time spent: $hour$min$sec";
# }

{
	my %sizes;
	foreach my $line (@newfiles,@updfiles){
		my @fields = split /\|/, $line;
		my $size = $fields[4];
		next unless $size > 0;
		my @dirs = split $RESEP, $fields[2];
		pop @dirs;
		my $dir = '';
		foreach my $i (0..$#dirs) {
			$dir = $dirs[$i] = "$dir$dirs[$i]$SEP";
		}
		map { $sizes{$_} += $size } @dirs;
	}
	my @keys = grep {$sizes{$_} > $SIZELIMIT} keys %sizes;
	print "Bytes sent by directory:" if scalar @keys;
	my $last = {
		size => 0,
		dir => ''
	};
	my @lines = ();
	foreach my $dir (sort {
			return $sizes{$b} <=> $sizes{$a} unless $sizes{$b} == $sizes{$a};
			return $b cmp $a
		} @keys){
		my $size = $sizes{$dir};
		push @lines, sprintf("\t%-12d\t%s", $size, $dir) unless $size == $last->{size} and $last->{dir} =~ /\Q$dir\E/;
		$last->{size} = $size;
		$last->{dir} = $dir;
	}
	my $diff = scalar @lines - $DIRSLIMIT;
	$#lines = $DIRSLIMIT - 1 if $diff > 0;
	local $, = "\n";
	print @lines;
	print "\t+ $diff directories. See Logs" if $diff > 0;
}

{
	my %sizes = ();
	foreach my $line (@updfiles){
		my ($file,$size) = (split /\|/, $line)[2,4];
		next and print STDERR "Strange situation with $line" if defined $sizes{$file};
		$sizes{$file} += $size;
	}
	my @topkeys = (sort { $sizes{$b} <=> $sizes{$a} }  keys %sizes);
	$#topkeys = 9 if scalar @topkeys > 10;
	print scalar @topkeys, "Biggest updates:" if scalar @topkeys;
	printf("\t%-12d\t%s\n", $sizes{$_}, "$_") foreach (@topkeys);
}

{
	my %sizes = ();
	foreach my $line (@newfiles){
		my ($file,$size) = (split /\|/, $line)[2,4];
		next and print STDERR "Strange situation with $line" if defined $sizes{$file};
		$sizes{$file} += $size;
	}
	my @topkeys = (sort { $sizes{$b} <=> $sizes{$a} }  keys %sizes);
	$#topkeys = 9 if scalar @topkeys > 10;
	print scalar @topkeys, "Biggest new files:" if scalar @topkeys;
	printf("\t%-12d\t%s\n", $sizes{$_}, "$_") foreach (@topkeys);
}
