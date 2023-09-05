#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp qw/tempdir/;

# Check for command-line arguments
if (@ARGV < 2) {
    die("Usage: $0 <directory> <filter_file>\n");
}

my ($directory, $filter_file) = @ARGV;

my $temp_dir = tempdir( 'bkit-excluded-XXXXXXX', CLEANUP => 1, TMPDIR => 1);

my %lines;

my $dry_rsync_filter = qq|rsync --dry-run -aiH --filter=". $filter_file" "$directory/" "$temp_dir"|;

open(my $filter, "-|", $dry_rsync_filter) or die "Failed to open $dry_rsync_filter: $!";

while (my $line = <$filter>) {
  $lines{$line} = 1;
}

my $dry_rsync = qq|rsync --dry-run -aiH "$directory/" "$temp_dir"|;

open(my $rh, "-|", $dry_rsync) or die "Failed to open rsync pipe: $!";

while (my $line = <$rh>) {
  print "$line" unless $lines{$line};
}
