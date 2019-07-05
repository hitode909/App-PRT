package t::App::PRT::CLI;
use 5.010001;
use t::test;

use Capture::Tiny qw(capture);
use File::Basename ();
use File::pushd;
use FindBin;
use List::Util qw(first);
use Path::Class;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::CLI';
}

sub instantiate : Tests {
    isa_ok App::PRT::CLI->new, 'App::PRT::CLI';
}

sub _command_name_to_command_class : Tests {
    my $cli = App::PRT::CLI->new;

    is $cli->_command_name_to_command_class('hello'), 'App::PRT::Command::Hello', 'ucfirst';
    is $cli->_command_name_to_command_class('replace_token'), 'App::PRT::Command::ReplaceToken', 'separate by _';

    subtest 'alias' => sub {
        is $cli->_command_name_to_command_class('rename_namespace'), 'App::PRT::Command::RenameNameSpace', 'rename_namespace is alias for rename_name_space. Namespace is not name space';
    };
}

sub set_io : Tests {
    my $cli = App::PRT::CLI->new;
    $cli->set_io(*STDIN, *STDOUT);

    is $cli->{input}, *STDIN;
    is $cli->{output}, *STDOUT;
}

# Test global options and script/prt invocation.
sub script_prt_invocation : Tests {

    # Check if we are running under cover(1) from Devel::Cover
    my $is_covering = !!(eval 'Devel::Cover::get_coverage()');
    diag $is_covering ? 'Devel::Cover running' : 'Devel::Cover not covering';

    # Find the right script/prt for this test run.
    my $running_in_blib = defined first { /\bblib\b/ } @INC;
    my $dir = dir(File::Basename::dirname(__FILE__));
    my $script = $dir->parent->file(
                    ($running_in_blib ? qw(blib) : ()), qw(script prt)
                )->absolute;

    # Make the command to run script/prt.
    my @cmd = ($^X, $is_covering ? ('-MDevel::Cover=-silent,1') : ());

    push @cmd, (map { "-I$_" } @INC);
        # brute-force our @INC down to the other perl invocation
        # so that we can run tests with -Ilib.

    push @cmd, $script;
    diag "Testing script/prt with command line:\n", join ' ', @cmd;

    # Run the tests

    subtest 'when empty input' => sub {
        my ($stdout, $stderr, $exit) = capture {
            return system(@cmd);
        };
        cmp_ok $exit>>8, '==', 2, 'exit code';
    };

    subtest 'invalid option' => sub {
        my ($stdout, $stderr, $exit) = capture {
            return system(@cmd, '-~');
        };
        cmp_ok $exit>>8, '>', 0, 'exit code';
    };

    subtest 'normal invocation' => sub {
        # This is for coverage of the last line of script/prt.
        my ($stdout, $stderr, $exit) = capture {
            return system(@cmd, 'list_files');
        };
        cmp_ok $exit>>8, '==', 0, 'exit code';
        like $stdout, qr/./, 'Nonempty stdout';
    };

    subtest 'command-line help' => sub {

        for my $flag (qw(-h -? --help)) {
            my ($stdout, $stderr, $exit) = capture {
                return system(@cmd, $flag);
            };
            cmp_ok $exit>>8, '==', 0, "$flag exit code";
            like $stdout, qr/^Usage:/m, "$flag text";
        }

        my ($stdout, $stderr, $exit) = capture {
            return system(@cmd, '--man');
        };
        cmp_ok $exit>>8, '==', 0, '--man exit code';
        like $stdout,
            qr{(?:\e[^A-Z]+)?(?:SYNOPSIS|S.SY.YN.NO.OP.PS.SI.IS.S)\b}m,
            '--man text';
            # \e[A-Z]+:     'SYNOPSIS' may be preceded by an ANSI escape code.
            # S.SY.Y...S.S: 'SYNOPSIS' may be boldfaced by double-striking.

        # prt -h <foo> ignores <foo>.
        ($stdout, $stderr, $exit) = capture {
            return system(@cmd, qw(-h list_files));
        };
        cmp_ok $exit>>8, '==', 0, '-h exit code (command ignored)';
        like $stdout, qr/^Usage:/m, '-h text (command ignored)';

    };

} #parse_exec

