package App::PRT::CLI;
use strict;
use warnings;

use Class::Load qw(load_class);
use Getopt::Long qw(GetOptionsFromArray);
use App::PRT::Collector::Files;

sub new {
    my ($class) = @_;

    bless {}, $class;
}

sub parse {
    my ($self, @args) = @_;

    my $command = shift @args || 'help';

    my $command_class = $self->_command_name_to_command_class($command);
    load_class $command_class;
    $self->{command} = $command_class->new;

    my @rest_args = $self->{command}->parse_arguments(@args);

    if ($self->{command}->handle_files) {
        $self->{collector} = App::PRT::Collector::Files->new(@rest_args);
    }

    1;
}

sub run {
    my ($self) = @_;

    if ($self->command->handle_files) {
        $self->_run_for_each_files;
    } else {
        # just run
        $self->command->execute;
    }
}

sub _run_for_each_files {
    my ($self) = @_;

    my $collector = $self->collector;
    my $command = $self->command;

    for my $file (@{$collector->collect}) {
        $command->execute($file);
    }
}

sub command {
    my ($self) = @_;

    $self->{command};
}

sub collector {
    my ($self) = @_;

    $self->{collector};
}

sub _command_name_to_command_class {
    my ($self, $name) = @_;

    my $command_class = join '', map { ucfirst } split '_', $name;

    'App::PRT::Command::' . $command_class;
}

1;
