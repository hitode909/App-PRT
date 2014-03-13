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

sub _collector_name_to_collector_class : Tests {
    my $cli = PRT::CLI->new;

    is $cli->_collector_name_to_collector_class('files'), 'PRT::Collector::Files', 'ucfirst';
    is $cli->_collector_name_to_collector_class('git_directory'), 'PRT::Collector::GitDirectory', 'separate by _';
}

sub parse : Tests {
    subtest 'when empty input' => sub {
        my $cli = PRT::CLI->new;
        $cli->parse;
        cmp_deeply $cli->command, isa('PRT::Command::Help'), 'Help command loaded';
        cmp_deeply $cli->collector, isa('PRT::Collector::Files') & methods(
            collect => [],
        ), 'Files collector loaded';
    };

    subtest 'when command specified' => sub {
        my $cli = PRT::CLI->new;
        $cli->parse('replace_token');
        cmp_deeply $cli->command, isa('PRT::Command::ReplaceToken') & methods(
            rules => {},
        ), 'ReplaceToken command loaded';
        cmp_deeply $cli->collector, isa('PRT::Collector::Files') & methods(
            collect => [],
        ), 'Files collector loaded';
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
