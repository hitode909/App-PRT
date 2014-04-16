package Bye;
use strict;
use warnings;
use Hello;

sub good {
    my ($class, $message) = @_;

    "Good $message";
}

sub good_bye {
    my ($class, $name) = @_;

    $class->good("bye, $name\n");
}

1;
