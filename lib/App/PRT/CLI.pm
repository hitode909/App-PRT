package App::PRT::CLI;
use strict;
use warnings;

use Class::Load qw(load_class);
use Getopt::Long qw(GetOptionsFromArray);
use IO::Interactive qw(is_interactive);
use Cwd ();
use App::PRT::Collector::FileHandle;
use App::PRT::Collector::Files;
use App::PRT::Collector::AllFiles;
use App::PRT::Collector::GitDirectory;

sub new {
    my ($class) = @_;

    bless {}, $class;
}

sub set_io {
    my ($self, $stdin, $stdout) = @_;
    $self->{input} = $stdin;
    $self->{output} = $stdout;
}

sub parse {
    my ($self, @args) = @_;

    my $command = shift @args or die 'prt <command> <args>';

    my $command_class = $self->_command_name_to_command_class($command);

    eval {
        load_class $command_class;
    };

    if ($@) {
        die "Command $command not found ($@)";
    }

    $self->{command} = $command_class->new;

    my @rest_args = $self->{command}->parse_arguments(@args);

    my $collector = $self->_prepare_collector(@rest_args);
    unless ($collector) {
        die 'Cannot decide target files';
    }
    $self->{collector} = $collector;

    1;
}

sub run {
    my ($self) = @_;

    my $collector = $self->collector;
    my $command = $self->command;

    if ($command->can('execute_files')) { # TODO: create a base class for command?
        $command->execute_files($collector->collect, $self->{output});
    } else {
        for my $file (@{$collector->collect}) {
            $command->execute($file, $self->{output});
        }
    }
}

sub _prepare_collector {
    my ($self, @args) = @_;

    # target files specified?
    if (@args) {
        return App::PRT::Collector::Files->new(@args);
    }

    # STDIN from pipe?
    if ($self->_input_is_pipe) {
        return App::PRT::Collector::FileHandle->new($self->{input});
    }

    my $cwd = Cwd::getcwd;

    # git directory?
    my $git_root_directory = App::PRT::Collector::GitDirectory->find_git_root_directory($cwd);
    if ($git_root_directory) {
        return App::PRT::Collector::GitDirectory->new($git_root_directory);
    }

    # seems perl project?
    my $project_root_directory = App::PRT::Collector::AllFiles->find_project_root_directory($cwd);
    if ($project_root_directory) {
        return App::PRT::Collector::AllFiles->new($project_root_directory);
    }

    return;
}

# -t  Filehandle is opened to a tty.
sub _input_is_pipe {
    my ($self) = @_;
    $self->{input} && ! is_interactive($self->{input});
}

sub command {
    my ($self) = @_;

    $self->{command};
}

sub collector {
    my ($self) = @_;

    $self->{collector};
}

sub _command_name_to_command_class {
    my ($self, $name) = @_;

    my $command_class = join '', map { ucfirst } split '_', $name;

    # XXX: Super hack to fix typo
    if ($command_class eq 'RenameNamespace') {
        $command_class = 'RenameNameSpace';
    }

    'App::PRT::Command::' . $command_class;
}

1;
