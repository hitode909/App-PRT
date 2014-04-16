package Greeting;
use strict;
use warnings;
use Hello;
use GoodAfternoon;

sub hi {
    my ($class, $name) = @_;

    "Hi, $name\n";
}

sub bye {
    my ($class, $name) = @_;

    "Bye, $name\n";
}

1;
