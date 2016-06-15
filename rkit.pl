use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw|dirname|;
use File::Which;
use JSON;
use Data::Dumper;
use File::Path qw|make_path|;
use Config::Simple;
use Getopt::Long;

($\,$,) = ("\n","\t");
my $json = (new JSON)->utf8->pretty;

my $cd = dirname abs_path $0;
$cd =~ s#/+#\\#g; 
my $config = "$cd\\local-conf\\init.conf";
open my $OLDSTD, ">&STDOUT" or die "$!"; #OLDSTD -> STDOUT
GetOptions(
   'config=s' => \$config,
   'output:s' => sub{
      my $mylog = $_[1] || eval{
        my $mylog = "$cd\\logs";
        -d $mylog or mkdir $mylog or die "Can't mkdir $mylog:$!";
        return $mylog . '\\bkit.log';
      } or die "$@";
      my $localtime = localtime;
      print "$localtime => Output redirected to $mylog. Please check the result there";
      open STDOUT, ">$mylog" or die "Can't redirect output to $mylog:$!";
      open STDERR, ">&STDOUT" or die "Can't redirect stderr to stdout:$!";
    }
) or die "Sorry:$!";

print "Read configuration from $config";
-e $config or die "File $config not found";

my $cfg = new Config::Simple("$config") or die "File $config has a wrong configuration";
my $url = $cfg->param('url');
my $pass = $cfg->param('pass');
my $workdir = $cfg->param('workdir') || '.bkit';
$workdir =~ s#^([a-z]:)?(/|\\)*##i; #just in case. It should be a relative path to backup drive. Not an absolute path

my $location =  eval {
  local $/ = undef;
  my $endpoint = <>;
  $json->decode($endpoint);
} or die "Cannot decode input file: $@";

map{die "Missing location->{$_} component" unless defined $location->{$_}} (qw|drive backup computer path entry|);
my ($drive, $backup,$computer,$path,$entry) = @{$location}{qw|drive backup computer path entry|};
 
my $workpath = "$drive:\\$workdir";
-d $workpath or mkdir $workpath;
my ($logspath,$permspath) = map {-d $_ or mkdir $_; $_} map {"$workpath\\$_"} qw(logs perms);

my ($logfile,$tempacls,$logacls) = map {"$logspath\\$_"} qw(recv.log temp.acls apply-acls.log); 
my $aclsfile = "$permspath\\acls.txt";

my $fmt = q#'"%p|%t|%o|%i|%b|%l|%f"'#;

my $perl = which 'perl';
my $arch = lc Win32::GetArchName() || 'x86';
my $rsync = "$cd\\cygwin-$arch\\rsync.exe";
$rsync = which 'rsync' or die "Cannot find rsync $rsync" unless -e $rsync;

my $lpath = "$drive:/$path";                                  #local path
my $acls = $aclsfile;
$acls =~ s#\\+#/#g;															              #dos2linux
$acls =~ s#^([a-z]:)?/?##gi;										              #dos2linux and remove first slash

eval{
  -d $lpath or make_path $lpath; 
  $lpath =~ s#/+#\\#g;												                #linux2dos
  my $push = "$perl $cd\\bkit.pl $lpath\\$entry";							#First backup it to server
  print 'Backup before recovery';
  print qx|${push} 2>&1|;
  $? and die "The command $push exit with non zero value:$?\nSee file ${logfile} for details";
  my $exec = qq|${rsync} -rlitzvvhR --delete-delay --delay-updates --force --stats --fuzzy|
    .qq| --out-format=${fmt}|
    .qq| ${url}/${drive}/${backup}/./${acls}|							#SRC1: acls
    .qq| ${url}/${drive}/${backup}/./${path}/${entry}|		#SRC2: data
    .qq| /cygdrive/${drive}/|											        #DST
    .qq| 1>${logfile} 2>&1|;
  print "Recovery with command\n\t $exec";
  open my $handler, "|-", $exec; 									#Now we can restore it
  print $handler "${pass}\n\n";
  close $handler;
  $? and die "The rsync exit with non zero value:$?\nSee file ${logfile} for details";
  print "Filter out acls for entry $lpath\\$entry";
  print qx|$perl $cd\\filterAcls.pl $lpath\\$entry $aclsfile $tempacls 2>&1|;
  $? and die "Fail to filter out acls file $aclsfile to $tempacls";
  my $subinacl = "$cd\\3rd-party\\subinacl\\subinacl.exe";
  $subinacl = which 'subinacl' unless -e $subinacl;
  my $sub = qq|$subinacl /playfile $tempacls|;
  print "Apply acls with command $sub";
  qx|$sub 1>$logacls 2>&1|;
  $? and die "The command $sub exit with non zero value:$?\nSee logs for details";
  print "Backup again";
  print qx|${push} 2>&1|;								#push another backup to server	
  $? and die "The command $push exit with non zero value:$?\nSee logs for details";
  print "Done Recovery";
} or die "Die while executing rsync: $@";

END {
  open STDOUT, ">&",$OLDSTD or die "$!" if defined $OLDSTD;
  my $localtime = localtime;
  print "Done ($0) at $localtime";
}
