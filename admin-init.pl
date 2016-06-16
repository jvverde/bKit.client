use strict;
use warnings;
use Win32;

my ($cd) = Win32::GetFullPathName( $0 );
unshift @ARGV,"${cd}init.pl";
do "${cd}runasadmin.pl";
$@ and die qq|Error: "$@" ($!)|;
