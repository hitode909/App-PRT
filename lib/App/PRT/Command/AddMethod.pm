package App::PRT::Command::AddMethod;
use strict;
use warnings;
use PPI;

# Internal command to add method to file

sub new {
    my ($class) = @_;
    bless {
        code => undef,
    }, $class;
}

sub handle_files { 1 }

# register a method
# arguments:
#   $code: Source code string of method to add
sub register {
    my ($self, $code) = @_;

    $self->{code} = $code;
}

sub code {
    my ($self) = @_;

    $self->{code};
}

# refactor a file
# argumensts:
#   $file: filename for refactoring
sub execute {
    my ($self, $file) = @_;

    my $document = PPI::Document->new($file);

    my $statements = $document->find('PPI::Statement');
    die 'statement not found' unless $statements;
    my $after = $statements->[-1];

    my $code_document = PPI::Document->new(\$self->code);
    my $code_statement = $code_document->find_first('PPI::Statement::Sub');

    my @comments;
    my $cursor = $code_statement->first_token->previous_token;
    while (defined $cursor && (ref $cursor eq 'PPI::Token::Comment' || ref $cursor eq 'PPI::Token::Whitespace')) {
        unshift @comments, $cursor;
        $cursor = $cursor->previous_token;
    }

    while (ref $comments[0] eq 'PPI::Token::Whitespace') {
        shift @comments;
    }

    $after->insert_before($_) for @comments;

    $after->insert_before($code_statement);

    my $whitespaces_document = PPI::Document->new(\"\n\n");
    $after->insert_before($_) for @{ $whitespaces_document->find('PPI::Token') };

    $document->save($file);
}

1;
