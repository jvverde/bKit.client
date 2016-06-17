use strict;
use warnings;
use Cwd qw|abs_path|;
use File::Basename qw |dirname|;
use File::Which;
use JSON;
use Data::Dumper;
use Win32;
use Config::Simple;
use Getopt::Long;
use Pod::Usage;

($\,$,) = ("\n","\t");
my $json = (new JSON)->utf8->pretty;

my $man = 0;
my $help = 0;
my $server = 'bkit';
my $port = 8733;
my $user = 'user';
my $section = 'bkit';
my $pass = 'us3r';
my $workdir = '.bkit';
my $aclstimeout = 3600*24*8; #8 days
GetOptions(
  'help|?' => \$help, 
   man => \$man,
   'server|s=s' => \$server,
   'port=i' => \$port,
   user => \$user,
   pass => \$pass,
   section => \$section,
   workdir => \$workdir,
   aclstimeout => \$aclstimeout
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $man;
   
sub saveData{
  my ($file,$data) = @_;
  eval{
    open my $fhv, ">$file" or die "Cannot save info to $file";
    print $fhv $data; 
    close $fhv;
  } // warn "Warning:$@";
} 

my $cd = dirname abs_path $0;
$cd =~ s#/+#\\#g; 
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
$? and die "Error while running $cd\\getinfo.pl:$wmi($?)\n";

saveData $wmiFile, $wmi;

my $wmiInfo = $json->decode($wmi) or die "Cannot decode json data saved in $wmiFile";
defined $wmiInfo->{Win32_ComputerSystemProduct} or die "Win32_ComputerSystemProduct not defined in $wmiInfo";
defined $wmiInfo->{Win32_ComputerSystemProduct}->{UUID} or die "Win32_ComputerSystemProduct not defined in $wmiInfo";

my $uuid = $wmiInfo->{Win32_ComputerSystemProduct}->{UUID} || '_';
my $name = $sysInfo->{nodeName};
my $domain = $sysInfo->{domainName}; 

my $path = $sysDir;
$path =~ s/[\\]/\//g; #dos->unix
$path =~ s/^([a-z]):/\/cygdrive\/$1/i;

my $exec = qq|${rsync} -rltvvhR --inplace --stats |
  .qq| ${path}/./ rsync://admin\@${server}:${port}/${section}/win/${domain}/${name}/${uuid}|
;

print "Executing:\n\t$exec\n";

print qx|$exec 2>&1|;
$? and die "Exit value of rsync is non null: $?";


my $cfg = new Config::Simple(syntax=>'http');
$cfg->param('url',"rsync://${user}\@${server}:${port}/${domain}.${name}.${uuid}");
$cfg->param('pass',$pass);
$cfg->param('workdir',$workdir);
$cfg->param('aclstimeout',$aclstimeout);


$cfg->save("$confDir\\init.conf") or die "Error while saving init.conf file to $confDir";

print "Saved configuration to $confDir\\init.conf";

print qx|$perl $cd\\set-assoc.pl $cd\\admin-rkit.pl -o $cd\\logs\\rkit.log|;
$? and die "Exit value of set-assoc.pl is non null: $?";

print "Associated bkit extension with rkit";

END{
  print 'Init finished ' . ($? ? "abormally: $?": 'successfully');
  print 'Press ENTER to continue...';
  <>;
  print 'Bye';
}
__END__

=pod

=head1 NAME
bkit - Usage

=head1 SYNOPSIS

  init [options]
    Options:
      -help            brief help message
      -man             full documentation
      server           server name or ip address, Default:bkit
      port             port number, Default:8733
      user             rsync user for the backup, Default: user
      pass             rsync pass 
      section          rsyncd.conf section, Default: bkit 

=head1 OPTIONS

=over 4

=item B<-help>
Print a brief help message and exits.

=item B<-man>
Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> inits the client side for a bkit server.

=cut

