package App::PRT::Command::IntroduceVariables;
use strict;
use warnings;
use PPI;

sub new {
    my ($class) = @_;
    bless {}, $class;
}

sub parse_arguments {
    my ($self, @arguments) = @_;
    use Data::Dumper;
    @arguments;
}

sub execute {
    my ($self, $file, $out) = @_;

    my $variables = $self->collect_variables($file);
    for my $variable (@$variables) {
        say $out $variable;
    }
}

sub collect_variables {
    my ($self, $file) = @_;
    my $document = PPI::Document->new($file);

    my $knowns = {};
    my $variables = [];
    my $tokens = $document->find('PPI::Token::Symbol');
    return [] unless $tokens;

    for my $token (@$tokens) {
        next if $knowns->{$token}++;

        push @$variables, $token->content;
    }

    $variables;
}

1;
