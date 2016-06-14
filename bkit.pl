use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw|dirname|;
use File::Path qw|make_path|;
use File::Which;
use JSON;
use Data::Dumper;
use Config::Simple;
use Getopt::Long;

#https://github.com/candera/shadowspawn See later

($\,$,) = ("\n","\t");
my $json = (new JSON)->utf8->pretty;


sub saveData{
  my ($file,$data) = @_;
  open my $fhv, ">$file" or (warn "Cannot save info to $file" and return undef);
  print $fhv $data; 
  close $fhv;
  return $data;
} 
sub drive2DevId{
  my ($drive,$lsv) = @_;
  my $volumes = $json->decode($lsv) or die "Not json:$!";
  my ($volume) = grep{defined $_->{DriveLetter} and uc $_->{DriveLetter} eq "$drive:"} @$volumes;
  return $volume->{DeviceID};
}
sub getShadowCopies{
  my ($volume,$lsh) = @_;
  my $shadows = $json->decode($lsh) or die "Not json:$!";
  return undef unless defined $shadows->{InstallDate} and defined $shadows->{DeviceObject} and defined $shadows->{VolumeName};
  my $volumes = $shadows->{VolumeName};
  return {map {
    $shadows->{InstallDate}->[$_] => {
      volume => $shadows->{DeviceObject}->[$_]
      ,id => $shadows->{ID}->[$_]
    }
  } grep {defined $volumes->[$_] and $volumes->[$_] eq $volume} 0..$#{$volumes}};
}

my $cd = dirname abs_path $0;
my $config = "$cd\\local-conf\\init.conf";
open my $OLDSTD, ">&STDOUT" or die "$!";
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
my $cfg = new Config::Simple($config) or die "Can't parse file $config";
my $url = $cfg->param('url');
my $pass = $cfg->param('pass');
my $workdir = $cfg->param('workdir') || '.bkit';
$workdir =~ s#^([a-z]:)?(/|\\)*##i; #just in case. It should be a path relative to backup drive. Not an absolute path

my $dir = shift or die 'You must specify a directory';
-e $dir or die "The entry $dir doesn't exist";
my ($drive,$path) = ($dir =~ /^([a-z]):(.*)$/i) or die 'You must include drive letter in directory specification';
$drive = uc $drive;
$path =~ s#^[\\]+##; #removes any backslash from begin of path
$path =~ s#[\\]+#/#g; #dos->unix and remove backslash duplicates

my $workpath = "$drive:\\$workdir";
-d $workpath or make_path $workpath;
#paths to be used won windows
my ($logspath,$permspath,$volspath) = map {-d $_ or mkdir $_; $_} map {"$workpath\\$_"} qw(logs perms vols);
#dirs to be used on rsync
my ($logsdir,$permsdir) = map{s#[\\]+#/#g;$_} map {"$workdir/$_"} qw(logs perms);

#logfiles
my ($bkitlog,$sendlog) = map{"$logspath\\$_"} qw(bkit.log send.log);
unlink $bkitlog if -e $bkitlog;

my $subinacl = "$cd\\3rd-party\\subinacl\\subinacl.exe";
$subinacl = which 'subinacl' unless -e $subinacl;
my $acls = "$permspath\\acls.txt";
my $mtime = (stat $acls)[9] if -e $acls;
$mtime //= 0;
my $aclstimeout = $cfg->param('aclstimeout') || 3600*24*8;
qx|$subinacl /noverbose /output=$acls /subdirectories $drive:\\ 1>>$bkitlog 2>&1|
  if -e $subinacl and (time - $mtime) > $aclstimeout;

my $perl = which 'perl';

my $lsv = qx|$perl $cd\\getVolumes.pl  2>>$bkitlog|;
$? and die "Cannot get volumes. Error code: $?";
saveData "$volspath\\volumes.txt", $lsv;

my $devId = drive2DevId $drive, $lsv or die "Cannot get DeviceId for drive $drive:$!";

qx|$perl $cd\\createShadowCopy.pl $drive 1>>$bkitlog 2>&1|;
$? and die "Cannot create shadow copy, Error value: $?";

my $lsh = qx|$perl $cd\\listShadows.pl 2>>$bkitlog|;
$? and die "Cannot list shadow copies. Error code $?";

my $cvss = getShadowCopies $devId, $lsh;
die 'Cannot get shadow Copies' unless defined $cvss and scalar %$cvss;
my $lastVssKey = pop @{[sort keys %$cvss]};
my $cur = $cvss->{$lastVssKey}->{volume};

my $fmt = q#'"%p|%t|%o|%i|%b|%l|%f"'#;
my $arch = lc Win32::GetArchName() || 'x86';
my $rsync = "$cd\\cygwin-$arch\\rsync.exe";
$rsync = which 'rsync' or die "Cannot find rsync" unless -e $rsync;

if (defined $cur){
  my ($shcN) = $cur =~ /(HarddiskVolumeShadowCopy\d+)/;
  my $exec = qq|${rsync} -rlitzvvhR --chmod=D750,F640 --inplace --delete-delay --force --delete-excluded --stats --fuzzy|
    .qq| --exclude-from=$cd\\conf\\excludes.txt|
    .qq| --out-format=${fmt}|
    .qq| /proc/sys/Device/${shcN}/${workdir}/.././${logsdir}|          #src1	=> logs from previous run
    .qq| /proc/sys/Device/${shcN}/${workdir}/.././${permsdir}|         #src2	=> acls
    .qq| /proc/sys/Device/${shcN}/${workdir}/.././${path}|             #src3	=> the real data
    .qq| ${url}/${drive}/current/|                                     #dst
    .qq| 1>${sendlog} 2>&1|;
  print "Go to run\n\t $exec";
  open my $handler, "|-",$exec;
  print $handler "${pass}\n\n";
  close $handler;
  die "Error while runing rsync:$?" if $?;
  print "Done rsync";
}

END {
  my $exit = $?;
  eval{
    my $last = $cvss->{$lastVssKey}->{id};
    my $vssadmin = which 'vssadmin' or die "Cannot found vssadmin";
    qx|$vssadmin Delete Shadows /Shadow=$last /Quiet 1>>$bkitlog 2>&1| // die "Cannot delete shadows";
  } // warn "$@" if defined $lastVssKey;
  close $bkitlog;
  open STDOUT, ">&",$OLDSTD or die "$!" if defined $OLDSTD;
  my $localtime = localtime;
  print "Done ($0) at $localtime" and exit unless $exit;
  print "Error ($0) at $localtime";
  exit($exit);
}

