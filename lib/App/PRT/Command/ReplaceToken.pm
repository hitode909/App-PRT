package App::PRT::Command::ReplaceToken;
use strict;
use warnings;
use PPI;

sub new {
    my ($class) = @_;
    bless {
        rules => {},
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

    @arguments;
}

# register a replacing rule
# arguments:
#   $source: source token
#   $dest:   destination token
# discussions:
#   should consider utf-8 flag ?
sub register {
    my ($self, $source, $dest) = @_;

    $self->rules->{$source} = $dest;
}

# return replacing rules
# returns:
#  { source => destination }
sub rules {
    my ($self) = @_;

    $self->{rules};
}

# find a destination token for a source token
# returns:
#   destination token (when regstered)
#   undef             (when not registered)
sub rule {
    my ($self, $source) = @_;

    $self->rules->{$source};
}

# refactor a file
# argumensts:
#   $file: filename for refactoring
sub execute {
    my ($self, $file) = @_;

    my $document = PPI::Document->new($file);

    my $tokens = $document->find('PPI::Token');

    for my $token (@$tokens) {
        my $dest = $self->rule($token->content);
        next unless defined $dest;
        $token->set_content($dest);
    }

    $document->save($file);
}

1;
