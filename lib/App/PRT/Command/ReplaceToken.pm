package App::PRT::Command::ReplaceToken;
use strict;
use warnings;
use PPI;

sub new {
    my ($class) = @_;
    bless {
        source_token      => undef,
        destination_token => undef,
        statement_in      => undef,
    }, $class;
}

sub handle_files { 1 }

# parse arguments from CLI
# arguments:
#   @arguments
# returns:
#   @rest_arguments
sub parse_arguments {
    my ($self, @arguments) = @_;

    die "source and destination tokens required" unless @arguments >= 2;

    $self->register(shift @arguments => shift @arguments);

    if (@arguments >= 2 && $arguments[0] eq '--in') {
        shift @arguments;
        $self->set_replace_only_statement_which_has_token(shift @arguments);
    }

    @arguments;
}

# register a replacing rule
# arguments:
#   $source:      source token
#   $destination: destinationination token
# discussions:
#   should consider utf-8 flag ?
sub register {
    my ($self, $source, $destination) = @_;

    $self->{source_token} = $source;
    $self->{destination_token} = $destination;
}

sub set_replace_only_statement_which_has_token {
    my ($self, $in) = @_;

    $self->{statement_in} = $in;
}

sub replace_only_statement_which_has_token {
    my ($self) = @_;

    $self->{statement_in};
}

sub source_token {
    my ($self) = @_;

    $self->{source_token};
}

sub destination_token {
    my ($self) = @_;

    $self->{destination_token};
}

# refactor a file
# argumensts:
#   $file: filename for refactoring
sub execute {
    my ($self, $file) = @_;

    return unless defined $self->source_token;

    my $document = PPI::Document->new($file);

    my $tokens = $document->find('PPI::Token');

    my $replaced = 0;
    for my $token (@$tokens) {
        next unless $token->content eq $self->source_token;
        $token->set_content($self->destination_token);
        $replaced++;
    }

    $document->save($file) if $replaced;
}

1;
