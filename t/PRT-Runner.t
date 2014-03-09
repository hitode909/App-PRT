package t::PRT::Collector::Files;
use t::test;

use PRT::Collector::Files;
use PRT::Command::ReplaceToken;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Runner';
}

sub instantiate : Tests {
    isa_ok PRT::Runner->new, 'PRT::Runner';
}

sub run : Tests {
    my $directory = t::test::create_hello_world();

    my $runner = PRT::Runner->new;
    my $collector = PRT::Collector::Files->new(["$directory/hello_world.pl"]);
    my $command = PRT::Command::ReplaceToken->new;

    ok exception {
        $runner->run;
    }, 'both collector and command are required';

    $runner->set_collector($collector);

    ok exception {
        $runner->run;
    }, 'both collector and command are required';

    $runner->set_command($command);

    is_deeply $runner->collector, $collector, 'can get collector';
    is_deeply $runner->command, $command, 'can get command';

    ok ! exception {
        $runner->run;
    }, 'run will success when collector and command are prepared';
}
