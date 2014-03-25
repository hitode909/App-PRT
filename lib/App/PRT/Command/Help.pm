package App::PRT::Command::Help;
use strict;
use warnings;
use PPI;

sub new {
    my ($class) = @_;
    bless {}, $class;
}

sub handle_files { 0 }

sub parse_arguments {
    my ($self, @args) = @_;
    # NOP
    @args;
}

sub execute {
    my ($self) = @_;

    print $self->help_message;
}

sub help_message {
    return <<HELP;
usage: prt <command> <args> <files>

Examples:
  prt replace_token foo bar *.pm
    replace tokens with content 'foo' with 'bar' in *.pm.
  prt rename_class Foo Bar lib/*.pm
    Rename Foo class to Bar. This command will rename lib/Foo.pm to lib/Bar.pm.
HELP
}


1;
