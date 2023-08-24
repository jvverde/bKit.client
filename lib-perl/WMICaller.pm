package WMICaller;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(invoke_wmi get_wmi);

my $powershell_available;

sub _PSexist {
    return $powershell_available if defined $powershell_available;
    return $powershell_available = system("powershell.exe -Command exit") == 0;
}

sub invoke_wmi {
    my @values = eval {
        if (_PSexist()) {
            _invoke_powershell(@_);
        } else {
            _invoke_wmic(@_);
        }
    };
    warn "Error at invoke_wmi: $@" and return if $@;
    return @values;
}

sub get_wmi {
    my @values = invoke_wmi(@_);
    return $values[0];
}

sub _invoke_powershell {
    my ($class, $field, $value, $prop) = @_;

    my $command = qq(powershell.exe -NoProfile -Command "Get-WmiObject -Class $class | where $field -like '$value' | Select-Object -Property $prop | Format-Table -HideTableHeaders");
    my $output = qx/$command/;

    if ($? == -1 || $? >> 8) {
        die "Failed to execute PowerShell command: $!\n";
    }

    my @values = grep { /.+/ } split(/\s+/, $output);
    return @values;
}

sub _invoke_wmic {
    my ($class, $field, $value, $prop) = @_;

    my $command = qq|wmic PATH $class where "$field like '$value'" get $prop /value|;
    print "comand=$command\n";
    my $output = qx/$command/;

    if ($? == -1 || $? >> 8) {
        die "Failed to execute WMIC command: $!\n";
    }

    my @values;
    for my $line (split("\n", $output)) {
        if ($line =~ /=/) {
            my ($key, $value) = split(/=/, $line, 2);
            $value =~ s/\r+//g;
            push @values, $value;
        }
    }
    return @values;
}

1;
