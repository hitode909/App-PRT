package App::PRT::Collector::Files;
use strict;
use warnings;

sub new {
    my ($class, @files) = @_;

    bless {
        files => [@files],
    }, $class;
}

sub collect {
    my ($self) = @_;

    for my $file (@{$self->{files}}) {
        die "$file does not exist" unless -f $file;
    }

    $self->{files};
}

1;
