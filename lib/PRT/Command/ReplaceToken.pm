package PRT::Command::ReplaceToken;
use strict;
use warnings;
use PPI;

sub new {
    my ($class) = @_;
    bless {}, $class;
}

# get a source token for replacement
sub source_token {
    my ($self) = @_;

    $self->{source_token} // '';
}

# set a source token for replacement
sub set_source_token {
    my ($self, $source_token) = @_;

    $self->{source_token} = $source_token;
}

# get a source token for replacement
sub dest_token {
    my ($self) = @_;

    $self->{dest_token} // '';
}

# set a destination token for replacement
sub set_dest_token {
    my ($self, $dest_token) = @_;

    $self->{dest_token} = $dest_token;
}

# refactor a file
# argumensts:
#   $file: filename for refactoring
sub execute {
    my ($self, $file) = @_;

    my $source = $self->source_token;
    my $dest   = $self->dest_token;

    my $document = PPI::Document->new($file);

    my $tokens = $document->find('PPI::Token');

    for my $token (@$tokens) {
        if ($token->content eq $source) {
            $token->set_content($dest);
        }
    }

    $document->save($file);
}

1;
