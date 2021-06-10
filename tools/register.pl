#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use IO::Prompter [ -stdio ];
use REST::Client;
use Getopt::Long;
use JSON::Tiny qw(decode_json encode_json);
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

my ($user, $email, $pass) = @ARGV;

$user = prompt('User:') unless $user;
$email = prompt('Email:') unless $email;
$pass = prompt('Password:', -echo => '*') unless $pass;
$server = prompt('Server:') unless $server;

my $host=qq|$schema://$server:1$port/|;

my $client = REST::Client->new();
$client->setCa(qq|$directory/../certs/bkitCA.crt|);
$client->addHeader('Content-Type', 'application/json');
$client->addHeader('Accept', 'application/json');
$client->setHost($host);

my $response, $rcode, $rok;

$client->GET(qq|/v1/auth/check/$user|);
($response, $rcode) = ($client->responseContent(), $client->responseCode());
die "Can't check '$user' on '$host'\nresponse was: $response" if 200 != $rcode; 

my $check = decode_json( $client->responseContent() );
die "'$user' is not available" unless $check->{message} eq 'available';

my $requestData = encode_json({ username => $user, eemail => $email });

$client->POST(qq|/v1/auth/request|, $requestData) or die "Can't request '$requestData'";
my $request = decode_json( $client->responseContent() );
#die "'$user' is not available" unless $request->{message} eq 'available';

print Dumper $request;
