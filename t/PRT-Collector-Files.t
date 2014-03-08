package t::PRT::Collector::Files;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'PRT::Collector::Files';
}

sub instantiate : Tests {
    isa_ok PRT::Collector::Files->new, 'PRT::Collector::Files';
}

sub collect : Tests {
    my $directory = t::test::create_hello_world();

    subtest 'when no files specified' => sub {
        my $collector = PRT::Collector::Files->new;
        is_deeply $collector->collect, [];
    }, 'result is empty';

    subtest 'when files specified' => sub {
        my $collector = PRT::Collector::Files->new(["$directory/hello_world.pl"]);
        is_deeply $collector->collect, ["$directory/hello_world.pl"];
    }, 'specified files returned';

    subtest 'when not existing file specified' => sub {
        my $collector = PRT::Collector::Files->new(["$directory/not_existd.pl"]);
        ok exception {
            $collector->collect;
        }, 'died';
    };

}
