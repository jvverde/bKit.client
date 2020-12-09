#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use IO::Prompter [ -stdio ];
use REST::Client;
use Getopt::Long;
use Data::Dumper;

$\="\n";
my $directory = dirname( $0 );
my $schema = 'https';
my $port = '8766';
my $server = undef;

my $options = {
  port => \$port,
  schema => \$schema,
  server => \$server
};

GetOptions ($options, 'port|p=i', 'schema=s', 'server|s=s');

my ($user, $pass) = @ARGV;


print Dumper $options;

$user = prompt('User:') unless $user;
$pass = prompt('Password:', -echo => '*') unless $pass;
$server = prompt('Server:') unless $server;

my $host=qq|$schema://$server:$port/|;
print "url=$host";

exit;
my $client = REST::Client->new();

$client->setCa(qq|$directory/../certs/bkitCA.crt|);

$client->setHost($host);

$client->GET(qq|/v1/auth/check/$user|);
print $client->responseContent();

