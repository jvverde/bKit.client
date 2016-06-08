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

($\,$,) = ("\n","\t");
my $json = (new JSON)->utf8->pretty;

my $perl = which 'perl';
my $cd = dirname abs_path $0;

my $arch = lc Win32::GetArchName() || 'x86';
my $rsync = "$cd\\cygwin-$arch\\rsync.exe";
$rsync = which 'rsync' or die "Cannot find rsync $rsync" unless -e $rsync;

my $location =  eval {
  local $/ = undef;
  my $endpoint = <>;
  $json->decode($endpoint);
} or die "Cannot decode input file: $@";

my ($drive, $backup,$computer,$path) = @{$location}{qw|drive backup computer path|};

my $confdir = "$cd\\local-conf";
-d $confdir or die "$confdir not found";
my $cfg = new Config::Simple("$confdir\\init.conf") or die "File $confdir\\init.conf has a wrong configuration";
my $url = $cfg->param('url');
my $pass = $cfg->param('pass');

my $bkitDir = '.bkit.me';
my $bkit = "$drive:\\$bkitDir";
-d $bkit or mkdir $bkit;
my ($logs,$perms,$vols) = map {-d $_ or mkdir $_; $_} map {"$bkit\\$_"} qw(logs perms vols);
my $acls = "$perms\\acls.txt";



my $fmt = q#"%t|%o|%i|%l|%b|%f"#;
if (defined $drive && defined $backup && defined $computer){
  my $r = qq|${rsync} -rlitzvvhR --chmod=ugo=rwX --inplace --delete-after --force --delete-excluded --stats --fuzzy|
	.qq| --skip-compress=gz/zip/z/rpm/deb/iso/bz2/t[gb]z/7z/mp[34]/mov/avi/ogg/jpg/jpeg|
	.qq| --out-format=${fmt}|
    .qq| ${url}/${drive}/${backup}/./${path} /cygdrive/${drive}/|
    .qq| 2>${bkit}\\logs\\recv-err.txt >${bkit}\\logs\\recv-logs.txt|;
  print $r;
  open my $handler, "|-", $r;
  print $handler "${pass}\n\n";  
}

END {

}
