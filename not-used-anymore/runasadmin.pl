use strict;
use warnings;
use Win32::OLE;
use File::Basename qw|dirname|;
use Cwd qw|abs_path|;
use File::Which;

my $shell = Win32::OLE->new('Shell.Application') or die "Can't create a Shell.Application: '$!'";

my $perl = which 'perl' or die "Can't find perl";

s/"/\\"/g foreach (@ARGV);
my $args = join '" "', @ARGV;

$shell->ShellExecute($perl, qq|"$args"|,undef,'runas');