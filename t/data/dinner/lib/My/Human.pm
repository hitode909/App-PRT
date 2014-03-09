package My::Human;
use strict;
use warnings;

sub new {
    my ($class, $name) = @_;

    bless {
        name => $name,
    }, $class;
}

sub name {
    my ($self) = @_;

    $self->{name};
}

sub eat {
    my ($self, $food) = @_;

    print "@{[ $self->name ]} is eating @{[ $food->name ]}.\n";
}

1;
