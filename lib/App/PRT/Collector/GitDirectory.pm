package App::PRT::Collector::GitDirectory;
use strict;
use warnings;
use Path::Class;

# find git directory from specified directory path
# returns:
#   directory path (when found)
#   undef          (when not found)
sub find_git_root_directory {
    my ($class, $directory) = @_;

    die "$directory does not exist" unless -d $directory;

    my $current = dir($directory);
    while (1) {
        if (-d $current->subdir('.git')) {
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

    die 'directory requird' unless defined $directory;

    die "directory $directory does not exist" unless -d $directory;

    bless {
        directory     => $directory,
    }, $class;
}

sub collect {
    my ($self) = @_;
    my $git_directory = dir($self->directory)->subdir('.git');

    my $output = `git --no-pager --git-dir $git_directory ls-files --full-name 2> /dev/null`;

    if ($?) {
        # when success, exit status is 0
        die "directory @{[ $self->directory ]} seems not a git repository";
    }

    my $dir = dir($self->directory);
    [ map { $dir->file($_)->stringify } split /\n/, $output ];
}

sub directory {
    my ($self) = @_;

    $self->{directory};
}

1;
