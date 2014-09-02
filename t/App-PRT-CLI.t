package t::App::PRT::CLI;
use t::test;
use FindBin;
use File::Basename ();

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
}

sub parse : Tests {
    subtest 'when empty input' => sub {
        my $cli = App::PRT::CLI->new;
        like exception {
            $cli->parse();
        }, qr/prt <command> <args>/;
    };

    subtest 'when command specified, not a git directory' => sub {
        my $directory = t::test::prepare_test_code('contain_ignores');
        my $g = mock_guard 'Cwd' => {
            getcwd => "$directory",
        };

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
        my $g = mock_guard 'Cwd' => {
            getcwd => "$directory",
        };

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
        my $g = mock_guard 'Cwd' => {
            getcwd => "$directory",
        };

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
        my $g = mock_guard 'Cwd' => {
            getcwd => "$directory",
        };
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
    }
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
        my $g = mock_guard 'App::PRT::Command::RenameNamespace' => {
            execute_files => sub {
                (undef, $files) = @_;
            },
        };

        $cli->run;

        is $g->call_count('App::PRT::Command::RenameNamespace', 'execute_files'), 1, 'execute_files called';
        cmp_deeply $files, ["$directory/lib/My/Food.pm", "$directory/lib/My/Human.pm"], 'called with files';
    };
}
