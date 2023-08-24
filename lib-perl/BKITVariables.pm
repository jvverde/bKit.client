package BKITVariables;

use strict;
use warnings;

sub chompIt{
    my ($s) = @_; 
    chomp $s;
    return $s;
}

sub _bkit_export_variables {
    return if $ENV{__BKIT_VARS_INITIALIZED};

    my @rsyncoptions = (
        '--exclude="/proc/kcore"',
    );

    my $os = lc chompIt(qx/uname -o/);

    $ENV{OS} = $os;
    $ENV{BKITCYGWIN} = chompIt(qx/uname -a/) if $os =~ /cygwin/i;

    if ($ENV{BKITCYGWIN} && `id -G` =~ /\b544\b/) {
        my $admin = `wmic PATH win32_UserAccount where "sid like 'S-1-5-21%%-500'" get Name`;
        $admin =~ s/\r//g;        # Remove CR
        $admin =~ s/\s+$//;       # Clean trailing spaces
        $admin =~ s/.*\n//;       # Remove header line
        $admin ||= "Administrator";

        $ENV{BKITISADMIN} = "YES";
        $ENV{BKITUSER} = $admin;
    } else {
        $ENV{BKITUSER} = chompIt qx/id -nu/;
    }

    $ENV{RSYNCOPTIONS} //= '';
    $ENV{RSYNCOPTIONS} .= ' --exclude="/proc/kcore" ';
    $ENV{__BKIT_VARS_INITIALIZED} = 1;
}

_bkit_export_variables();

unless (caller()) {
    print "BKITUSER=$ENV{BKITUSER}\n";
    print "OS=$ENV{OS}\n";
    print "BKITCYGWIN=$ENV{BKITCYGWIN}\n" if $ENV{BKITCYGWIN};
    print "BKITISADMIN=$ENV{BKITISADMIN}\n" if $ENV{BKITISADMIN};
}

1;
