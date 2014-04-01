package App::PRT::Collector::Files;
use strict;
use warnings;
use Cwd ();
use File::Basename ();
use File::Spec ();
use File::Find::Rule;

sub new {
    my ($class, @files) = @_;

    unless (@files) {
        @files = $class->_retrieve_all_perl_files;
    }

    bless {
        files => [@files],
    }, $class;
}

sub collect {
    my ($self) = @_;

    for my $file (@{$self->{files}}) {
        die "$file does not exist" unless -f $file;
    }

    $self->{files};
}

sub _retrieve_all_perl_files {
    my ($class) = @_;

    my $current_path = Cwd::getcwd;

    my %breadcrumb;
    my $project_root_path;
    while (1) {
        if ($breadcrumb{$current_path}++) {
            die "Cannot decide project root";
        }

        # Decide project root path
        # If exists .git or cpanfile on path, it is a project root.
        my @files = glob(
            File::Spec->catfile($current_path, '*') . " " .
            File::Spec->catfile($current_path, '.*')
        );
        if (grep { File::Basename::basename($_) =~ /\A(?:cpanfile|\.git)\Z/ } @files) {
            $project_root_path = $current_path;
            last;
        }

        $current_path = File::Basename::dirname($current_path);
    }

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
                     ->in($project_root_path);

    return @files;
}

1;
