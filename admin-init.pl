use strict;
use warnings;

unshift @ARGV,'init.pl';
do 'runasadmin.pl';
$@ and die qq|Error: "$@" ($!)|;
