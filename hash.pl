#!/usr/bin/perl 
use strict;
use warnings;
use Digest::SHA;

my $sha = Digest::SHA->new(256);
$\="\n";
while (<>){
  chomp;
  next unless -f;
  my ($size,$time) = (stat)[7,9];
  eval {$sha->addfile($_,'b');} or next;
  my $dig = $sha->hexdigest;
  my @steps = split //, $dig;
  my $path = join '/',@steps[0..5],$dig; 
  print "$_|$path|$size|$time";
}

