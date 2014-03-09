package PRT::Runner;
use strict;
use warnings;

sub new {
    my ($class) = @_;
    bless {}, $class;
}

# set a collector
sub set_collector {
    my ($self, $collector) = @_;

    $self->{collector} = $collector;
}

# get a collector
sub collector {
    my ($self) = @_;
    $self->{collector};
}

# set a command
sub set_command {
    my ($self, $command) = @_;

    $self->{command} = $command;
}

# get a command
sub command {
    my ($self) = @_;
    $self->{command};
}

# execute refactoring
sub run {
    my ($self) = @_;

    my $collector = $self->collector;
    my $command = $self->command;

    for my $file (@{$collector->collect}) {
        $command->execute($file);
    }
}

1;
