package App::PRT::Command::AddUse;
use strict;
use warnings;
use PPI;

# Internal command to add use statement to file

sub new {
    my ($class) = @_;
    bless {
        namespace => undef,
    }, $class;
}

# register a method
# arguments:
#   $namespace: package name to use
sub register {
    my ($self, $namespace) = @_;

    $self->{namespace} = $namespace;
}

sub namespace {
    my ($self) = @_;

    $self->{namespace};
}

# refactor a file
# argumensts:
#   $file: filename for refactoring
sub execute {
    my ($self, $file) = @_;

    my $document = PPI::Document->new($file);
    return unless $document;

    my $used = 0;
    my $last_use;
    my $include_statements = $document->find('PPI::Statement::Include');

    if ($include_statements) {
        for my $statement (@$include_statements) {
            next unless defined $statement->module;
            if ($statement->module eq $self->namespace) {
                $used++;
            }
            $last_use = $statement;
        }
    }
    return if $used;

    my $insert_to = $last_use || $document->find_first('PPI::Statement::Package') || $document->find_first('PPI::Statement');

    my $tokens_to_insert = PPI::Document->new(\"\nuse @{[ $self->namespace ]};");
    $insert_to->add_element($tokens_to_insert);
    $document->save($file);
}

1;
