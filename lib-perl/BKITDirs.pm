#!/usr/bin/perl
package BKITDirs;

use strict;
use warnings;
use File::Basename;
use File::Path qw(make_path);
use Cwd;
use Exporter qw(import);
use FindBin qw($RealBin);
use lib "$RealBin"; #for testing purposals, running perl module directly
use BKITVariables;
use WMICaller qw(invoke_wmi get_wmi);

sub _bkit_set_dirs {
    return if $ENV{VARDIR} and -e $ENV{VARDIR} and $ENV{ETCDIR} and -e $ENV{ETCDIR};

    my $user = $ENV{BKITUSER} || getpwuid($<);
    my $uid = getpwnam($user);
    my $homedir = (getpwuid($uid))[7] if $uid;

    if (exists $ENV{BKITCYGWIN}) {
        unless ($homedir) {
            my $SID = get_wmi('win32_UserAccount', 'Name', $user, 'SID');
            $homedir = get_wmi('win32_UserProfile', 'SID', $SID, 'LocalPath');
        }
        if (exists $ENV{BKITISADMIN} && !$homedir) {
            $homedir = get_wmi('win32_UserProfile', 'SID', 'S-1-5-21%%-500', 'LocalPath');
            $homedir = $ENV{ALLUSERSPROFILE} . '/bkit-admin' if !$homedir and $ENV{ALLUSERSPROFILE};
            $homedir = $ENV{ProgramData} . '/bkit-admin' if !$homedir and $ENV{ProgramData};
        }
        $homedir = qx(cygpath -u "$homedir");
        chomp $homedir;
        my $homedirW = qx(cygpath -w "$homedir");
        chomp $homedirW;
        $ENV{BKIT_HOMEDIR_WINDOWS} = $homedirW;
    }

    $homedir ||= $ENV{HOME} || "/home/$user";
    unless (-e $homedir) {
         make_path($homedir);
    }

    $ENV{BKIT_HOMEDIR} = $homedir;
    $ENV{VARDIR} = "$homedir/.bkit/var";
    $ENV{ETCDIR} = "$homedir/.bkit/etc";

    if (Cwd::abs_path($homedir) ne Cwd::abs_path("/home/$user")) {
        rename("/home/$user", "/home/${user}.old") if -e "/home/$user";
        symlink($homedir, "/home/$user");
    }
}

_bkit_set_dirs();

unless (caller()) {
    print "$ENV{VARDIR}\n";
    print "$ENV{ETCDIR}\n";
}

1; # Module should return a true value
