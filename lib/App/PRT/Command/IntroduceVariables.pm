package App::PRT::Command::IntroduceVariables;
use strict;
use warnings;
use PPI;

sub new {
    my ($class) = @_;
    bless {}, $class;
}

sub collect_variables {
    my ($self, $source) = @_;

    my @matched = $source =~ m{(\$[a-z]+)}g; # TODO
    \@matched;
}

1;
