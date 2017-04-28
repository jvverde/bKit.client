#!/usr/bin/env perl
use Data::Dumper;
use utf8;
use strict;

$/ = "\n";
undef $\;

my @lines = grep {/".+"$/} <>;

print Dumper [@lines];