sub parse : Tests {
    subtest 'when command specified, not a git directory' => sub {
        my $directory = t::test::prepare_test_code('contain_ignores');
        my $g = pushd($directory);

        my $cli = App::PRT::CLI->new;
        $cli->parse(qw{replace_token foo bar});
        cmp_deeply $cli->command, isa('App::PRT::Command::ReplaceToken') & methods(
            source_tokens => [ 'foo' ],
            destination_tokens => [ 'bar' ],
        ), 'ReplaceToken command loaded';

        cmp_deeply $cli->collector, isa('App::PRT::Collector::AllFiles') & methods(
            directory => $directory,
        );
    };

    subtest 'when command specified, git directory' => sub {
        my $directory = t::test::prepare_test_code('dinner');
        t::test::prepare_as_git_repository($directory);
        my $g = pushd($directory);

        my $cli = App::PRT::CLI->new;
        $cli->parse(qw{replace_token foo bar});
        cmp_deeply $cli->command, isa('App::PRT::Command::ReplaceToken') & methods(
            source_tokens => [ 'foo' ],
            destination_tokens => [ 'bar' ],
        ), 'ReplaceToken command loaded';

        cmp_deeply $cli->collector, isa('App::PRT::Collector::GitDirectory') & methods(
            directory => $directory,
        );
    };

    subtest 'when source, destination, target files specified' => sub {
        my $cli = App::PRT::CLI->new;
        my $directory = t::test::prepare_test_code('dinner');
        $cli->parse(
            qw{replace_token foo bar},
            qq{$directory/dinner.pl},
            qq{$directory/lib/My/Food.pm},
            qq{$directory/lib/My/Human.pm}
        );
        cmp_deeply $cli->command, isa('App::PRT::Command::ReplaceToken') & methods(
            source_tokens => [ 'foo' ],
            destination_tokens => [ 'bar' ],
        ), 'ReplaceToken command loaded and foo => bar registered';
        cmp_deeply $cli->collector, isa('App::PRT::Collector::Files') & methods(
            collect => [
                qq{$directory/dinner.pl},
                qq{$directory/lib/My/Food.pm},
                qq{$directory/lib/My/Human.pm}
            ],
        ), 'Files collector loaded and files are registered';
    };

    subtest 'when target ' => sub {
        my $directory = t::test::prepare_test_code('contain_ignores');
        my $g = pushd($directory);

        my $cli = App::PRT::CLI->new;
        $cli->parse(qw{replace_token foo bar});
        cmp_deeply $cli->command, isa('App::PRT::Command::ReplaceToken') & methods(
            source_tokens => [ 'foo' ],
            destination_tokens => [ 'bar' ],
        ), 'ReplaceToken command loaded';

        cmp_deeply $cli->collector, isa('App::PRT::Collector::AllFiles') & methods(
            directory => $directory,
        );
    };

    subtest 'when neither git directory or project root directory detected' => sub {
        my $directory = t::test::prepare_test_code('hello_world');
        my $g = pushd($directory);

        my $cli = App::PRT::CLI->new;
        like exception {
            $cli->parse(qw{replace_token foo bar});
        }, qr/Cannot decide target files/;
    };

    subtest 'when invalid command specified' => sub {
        my $cli = App::PRT::CLI->new;
        like exception {
            $cli->parse('invalid_command');
        }, qr/Command invalid_command not found/;
    };

    subtest 'when input is the pipe' => sub {
        my $cli = App::PRT::CLI->new;
        my $g = mock_guard 'App::PRT::CLI', { _input_is_pipe => 1 };
        $cli->parse('introduce_variables');
        cmp_deeply $cli->collector, isa('App::PRT::Collector::FileHandle');
    };

}

sub run : Tests {
    subtest 'command which can execute' => sub {
        my $directory = t::test::prepare_test_code('hello_world');

        my $cli = App::PRT::CLI->new;
        $cli->parse(qw(replace_token foo bar), "$directory/hello_world.pl");

        my $file;
        my $g = mock_guard 'App::PRT::Command::ReplaceToken' => {
            execute => sub {
                (undef, $file) = @_;
            },
        };

        $cli->run;

        is $g->call_count('App::PRT::Command::ReplaceToken', 'execute'), 1, 'execute called';
        is $file, "$directory/hello_world.pl", 'called with file'
    };

    subtest 'command which can execute_files' => sub {
        my $directory = t::test::prepare_test_code('dinner');

        my $cli = App::PRT::CLI->new;
        $cli->parse(qw(rename_namespace My Our), "$directory/lib/My/Food.pm", "$directory/lib/My/Human.pm");

        my $files;
        my $g = mock_guard 'App::PRT::Command::RenameNameSpace' => {
            execute_files => sub {
                (undef, $files) = @_;
            },
        };

        $cli->run;

        is $g->call_count('App::PRT::Command::RenameNameSpace', 'execute_files'), 1, 'execute_files called';
        cmp_deeply $files, ["$directory/lib/My/Food.pm", "$directory/lib/My/Human.pm"], 'called with files';
    };
}
