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
  prt rename_name_space Foo Bar
    Rename Foo and Foo::* classes to Bar and Bar::* classes.
  prt delete_method Food eat
    Delete eat method from Food class
  prt move_class_method 'Class#method' 'AnotherClass#another_method'
   Move Class#method to AnotherClass#another_method

HELP
}


1;
