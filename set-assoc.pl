use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw |dirname|;
use File::Which;
use Data::Dumper;
use Config::Simple;

($\,$,) = ("\n","\t");

my $script = shift or do {print "Usage:\n\t$0 script ext"; exit};
my $ext = shift or do {print "Usage:\n\t$0 script ext"; exit};

my $cd = dirname abs_path $0;

my $perl = which 'perl';

print qx|Assoc .$ext=rsync|;
print qx|Ftype rsync=$perl $cd\\$script \%1|;

