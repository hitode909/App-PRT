package App::PRT::Command::MoveClassMethod;
use strict;
use warnings;
use PPI;
use Path::Class;
use App::PRT::Command::ReplaceToken;
use App::PRT::Command::AddUse;
use App::PRT::Command::AddMethod;
use App::PRT::Command::DeleteMethod;
use App::PRT::Util::DestinationFile;

sub new {
    my ($class) = @_;
    bless {
        source_class_name       => undef,
        source_method_name      => undef,
        destination_class_name  => undef,
        destination_method_name => undef,
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

    die "source and destination are required" unless @arguments >= 2;

    $self->register(shift @arguments => shift @arguments);

    @arguments;
}


# register a replacing rule
# arguments:
#   $source: source class name and method name, joined by '#'
#   $dest:   destination class name and method name, joined by '#'
sub register {
    my ($self, $source, $destination) = @_;

    die 'invalid format' unless $source =~ qr/\A[^#]+#[^#]+\Z/;
    die 'invalid format' unless $destination;

    ($self->{source_class_name}, $self->{source_method_name}) = split '#', $source;
    ($self->{destination_class_name}, $self->{destination_method_name}) = split '#', $destination;
    $self->{destination_method_name} //= $self->{source_method_name};
}

sub source_class_name {
    my ($self) = @_;

    $self->{source_class_name};
}

sub source_method_name {
    my ($self) = @_;

    $self->{source_method_name};
}

sub destination_class_name {
    my ($self) = @_;

    $self->{destination_class_name};
}

sub destination_method_name {
    my ($self) = @_;

    $self->{destination_method_name};
}

sub source_method_body {
    my ($self) = @_;

    $self->{source_method_body};
}

sub destination_method_body {
    my ($self) = @_;

    my $document = PPI::Document->new(\$self->{source_method_body});
    my $sub = $document->find_first('PPI::Statement::Sub');
    $sub->schild(1)->set_content($self->destination_method_name);
    $document->content;
}

# refactor a file
# argumensts:
#   $file: filename for refactoring
sub execute {
    my ($self, $file) = @_;

    my $replaced = $self->_try_replace_tokens($file);

    # TODO:
    # - Move comment before method?
    # - Move pod?
    # - Move test code?

    my $document = PPI::Document->new($file);

    # When parse failed
    return unless $document;

    my $method_body = $self->_try_delete_method_and_get_deleted_code($file);
    if ($method_body) {
        $self->{source_method_body} = $method_body;

        # replace $class->$method
        $self->_try_replace_tokens_in_target_class($file);

        $document = PPI::Document->new($file);
        my $destination_file = App::PRT::Util::DestinationFile::destination_file(
            $self->source_class_name,
            $self->destination_class_name,
            $file
        );

        unless (-e $destination_file) {
            # prepare destination file
            my $fh = file($destination_file)->open('w');
            print $fh <<CODE;
package @{[ $self->destination_class_name ]};

1;
CODE
            $fh->close;
        }

        {
            # move method
            my $command = App::PRT::Command::AddMethod->new;
            $command->register($self->destination_method_body);
            $command->execute($destination_file);
        }

        # copy including modules
        my $packages_in_source = [ map { $_->module } @{ $document->find('PPI::Statement::Include') } ];
        for my $package (@$packages_in_source) {
            my $command = App::PRT::Command::AddUse->new;
            $command->register($package);
            $command->execute($destination_file);
        }
        1;
    }

    $replaced;
}

sub _try_replace_tokens {
    my ($self, $file) = @_;

    my $command = App::PRT::Command::ReplaceToken->new;
    $command->register(
        "@{[ $self->source_class_name ]}->@{[ $self->source_method_name ]}",
        "@{[ $self->destination_class_name ]}->@{[ $self->destination_method_name ]}"
    );
    if ($command->execute($file)) {
        $self->_try_add_use($file);
    }
}

sub _try_replace_tokens_in_target_class {
    my ($self, $file) = @_;

    my $command = App::PRT::Command::ReplaceToken->new;
    $command->register(
        "\$class->@{[ $self->source_method_name ]}",
        "@{[ $self->destination_class_name ]}->@{[ $self->destination_method_name ]}"
    );
    if ($command->execute($file)) {
        $self->_try_add_use($file);
    }
}

sub _try_add_use {
    my ($self, $file) = @_;

    my $command = App::PRT::Command::AddUse->new;
    $command->register($self->destination_class_name);
    $command->execute($file);
}

sub _try_delete_method_and_get_deleted_code {
    my ($self, $file) = @_;

    my $command = App::PRT::Command::DeleteMethod->new;
    $command->register($self->source_class_name, $self->source_method_name);
    if ($command->execute($file)) {
        return $command->deleted_code;
    }
}

1;
