package App::PRT::Command::RenameNameSpace;
use strict;
use warnings;
use PPI;
use App::PRT::Command::RenameClass;

sub new {
    my ($class) = @_;
    bless {
        source_name_space => undef,
        target_hname_space => undef,
    }, $class;
}

# parse arguments from CLI
# arguments:
#   @arguments
# returns:
#   @rest_arguments
sub parse_arguments {
    my ($self, @arguments) = @_;

    die "source and destination class are required" unless @arguments >= 2;

    $self->register(shift @arguments => shift @arguments);

    @arguments;
}


# register a replacing rule
# arguments:
#   $source: source name space
#   $dest:   destination name space
sub register {
    my ($self, $source_name_space, $destination_name_space) = @_;

    $self->{source_name_space} = $source_name_space;
    $self->{destination_name_space} = $destination_name_space;
}

sub source_name_space {
    my ($self) = @_;

    $self->{source_name_space};
}

sub destination_name_space {
    my ($self) = @_;

    $self->{destination_name_space};
}

# refactor files
# argumensts:
#   $files: [ filenames for refactoring ]
sub execute_files {
    my ($self, $files) = @_;

    my $target_classes = $self->_collect_target_classes($files);

    my $knowns = { map { $_ => 1 } @$target_classes };

    for my $target_class (@$target_classes) {
        my $rename_command = App::PRT::Command::RenameClass->new;
        $rename_command->register($target_class => $self->_destination_class_name($target_class));
        for my $file (@$files) {
            next unless -f $file;
            my $file_after = $rename_command->execute($file);
            if ($file_after && $file_after ne $file && !$knowns->{$file_after}) {
                $knowns->{$file_after}++;
                push @$files, $file_after;
            }
        }
    }
}

sub _collect_target_classes {
    my ($self, $files) = @_;

    [ grep {
        $_
    } map {
        $self->_is_target_class($_);
    } @$files ];
}

sub _is_target_class {
    my ($self, $file) = @_;

    my $document = PPI::Document->new($file);

    # When parse failed
    return unless $document;

    my $package = $document->find_first('PPI::Statement::Package');

    return unless $package;

    if (index($package->namespace, $self->source_name_space) == 0) {
        $package->namespace;
    }
}

sub _destination_class_name {
    my ($self, $class_name) = @_;

    return unless index($class_name, $self->source_name_space) == 0;

    my $dest = $class_name;

    $self->destination_name_space . substr($class_name, length($self->source_name_space));
}

1;
