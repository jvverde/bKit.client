use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw|dirname|;
use File::Which;
use JSON;
use Data::Dumper;
use Win32;
use File::Path qw|make_path|;
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

my ($drive, $backup,$computer,$path,$entry) = @{$location}{qw|drive backup computer path entry|};

my $confdir = "$cd\\local-conf";
-d $confdir or die "$confdir not found";
my $cfg = new Config::Simple("$confdir\\init.conf") or die "File $confdir\\init.conf has a wrong configuration";
my $url = $cfg->param('url');
my $pass = $cfg->param('pass');

my $bkitDir = '.bkit.pt';
my $bkit = "$drive:\\$bkitDir";
-d $bkit or mkdir $bkit;
my ($logs,$perms,$vols) = map {-d $_ or mkdir $_; $_} map {"$bkit\\$_"} qw(logs perms vols);
my $acls = "$perms\\acls.txt";

my $fmt = q#"%t|%o|%i|%b|%l|%f"#;
if (defined $drive && defined $backup && defined $computer){
	my $lpath = "$drive:/$path";
	my ($prelog,$prerr,$rlog,$rerr,$poslog,$poserr) = map {"${logs}\\$_"} qw|pre.log pre.err recv.log recv.err pos.log pos.err|;
	eval{
		-d $lpath or make_path $lpath; 
		$lpath =~ s#/#\\#g;												          #linux2dos
		my $push = "$perl $cd\\bkit.pl $lpath\\$entry";							#First backup it to server
		qx|${push} 2>$prerr 1>$prelog|;
		$? == 0 or die "The command $push exit with non zero value:$?\nSee file $prerr for details";
		my $r = qq|${rsync} -rlitzvvhR --no-perms --delete-delay --delay-updates --force --stats --fuzzy|
			.qq| --out-format=${fmt}|
			.qq| ${url}/${drive}/${backup}/./${path}/${entry} /cygdrive/${drive}/|
			.qq| 2>$rerr 1>$rlog|;
		open my $handler, "|-", $r; 									#Now we can restore it
		print $handler "${pass}\n\n";  
		qx|${push} 2>$poserr 1>$poslog|;								#push another backup to server	
		$? == 0 or die "The command $push exit with non zero value:$?\nSee file $poserr for details";
	} or die "Die while executing rsync: $@";
}

END {
	print 'rkit done';
}
