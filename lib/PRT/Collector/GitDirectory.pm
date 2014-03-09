package PRT::Collector::GitDirectory;
use strict;
use warnings;

sub new {
    my ($class, $directory) = @_;

    die 'directory requird' unless defined $directory;

    die "directory $directory does not exist" unless -d $directory;

    my $files = $class->_collect($directory);

    bless {
        directory     => $directory,
        files         => $files,
    }, $class;
}

sub _collect {
    my ($class, $directory) = @_;
    my $git_directory = "$directory/.git";

    my $output = `git --no-pager --git-dir $git_directory ls-files --full-name 2> /dev/null`;

    if ($?) {
        # when success, exit status is 0
        die "directory $directory seems not a git repository";
    }

    my $files = [ map { "$directory/$_" } split /\n/, $output ];
}

sub directory {
    my ($self) = @_;

    $self->{directory};
}

sub collect {
    my ($self) = @_;

    $self->{files};
}

1;
