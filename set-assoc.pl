use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename;
use File::Which;
#See
#https://github.com/dk/Prima
#http://stackoverflow.com/questions/1015699/perl-modules-for-creating-a-simple-microsoft-windows-gui
#http://search.cpan.org/dist/IUP/lib/IUP.pod
#http://www.cavapackager.com/
#http://www.arl.wustl.edu/projects/fpx/references/perl/cookbook/ch15_16.htm

($\,$,) = ("\n","\t");

my $cd = dirname abs_path $0;

my $script = shift or do {print "Usage:\n\t$0 script ..."; exit};
my $args = join ' ', @ARGV;
my $ext = 'bkit';

$script = abs_path "$cd\\$script" if dirname($script) !~ m#^(?:[a-z]:)?(?:/|\\)#i;
$script =~ s#/+#\\#g; 

my $perl = which 'perl';
-e $perl or die "Can't find $perl";
-e $script or die "Can't find $script";

print qx|Assoc .$ext=bkit|;
print qx|Ftype bkit=$perl $script $args \%1|;

