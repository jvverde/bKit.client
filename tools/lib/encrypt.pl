#!/usr/bin/env perl
use strict;
use MIME::Base64;
use Crypt::ScryptKDF qw(scrypt_raw);
use Crypt::CBC;
use Crypt::Cipher::AES;
use Digest::SHA qw(hmac_sha256_base64);
use Crypt::Random qw( makerandom makerandom_octet ); 
use utf8;

use Encode 'decode';
$\ ="\n";

my ($msg, $password) = @ARGV;

my $salt = makerandom_octet ( Length => 16, Strength => 1 ); 

my $key = scrypt_raw($password, $salt,  16384, 8, 1, 32);

my $iv = makerandom_octet ( Length => 16, Strength => 1 ); 

my $cbc = Crypt::CBC->new( -cipher=>'Cipher::AES', -key=>$key, -iv=>$iv, -literal_key => 1, -header=>'none');
my $encrypt = $cbc->encrypt($msg);
#my $digest = hmac_sha256_base64($msg, $password);

print join '|', map {chomp; $_} map { encode_base64($_) } ($iv, $salt, $encrypt);

exit;
