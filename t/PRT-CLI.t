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
    my $runner;
    my $g = mock_guard 'PRT::Runner' => {
        run => sub {
            $runner = shift;
            1;
        },
    };
    my $cli = PRT::CLI->new;
    $cli->parse;
    $cli->run;

    is $g->call_count('PRT::Runner', 'run'), 1, 'Runner#run called';

    cmp_deeply $runner->command, $cli->command, 'command matches';
    cmp_deeply $runner->collector, $cli->collector, 'collector matches';
}
