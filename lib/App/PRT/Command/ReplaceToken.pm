package App::PRT::Command::ReplaceToken;
use strict;
use warnings;
use PPI;

sub new {
    my ($class) = @_;
    bless {
        source_tokens      => undef,
        destination_tokens => undef,
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

    if (@arguments >= 2 && $arguments[0] eq '--in-statement') {
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

    my $source_tokens = do {
        my $document = PPI::Document::Fragment->new(\$source);
        [ map { $_->content } @{ $document->find('PPI::Token') } ];
    };

    my $destination_tokens = do {
        my $document = PPI::Document::Fragment->new(\$destination);
        [ map { $_->content } @{ $document->find('PPI::Token') } ];
    };

    $self->{source_tokens} = $source_tokens;
    $self->{destination_tokens} = $destination_tokens;
}

sub set_replace_only_statement_which_has_token {
    my ($self, $in) = @_;

    $self->{statement_in} = $in;
}

sub replace_only_statement_which_has_token {
    my ($self) = @_;

    $self->{statement_in};
}

sub source_tokens {
    my ($self) = @_;

    $self->{source_tokens};
}

sub destination_tokens {
    my ($self) = @_;

    $self->{destination_tokens};
}

# refactor a file
# argumensts:
#   $file: filename for refactoring
sub execute {
    my ($self, $file) = @_;

    return unless defined $self->source_tokens;

    my $document = PPI::Document->new($file);

    # When parse failed
    return unless $document;

    my $replaced = 0;
    if (defined $self->replace_only_statement_which_has_token) {
        $replaced += $self->_replace_in_statement($document);
    } else {
        $replaced += $self->_replace_all($document);
    }

    $document->save($file) if $replaced;
}

sub _replace_all {
    my ($self, $document) = @_;

    my $tokens = $document->find('PPI::Token');

    return 0 unless $tokens;

    my $replaced = 0;

    for my $token (@$tokens) {
        $replaced += $self->_try_replace($token);
    }

    $replaced;
}

sub _try_replace {
    my ($self, $token) = @_;
    my @matched = $self->_match($token);
    return 0 unless @matched;
    my $first = shift @matched;
    $first->set_content(join '', @{$self->destination_tokens});
    $_->set_content('') for @matched; # removing `(` will delete (...). So set empty content.
    1;
}

sub _match {
    my ($self, $token) = @_;

    my @matched;

    for my $source (@{$self->source_tokens}) {
        if ($token->content eq $source) {
            push @matched, $token;
            $token = $token->next_token;
        } else {
            return;
        }
    }
    return @matched;
}

sub _replace_in_statement {
    my ($self, $document) = @_;

    my $statements = $document->find('PPI::Statement');

    return 0 unless $statements;

    my $replaced = 0;

    for my $statement (@$statements) {
        next if ref $statement eq 'PPI::Statement::Sub';
        next if ref $statement eq 'PPI::Statement::Compound';
        next if $statement->schild(0)->content eq 'do';

        my $found = 0;
        my $tokens = $statement->find('PPI::Token');
        for my $token (@$tokens) {
            if ($token->content eq $self->replace_only_statement_which_has_token) {
                $found++;
                last;
            }
        }
        next unless $found;

        for my $token (@$tokens) {
            $replaced += $self->_try_replace($token);
        }
    }

    $replaced;
}

1;
