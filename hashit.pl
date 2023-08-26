#!/usr/bin/env perl
use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename;
use File::stat;
use Digest::SHA qw(sha256_hex);

$\="\n";

sub get_mount_point {
    my ($file) = @_;
    my $mount_point = qx/stat -c %m "$file"/;
    chomp($mount_point);
    return $mount_point;
}

sub compute_hash {
    my ($file) = @_;
    open(my $fh, '<:raw', $file) or die "Unable to open file $file: $!";
    my $hash = sha256_hex(<$fh>);
    close($fh);
    return $hash;
}

sub main {
    my $sdir = dirname(abs_path($0));

    foreach my $dir (@ARGV) {
        my $fullpath = abs_path($dir);
        next unless $fullpath;

        my $root = $ENV{BKIT_MNTPOINT} || get_mount_point($fullpath);

        open(my $check_fh, '-|', "$sdir/check.sh", @ARGV, "--out-format=%i|/%f", $fullpath) or die "Failed to execute check.sh: $!";        
        while (my $line = <$check_fh>) {
            chomp($line);
            next unless $line =~ /^<f/; # Only consider files that need update
            my ($status, $file) = split(/\|/, $line);
            my $fullname = "$root/$file";
            my $hash = compute_hash($fullname);
            $hash =~ s{^(.)(.)(.)(.)(.)(.)}{$1/$2/$3/$4/$5/$6/};
            my $stats = stat($fullname);
            my $size = $stats->size;
            my $mtime = $stats->mtime;
            print "$hash|$size|$mtime|$file";
        }
        close($check_fh);
    }
}

die "Usage:\n\t$0 dirs" unless @ARGV;

main();
