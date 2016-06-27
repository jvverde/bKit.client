use strict;
use Digest::MD5;

my $md5 = Digest::MD5->new;
while (<>) {
	$md5->add($_);
}
print $md5->hexdigest;