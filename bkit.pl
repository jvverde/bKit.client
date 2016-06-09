use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw |dirname|;
use File::Which;
use JSON;
use Data::Dumper;
use Win32;
#use Win32::DriveInfo;
use Sys::Hostname;
use Net::Domain qw|hostfqdn hostdomain|;
use Config::Simple;
#https://github.com/candera/shadowspawn
use File::Path qw|make_path|;

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

my $dir = shift or die 'You must specify a directory';
my ($drive,$path) = ($dir =~ /^([a-z]):(.*)$/i) or die 'You must include drive letter in directory';
$drive = uc $drive;
$path =~ s/^[^\\]?/\\$&/; #garante um backslash no inicio do path
$path =~ s/[\\]/\//g;    #dos->unix 

my $cd = dirname abs_path $0;
my $confdir = "$cd\\local-conf";
-d $confdir or die "$confdir not found";
my $cfg = new Config::Simple("$confdir\\init.conf") or die "File $confdir\\init.conf not found";
my $url = $cfg->param('url');
my $pass = $cfg->param('pass');
my $bkitDir = $cfg->param('histofile') || '.bkit';
$bkitDir =~ s#^([a-z]:)?(/|\\)*##i; #just in case. It should be a relative path to backup drive. Not an absolute path

my $bkit = "$drive:\\$bkitDir";
-d $bkit or make_path $bkit;
my ($logs,$perms,$vols) = map {-d $_ or mkdir $_; $_} map {"$bkit\\$_"} qw(logs perms vols);

my $perl = which 'perl';
my $vssadmin = which 'vssadmin';


my $subinacl = "$cd\\3rd-party\\subinacl\\subinacl.exe";
$subinacl = which 'subinacl' unless -e $subinacl;
my $acls = "$perms\\acls.txt";
my $mtime = (stat $acls)[9] if -e $acls;
$mtime //= 0;
my $aclstimeout = $cfg->param('aclstimeout') || 3600*24*8;
print qx|$subinacl /noverbose /output=$acls /subdirectories $drive:\\| 
  if -e $subinacl and (time - $mtime) > $aclstimeout;

my $lsv = qx|$perl $cd\\getvol.pl| or die "Error code $?";
saveData "$vols\\volumes.txt", $lsv;

my $devId = drive2DevId $drive, $lsv or die "Cannot get DeviceId for drive $drive:$!";
system qq|$perl $cd\\csc.pl $drive| and die "Cannot create shadow copy, Error value: $? ($!)";
my $lsh = qx|$perl $cd\\lsh.pl| or die "Error code $? ($!)";
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
  open my $handler, "|-"
    ,qq|${rsync} -rlitzvvhR --chmod=ugo=rwX --inplace --delete-delay --force --delete-excluded --stats --fuzzy|
    .qq| --exclude-from=$cd\\conf\\excludes.txt|
    .qq| --out-format=${fmt}|
    .qq| /proc/sys/Device/${shcN}/${bkitDir}/../.${path} ${url}/{$drive}/current/|
    .qq| 1>${bkit}\\logs\\send.log 2>&1|;
  print $handler "${pass}\n\n";
}

END {
  if (defined $lastVssKey){
    my $last = $cvss->{$lastVssKey}->{id};
    print qx|$vssadmin Delete Shadows /Shadow=$last /Quiet|;
  }
}
