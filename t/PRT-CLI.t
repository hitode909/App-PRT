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
    my $cli = PRT::CLI->new;
    $cli->parse;
    isa_ok $cli->command, 'PRT::Command::Help', 'Help command loaded';
    isa_ok $cli->collector, 'PRT::Collector::Files', 'Files collector loaded';
}
