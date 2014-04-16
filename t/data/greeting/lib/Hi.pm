package Hi;
use strict;
use warnings;
use Hello;

sub good_morning {
    my ($class, $name) = @_;

    "Good morning, $name\n";
}

1;
