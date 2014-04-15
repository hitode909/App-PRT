package App::PRT::Collector::AllFiles;
use strict;
use warnings;
use File::Find::Rule;
use Path::Class;

# find project root directory from specified directory path
# If exists cpanfile on path, it is a project root.
#
# returns:
#   directory path (when found)
#   undef          (when not found)
sub find_project_root_directory {
    my ($class, $directory) = @_;

    die "$directory does not exist" unless -d $directory;

    my $current = dir($directory);
    while (1) {
        if (-e $current->file('cpanfile')) {
            return $current->stringify;
        }

        if ($current eq $current->parent) {
            # not found
            return;
        }

        $current = $current->parent;
    }
}

sub new {
    my ($class, $directory) = @_;

    bless {
        directory => $directory,
    }, $class;
}

sub directory {
    my ($self) = @_;

    $self->{directory};
}

sub collect {
    my ($self) = @_;

    die "directory @{[ $self->directory ]} does not exist" unless -d $self->directory;

    my @files = $self->_retrieve_all_perl_files;

    \@files;
}

sub _retrieve_all_perl_files {
    my ($self) = @_;

    my @ignore_directories = qw(share fatlib _build .git blib local);

    my $rule = File::Find::Rule->new;
    $rule = $rule->or($rule->new
                           ->directory
                           ->name(@ignore_directories)
                           ->prune
                           ->discard,
                      $rule->new);
    my @files = $rule->file
                     ->name(qr/\.(?:pl|pm|psgi|t)\Z/)
                     ->in($self->directory);

    return @files;
}

1;
