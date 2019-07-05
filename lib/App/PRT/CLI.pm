package App::PRT::CLI;
use strict;
use warnings;

use Class::Load qw(load_class);
use Cwd ();

use Getopt::Long 2.34 qw(GetOptionsFromArray :config),
    qw(auto_help auto_version),     # handle -?, --help, --version
    qw(passthrough require_order),  # stop at the first unrecognized
    qw(no_getopt_compat gnu_compat bundling);   # --foo, -x, no +x

use IO::Interactive qw(is_interactive);
use List::MoreUtils qw(first_index);

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

    $self->_process_global_options(\@args);     # E.g., --help.  May exit().

    my $command = shift @args;
        # _process_global_options exit()s if no args are provided.

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

# Process any global options.  Calls exit() if no arguments are left, since
# that means there's no command.
# Note: -~ is reserved for testing.  Please do not add '~' as a valid option.

sub _process_global_options {
    my ($self, $lrArgv) = @_;
    my %opts;

    # uncoverable branch true
    GetOptionsFromArray($lrArgv, \%opts, qw(h man))
        or die 'Error while processing global options';
        # At present, this always succeeds, because it is configured to simply
        # stop at the first unrecognized option, and because none of the
        # options have coderefs or validation.

    Getopt::Long::HelpMessage(-exitval => 0, -verbose => 2) if $opts{man};
    Getopt::Long::HelpMessage(-exitval => 0) if $opts{h};

    Getopt::Long::HelpMessage(-exitval => 2) unless @$lrArgv;
} #_process_global_optons

1;
