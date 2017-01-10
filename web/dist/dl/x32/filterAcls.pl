use strict;
use warnings;

my ($entry,$aclfile,$result) = @ARGV[0..2];

my $sep = quotemeta "+File $entry";
my $rei = qr/$sep/i;
my $reo = qr/===+/i;
open my $in, "<:raw:encoding(UTF-16LE)",$aclfile or die "Can't open file $aclfile:$!";
open STDOUT, ">:raw:encoding(UTF-16LE)",$result or die "Can't open file $result:$!" if $result;
binmode STDOUT, ':raw:encoding(UTF-16LE)';
my $match = 0;
my $last = '';
my $input;
while($input = <$in>){
  if ($input =~ $rei){
    $match = 1;       #start the match state
    print $last;      #print the '=' sequence which occurs before the +File Dir line
    print $input;     #print the line
    $input = <$in>;   #goto next line which should be another sequence of '=', so the $reo RE won't match the next line
    last unless defined $input;
  }elsif($input =~ $reo){ #stop the match state when found a sequence of '='
    $match = 0;
  }
  if ($match){            #in match state print the line
    print $input
  }
  $last = $input;
};