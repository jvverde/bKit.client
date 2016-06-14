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

my $bkitDir = '.bkit';
my $bkit = "$drive:\\$bkitDir";
-d $bkit or mkdir $bkit;
my ($logs,$perms,$vols) = map {-d $_ or mkdir $_; $_} map {"$bkit\\$_"} qw(logs perms vols);

my $fmt = q#'"%p|%t|%o|%i|%b|%l|%f"'#;
if (defined $drive && defined $backup && defined $computer && defined $entry){
	my $lpath = "$drive:/$path";
	my $logfile = "${logs}\\recv.log";
	my $acls = "$perms/acls.txt";
	$acls =~ s#\\+#/#g;															#dos2linux
	$acls =~ s#^[a-z]:/?##gi;															#dos2linux

	eval{
		-d $lpath or make_path $lpath; 
		$lpath =~ s#/+#\\#g;												    #linux2dos
		my $push = "$perl $cd\\bkit.pl $lpath\\$entry";							#First backup it to server
		print qx|${push} 2>&1|;
		$? == 0 or die "The command $push exit with non zero value:$?\nSee file ${logfile} for details";
		my $r = qq|${rsync} -rlitzvvhR --delete-delay --delay-updates --force --stats --fuzzy|
			.qq| --out-format=${fmt}|
			.qq| ${url}/${drive}/${backup}/./${acls}|							#SRC1: acls
			.qq| ${url}/${drive}/${backup}/./${path}/${entry}|		#SRC2: data
			.qq| /cygdrive/${drive}/|											        #DST
			.qq| 1>${logfile} 2>&1|;
		open my $handler, "|-", $r; 									#Now we can restore it
		print $handler "${pass}\n\n";
    print qx|$perl $cd\\filterAcls.pl $lpath\\$entry $perms\\acls.txt $logs\\temp.acls|;
    my $subinacl = "$cd\\3rd-party\\subinacl\\subinacl.exe";
    $subinacl = which 'subinacl' unless -e $subinacl;
    qx|$subinacl /playfile $logs\\temp.acls  1>$logs\\apply-acls.log 2>&1|;
		print qx|${push} 2>&1|;								#push another backup to server	
		$? == 0 or die "The command $push exit with non zero value:$?\nSee file ${logfile} for details";
    
	} or die "Die while executing rsync: $@";
}

END {
	print 'rkit done';
}
