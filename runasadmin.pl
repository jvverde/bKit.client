use strict;
use warnings;
use Win32::OLE;
use File::Basename qw|dirname|;
use Cwd qw|abs_path|;
use File::Which;

my $shell = Win32::OLE->new('Shell.Application');

my $perl = which 'perl';
my $cd = dirname abs_path $0;
$cd =~ s#/+#\\#g; 

s/"/\\"/g foreach (@ARGV);
my $args = join '" "', @ARGV;

$shell->ShellExecute($perl, qq|"$args"|,$cd,'runas');