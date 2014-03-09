package PRT::Command::ReplaceToken;
use strict;
use warnings;
use Path::Class;

sub new {
    my ($class) = @_;
    bless {}, $class;
}

# set a collector for this command
# arguments:
#   $collector: PRT::Collector::*
# discussions:
#   Should command has a collector?
sub set_collector {
    my ($self, $collector) = @_;

    $self->{collector} = $collector;
}

# set a source token for replacement
sub set_source_token {
    my ($self, $source_token) = @_;

    $self->{source_tokan} = $source_token;
}

# set a destination token for replacement
sub set_dest_token {
    my ($self, $dest_token) = @_;

    $self->{dest_token} = $dest_token;
}

# refactor all files
sub execute {
    my ($self) = @_;

    for my $file (@{$self->{collector}->collect}) {
        $self->execute_file($file);
    }
}

# refactor a file
# argumensts:
#   $file: filename for refactoring
# discussions:
#   TODO: too complicated
#   TOO:  use PPI
sub execute_file {
    my ($self, $file) = @_;

    return unless exists $self->{source_tokan} && exists $self->{dest_token};

    my $source = $self->{source_tokan} // '';
    my $dest   = $self->{dest_token} // '';

    my $content = file($file)->slurp;
    $content =~ s/\Q$source\E/$dest/g;

    my $writer = file($file)->openw;
    $writer->print($content);
    $writer->close;
}

1;
