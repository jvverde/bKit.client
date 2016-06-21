use strict;
use warnings;
use Tk;
use IO::Handle;

sub fill {
  die 'hard';
  my ($w) = @_;
  my $text =<H>;
  $w->insert('end',$text);
  $w->yview('end');
}

$| = 1;


my $main = MainWindow->new;

my $t = $main->Scrolled('Text', -wrap=>'none')->pack(-expand=>1);
open(H,"cat gui.pl 2>&1 |") or die $!;

if (fork){
  MainLoop;
}else{
  open(H,"cat gui.pl 2>&1 |") or die $!;
  while(<H>){
    $t->insert('end',$_);
    $t->yview('end'); 
  }
  close H;
  <>;
}
#close H;



