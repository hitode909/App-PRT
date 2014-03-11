package PRT::CLI;
use strict;
use warnings;

use Getopt::Long qw(GetOptionsFromArray);

sub new {
    my ($class) = @_;

    bless {}, $class;
}

sub run {
    my ($class, @args) = @_;

    my $command = shift @args || 'help';

    warn $command;
}

1;
