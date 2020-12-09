#!/usr/bin/env perl
use strict;
use Crypt::SRP;
use utf8;
$\ ="\n";

  # N    A large safe prime (N = 2q+1, where q is prime)
  #      All arithmetic is done modulo N.
  # g    A generator modulo N
  # k    Multiplier parameter (k = H(N, g) in SRP-6a, k = 3 for legacy SRP-6)
  # s    User's salt
  # I    Username
  # p    Cleartext Password
  # H()  One-way hash function
  # ^    (Modular) Exponentiation
  # u    Random scrambling parameter
  # a,b  Secret ephemeral values
  # A,B  Public ephemeral values
  # x    Private key (derived from p and s)
  # v    Password verifier

my $srp = Crypt::SRP->new('RFC5054-4096bit', 'SHA256', 'hex');
my ($I, $P) = @ARGV;
my ($v, $s) = $srp->compute_verifier_and_salt($I, $P);
print "s=$s";
print "v=$v";
exit;
