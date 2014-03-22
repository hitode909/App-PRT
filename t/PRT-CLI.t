package t::PRT::CLI;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::CLI';
}

sub instantiate : Tests {
    isa_ok PRT::CLI->new, 'PRT::CLI';
}

sub _command_name_to_command_class : Tests {
    my $cli = PRT::CLI->new;

    is $cli->_command_name_to_command_class('hello'), 'PRT::Command::Hello', 'ucfirst';
    is $cli->_command_name_to_command_class('replace_token'), 'PRT::Command::ReplaceToken', 'separate by _';
}

sub parse : Tests {
    subtest 'when empty input' => sub {
        my $cli = PRT::CLI->new;
        ok $cli->parse;
        isa_ok $cli->command, 'PRT::Command::Help', 'default command is help';
        ok ! $cli->collector;
    };

    subtest 'when command specified' => sub {
        my $cli = PRT::CLI->new;
        $cli->parse(qw{replace_token foo bar});
        cmp_deeply $cli->command, isa('PRT::Command::ReplaceToken') & methods(
            rules => {foo => 'bar'},
        ), 'ReplaceToken command loaded';
        cmp_deeply $cli->collector, isa('PRT::Collector::Files') & methods(
            collect => [],
        ), 'Files collector loaded';
    };

    subtest 'when source and destination specified' => sub {
        my $cli = PRT::CLI->new;
        $cli->parse(qw{replace_token foo bar});
        cmp_deeply $cli->command, isa('PRT::Command::ReplaceToken') & methods(
            rules => {foo => 'bar'},
        ), 'ReplaceToken command loaded and foo => bar registered';
        cmp_deeply $cli->collector, isa('PRT::Collector::Files') & methods(
            collect => [],
        ), 'Files collector loaded';
    };

    subtest 'when source, destination, target files specified' => sub {
        my $cli = PRT::CLI->new;
        my $directory = t::test::prepare_test_code('dinner');
        $cli->parse(
            qw{replace_token foo bar},
            qq{$directory/dinner.pl},
            qq{$directory/lib/My/Food.pm},
            qq{$directory/lib/My/Human.pm}
        );
        cmp_deeply $cli->command, isa('PRT::Command::ReplaceToken') & methods(
            rules => {foo => 'bar'},
        ), 'ReplaceToken command loaded and foo => bar registered';
        cmp_deeply $cli->collector, isa('PRT::Collector::Files') & methods(
            collect => [
                qq{$directory/dinner.pl},
                qq{$directory/lib/My/Food.pm},
                qq{$directory/lib/My/Human.pm}
            ],
        ), 'Files collector loaded and files are registered';
    };

    subtest 'when invalid command specified' => sub {
        my $cli = PRT::CLI->new;
        ok exception {
            $cli->parse('invalid_comand');
        }, 'died';
    };
}

sub run : Tests {
    subtest "command which doesn't handle files" => sub {
        my $cli = PRT::CLI->new;
        my $g = mock_guard 'PRT::Command::Help' => {
            execute => sub {
                1;
            },
        };
        $cli->parse('help');
        $cli->run;

        is $g->call_count('PRT::Command::Help', 'execute'), 1, 'execute called';
    };

    subtest 'command which handles files' => sub {
        my $directory = t::test::prepare_test_code('hello_world');

        my $cli = PRT::CLI->new;
        $cli->parse(qw(replace_token foo bar), "$directory/hello_world.pl");

        my $file;
        my $g = mock_guard 'PRT::Command::ReplaceToken' => {
            execute => sub {
                (undef, $file) = @_;
            },
        };

        $cli->run;

        is $g->call_count('PRT::Command::ReplaceToken', 'execute'), 1, 'execute called';
        is $file, "$directory/hello_world.pl", 'called with file'
    };
}
