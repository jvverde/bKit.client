use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw |dirname|;
use File::Which;
use JSON;
use Data::Dumper;
use Win32;
use Config::Simple;

($\,$,) = ("\n","\t");
my $json = (new JSON)->utf8->pretty;

my $server = shift or do {print "Usage:\n\t$0 server-address"; exit};

sub saveData{
  my ($file,$data) = @_;
  open my $fhv, ">$file" or (warn "Cannot save info to $file" and return undef);
  print $fhv $data; 
  close $fhv;
  return $data;
} 

my $cd = dirname abs_path $0;
my $sysDir = "$cd\\sysInfo";
my $logDir = "$cd\\logs";
my $confDir = "$cd\\local-conf";
-d $sysDir or mkdir $sysDir;
-d $logDir or mkdir $logDir;
-d $confDir or mkdir $confDir;
my $wmiFile = "$sysDir\\wmi.info"; 
my $sysFile = "$sysDir\\sys.info";

my $perl = which 'perl';

my $arch = lc Win32::GetArchName() || 'x86';
my $rsync = "$cd\\cygwin-$arch\\rsync.exe";
$rsync = which 'rsync' or die "Cannot find rsync $rsync" unless -e $rsync;


my $osversion = [Win32::GetOSVersion()];
my $sysInfo = {
  version => $osversion
  ,displayName => Win32::GetOSDisplayName()
  ,arch => Win32::GetArchName()
  ,chip => Win32::GetChipName()
  ,oem => Win32::GetOEMCP()
  ,nodeName => Win32::NodeName() || '_'
  ,domainName => Win32::DomainName() || '_'
  ,product => Win32::GetProductInfo($osversion->[1], $osversion->[2], $osversion->[5], $osversion->[6])
  ,osName => ''.Win32::GetOSName() .''
};

saveData $sysFile, $json->encode($sysInfo);
 
my $wmi = qx|$perl $cd\\getinfo.pl|;
die "Cannot launch $cd\\getinfo.pl:$!" unless defined $wmi;
die "Error while running $cd\\getinfo.pl:$wmi($?)\n" if $?;

saveData $wmiFile, $wmi;

my $wmiInfo = $json->decode($wmi) or die "Cannot decode json data saved in $wmiFile";
defined $wmiInfo->{Win32_ComputerSystemProduct} or die "Win32_ComputerSystemProduct not defined in $wmiInfo";
defined $wmiInfo->{Win32_ComputerSystemProduct}->{UUID} or die "Win32_ComputerSystemProduct not defined in $wmiInfo";

my $uuid = $wmiInfo->{Win32_ComputerSystemProduct}->{UUID} || '_';
my $name = $sysInfo->{nodeName};
my $domain = $sysInfo->{domainName}; 

my $cfg = new Config::Simple(syntax=>'http');
$cfg->param('url',"rsync://user\@${server}:8733/${domain}.${name}.${uuid}");
$cfg->param('pass','us3r');
$cfg->save("$confDir\\init.conf") or die "Error while saving init.conf file to $confDir";

my $path = $sysDir;
$path =~ s/[\\]/\//g; #dos->unix
$path =~ s/^([a-z]):/\/cygdrive\/$1/i;

my $init = qq|${rsync} -rltvvhR --inplace --stats |
  .qq| ${path}/./ rsync://admin\@${server}:8733/bkit.me/win/${domain}/${name}/${uuid}|
  .qq| 2>${logDir}\\err.txt >${logDir}\\logs.txt|
;

print qx|$init|;

