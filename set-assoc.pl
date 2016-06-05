use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw |dirname|;
use File::Which;
#See
#https://github.com/dk/Prima
#http://stackoverflow.com/questions/1015699/perl-modules-for-creating-a-simple-microsoft-windows-gui
#http://search.cpan.org/dist/IUP/lib/IUP.pod
#http://www.cavapackager.com/
#http://www.arl.wustl.edu/projects/fpx/references/perl/cookbook/ch15_16.htm

($\,$,) = ("\n","\t");

my $script = shift or do {print "Usage:\n\t$0 script [ext]"; exit};
my $ext = shift || 'rsync';

my $cd = dirname abs_path $0;

my $perl = which 'perl';

print qx|Assoc .$ext=rsync|;
print qx|Ftype rsync=$perl $cd\\$script \%1|;

