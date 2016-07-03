#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")	#Full DIR
section=bkit
port=8733
user=us3r
workdir=.bkit
aclstimeout=3600*24*8
SERVER=$1

uuid="$(wmic csproduct get uuid /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~ /uuid/ {print $2}' | sed '#\r+##g') "
domain="$(wmic computersystem get domain /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /domain/ {print $2}' | sed '#\r+##g')"
name="$(wmic computersystem get name /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /name/ {print $2}' | sed '#\r+##g')"
echo "$uuid"
echo "$domain"
echo "$name"
MANIFDIR="$DIR/run"
##$DIR/manif.sh > $MANIF/manif.txt
RSYNC=$(find $DIR -type f -name "rsync.exe" -print | head -n 1)
#echo $RSYNC

${RSYNC} -rltvvhR --inplace --stats ${MANIFDIR}/./ rsync://admin\@${SERVER}:${port}/${section}/win/${domain}/${name}/${uuid}

[ "$?" -ne "0" ] &&  echo "Exit value of rsync is non null: $?" && exit 1

exit

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

