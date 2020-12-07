#!/usr/bin/env perl
use strict;
use MIME::Base64;
use Crypt::ScryptKDF qw(scrypt_hash scrypt_raw scrypt_hex scrypt_b64);
use Crypt::CBC;
use Crypt::Cipher::AES;
use Digest::SHA qw(hmac_sha256_base64);
use utf8;
#use warnings  qw(FATAL utf8);    # Fatalize encoding glitches.
#use open      qw(:std :utf8);    # Undeclared streams in UTF-8.
#use charnames qw(:full :short);  # Unneeded in v5.16.

#use open ":encoding(utf8)";
#use open IN => ":encoding(utf8)", OUT => ":utf8";

#binmode(STDOUT, ":utf8");          #treat as if it is UTF-8
#binmode(STDIN, ":encoding(utf8)"); #actually check if it is UTF-8

use Encode 'decode';
$\ ="\n";

my ($iv, $salt, $encrypted) = map {decode_base64($_)} split /\|/, $ARGV[0];

my $password = $ARGV[1];

my $key = scrypt_raw($password, $salt,  16384, 8, 1, 32);

my $cbc = Crypt::CBC->new( -cipher=>'Cipher::AES', -key=>$key, -iv=>$iv, -literal_key => 1, -header=>'none');
my $msg = $cbc->decrypt($encrypted);
my $digest = hmac_sha256_base64($msg, $password);

print $msg;
print encode_base64($digest);

exit;
