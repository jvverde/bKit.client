use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw |dirname|;
use File::Which;
use Data::Dumper;
use Config::Simple;

($\,$,) = ("\n","\t");

my $server = shift or do {print "Usage:\n\t$0 server-address"; exit};

my $cd = dirname abs_path $0;

my $perl = which 'perl';
my $assoc = which 'Assoc';
my $ftype = which 'Ftype';

print $perl;
print $assoc;
print $ftype;





