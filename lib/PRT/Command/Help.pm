package PRT::Command::Help;
use strict;
use warnings;
use PPI;

sub new {
    my ($class) = @_;
    bless {}, $class;
}

# TODO: collector must provide at leatst a file. Should need more hook point?
sub execute {
    my ($self) = @_;

    print $self->help_message;
}

sub help_message {
    return <<HELP;
usage: prt <command> <args>
HELP
}


1;
