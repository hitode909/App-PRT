package FoodWithComment;
use strict;
use warnings;

# create a new food
# You can use when you want to create a new instance
sub new {
    my ($class, $name) = @_;

    bless {
        name => $name,
    }, $class;
}

# another comment

sub name {
    my ($self) = @_;

    $self->{name};
}

1;
