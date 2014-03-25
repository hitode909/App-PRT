package t::App::PRT::Collector::Files;
use t::test;

sub _require : Test(startup => 1) {
    my ($self) = @_;

    use_ok 'App::PRT::Collector::Files';
}

sub instantiate : Tests {
    isa_ok App::PRT::Collector::Files->new, 'App::PRT::Collector::Files';
}

sub collect : Tests {
    my $directory = t::test::prepare_test_code('hello_world');

    subtest 'when no files specified' => sub {
        my $collector = App::PRT::Collector::Files->new;
        is_deeply $collector->collect, [];
    }, 'result is empty';

    subtest 'when files specified' => sub {
        my $collector = App::PRT::Collector::Files->new("$directory/hello_world.pl");
        is_deeply $collector->collect, ["$directory/hello_world.pl"];
    }, 'specified files returned';

    subtest 'when not existing file specified' => sub {
        my $collector = App::PRT::Collector::Files->new("$directory/not_existd.pl");
        ok exception {
            $collector->collect;
        }, 'died';
    };
}

sub collect_multi_files: Tests {
    my $directory = t::test::prepare_test_code('dinner');

    my $files = [
        "$directory/dinner.pl",
        "$directory/lib/My/Food.pm",
        "$directory/lib/My/Human.pm",
    ];

    my $collector = App::PRT::Collector::Files->new(@$files);
    is_deeply $collector->collect, $files, 'specified files are returned';

}
